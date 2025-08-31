// Parse the JavaScript inside dashboard.html and report syntax errors and delimiter counts
const fs = require('fs');
const path = require('path');

const file = path.resolve('c:/Users/jon.n/Desktop/my-website/dashboard.html');
const html = fs.readFileSync(file, 'utf8');

function extractLastScript(html) {
  const startIdx = html.lastIndexOf('<script');
  const endIdx = html.lastIndexOf('</script>');
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) return null;
  const tagEnd = html.indexOf('>', startIdx);
  if (tagEnd === -1) return null;
  const js = html.slice(tagEnd + 1, endIdx);
  const before = html.slice(0, tagEnd + 1);
  const startLine = (before.match(/\n/g) || []).length + 1; // 1-based
  return { js, startLine };
}

function countDelims(s) {
  const out = { backtick: 0, paren: 0, brace: 0, bracket: 0 };
  let inSingle = false, inDouble = false, inTemplate = false;
  let escape = false;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (escape) { escape = false; continue; }
    if (ch === '\\') { escape = true; continue; }
    // Toggle string states
    if (!inDouble && !inTemplate && ch === '\'' && !inSingle) { inSingle = true; continue; }
    else if (inSingle && ch === '\'') { inSingle = false; continue; }
    if (!inSingle && !inTemplate && ch === '"' && !inDouble) { inDouble = true; continue; }
    else if (inDouble && ch === '"') { inDouble = false; continue; }
    if (!inSingle && !inDouble && ch === '`') { inTemplate = !inTemplate; out.backtick += 1; continue; }

    if (inSingle || inDouble || inTemplate) continue;

    if (ch === '(') out.paren++;
    else if (ch === ')') out.paren--;
    else if (ch === '{') out.brace++;
    else if (ch === '}') out.brace--;
    else if (ch === '[') out.bracket++;
    else if (ch === ']') out.bracket--;
  }
  return out;
}

const extracted = extractLastScript(html);
if (!extracted) {
  console.error('Could not find last <script> block');
  process.exit(2);
}
const { js, startLine } = extracted;

console.log('Script starts at HTML line:', startLine);
const counts = countDelims(js);
console.log('Delimiter counts (imbalances show as non-zero negatives):', counts);

try {
  // Parse only; do not execute
  new Function(js);
  console.log('Parse: OK (no syntax error)');
} catch (e) {
  console.error('Parse error name:', e.name);
  console.error('Parse error message:', e.message);
  // Try to extract line number from stack
  const m = /<anonymous>:(\d+):(\d+)/.exec(e.stack || '');
  if (m) {
    const jsLine = Number(m[1]);
    const col = Number(m[2]);
    const htmlLine = startLine + jsLine - 1;
    console.error(`At JS line ${jsLine}, column ${col} (HTML approx line ${htmlLine})`);
    const lines = js.split(/\n/);
    const lo = Math.max(0, jsLine - 4);
    const hi = Math.min(lines.length, jsLine + 3);
    console.error('Context:\n' + lines.slice(lo, hi).map((l, i) => String(lo + i + 1).padStart(5) + ' | ' + l).join('\n'));
  } else {
    console.error('Stack:', e.stack);
  }
}
