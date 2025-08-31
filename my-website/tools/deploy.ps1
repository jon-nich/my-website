param(
  [switch]$Prod,
  [string]$SiteName,
  [string]$SiteId
)

# Resolve project root (this script lives in tools/) and publish dir from netlify.toml
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Project root: $root"

# Ensure netlify CLI available
$netlify = Get-Command netlify -ErrorAction SilentlyContinue
if (-not $netlify) {
  Write-Host "Netlify CLI not found. Install locally with npm (no admin):" -ForegroundColor Yellow
  Write-Host "  npm install -g netlify-cli" -ForegroundColor Yellow
  throw "Netlify CLI missing. Install and rerun."
}

# Ensure linked
Push-Location $root
try {
  $status = netlify status 2>$null
  if ($LASTEXITCODE -ne 0 -or -not ($status -match 'Site ID')) {
    if ($SiteId) {
      Write-Host "Linking to site by ID: $SiteId" -ForegroundColor Yellow
      netlify link --id $SiteId
    } elseif ($SiteName) {
      Write-Host "Linking to site by name: $SiteName" -ForegroundColor Yellow
      netlify link --name $SiteName
    } else {
      Write-Host "This folder is not linked to a Netlify site yet. Running interactive 'netlify link'..." -ForegroundColor Yellow
      netlify link
    }
  }

  if ($Prod) {
    Write-Host "Deploying production build..." -ForegroundColor Green
    netlify deploy --dir . --prod
  } else {
    Write-Host "Deploying draft (preview) build..." -ForegroundColor Green
    netlify deploy --dir .
  }
}
finally {
  Pop-Location
}
