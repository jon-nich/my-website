param(
  [string]$Root = ".",
  [int]$Port = 5173,
  [string]$HostName = "localhost"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
  Write-Host "ERROR: Root path '$Root' not found." -ForegroundColor Red
  exit 1
}

$prefix = "http://${HostName}:${Port}/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
  $listener.Start()
} catch {
  Write-Host "ERROR: Failed to bind $prefix. $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

Write-Host "Server listening on $prefix" -ForegroundColor Green

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".mjs"  = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".svg"  = "image/svg+xml"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".ico"  = "image/x-icon"
  ".map"  = "application/json; charset=utf-8"
  ".txt"  = "text/plain; charset=utf-8"
  ".wasm" = "application/wasm"
}

function Get-ContentType([string]$path) {
  $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
  if ($mime.ContainsKey($ext)) { return $mime[$ext] }
  return "application/octet-stream"
}

function ConvertTo-SafePath([string]$urlPath) {
  $p = $urlPath -replace "/+", "/"
  $p = [System.Uri]::UnescapeDataString($p)
  $p = $p.TrimStart("/")
  $p = $p -replace "\\", "/"
  return $p
}

$rootFull = [System.IO.Path]::GetFullPath($Root)

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
      $req = $ctx.Request
      $res = $ctx.Response

  $rel = [string](ConvertTo-SafePath $req.Url.AbsolutePath)
      if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "index.html" }
      if ($rel.EndsWith("/")) { $rel += "index.html" }

      $full = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($rootFull, $rel))
      if (-not $full.StartsWith($rootFull)) {
        $res.StatusCode = 403
        $res.Close()
        continue
      }

      if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $fallback = Join-Path $rootFull "index.html"
        if (Test-Path -LiteralPath $fallback -PathType Leaf) {
          $full = $fallback
        } else {
          $res.StatusCode = 404
          $res.Close()
          continue
        }
      }

      $res.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
      $res.Headers["Pragma"] = "no-cache"
      $res.Headers["Expires"] = "0"
      $res.ContentType = Get-ContentType $full

      $bytes = [System.IO.File]::ReadAllBytes($full)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
      $res.OutputStream.Close()
    } catch {
      try {
        $ctx.Response.StatusCode = 500
        $ctx.Response.Close()
      } catch {}
    }
  }
} finally {
  try { $listener.Stop() } catch {}
  try { $listener.Close() } catch {}
}
