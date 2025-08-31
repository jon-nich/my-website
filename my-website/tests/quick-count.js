const fs = require('fs');
const path = require('path');

const file = path.resolve(__dirname, '..', 'dashboard.html');
const src = fs.readFileSync(file, 'utf8');

let inTpl = false;
let inS = false; // '
let inD = false; // "
let inRegex = false;
let inLine = false;
let inBlock = false;
let backtickCount = 0;
let lastTplOpen = -1;

for (let i = 0; i < src.length; i++) {
  const c = src[i];
  const n = src[i + 1];
  const p = src[i - 1];

  if (inLine) {
    if (c === '\n') inLine = false;
    continue;
  }
  if (inBlock) {
    if (c === '*' && n === '/') { inBlock = false; i++; }
    continue;
  }
  if (!inTpl && !inS && !inD && !inRegex) {
    if (c === '/' && n === '/') { inLine = true; i++; continue; }
    if (c === '/' && n === '*') { inBlock = true; i++; continue; }
  }

  if (inTpl) {
    if (c === '`' && p !== '\\') { inTpl = false; backtickCount++; }
    continue;
  }
  if (!inS && !inD && !inRegex && c === '`' && p !== '\\') {
    inTpl = true; backtickCount++; lastTplOpen = i; continue;
  }

  if (!inTpl && !inRegex && !inS && c === '"' && p !== '\\') { inD = true; continue; }
  if (inD) { if (c === '"' && p !== '\\') inD = false; continue; }

  if (!inTpl && !inRegex && !inD && c === '\'' && p !== '\\') { inS = true; continue; }
  if (inS) { if (c === '\'' && p !== '\\') inS = false; continue; }

  // skip regex detection; not needed for template balance
}

const totalLines = src.split('\n').length;
console.log('Total lines:', totalLines);
console.log('Backtick tokens seen:', backtickCount);
console.log('Currently inside template?', inTpl);
if (inTpl && lastTplOpen >= 0) {
  const before = src.slice(0, lastTplOpen);
  const lineNum = before.split('\n').length;
  const lineStart = before.lastIndexOf('\n') + 1;
  const snippet = src.slice(lineStart, Math.min(src.length, lineStart + 300));
  console.log('Unclosed template starts at line', lineNum);
  console.log('Snippet:\n' + snippet);
}

// Also do a quick brace/paren/bracket balance (approximate, ignores strings/templates)
let b1 = 0, b2 = 0, b3 = 0; // {} () []
let inAnyStr = false, strCh = '';
for (let i = 0; i < src.length; i++) {
  const c = src[i];
  const p = src[i - 1];
  if (inAnyStr) {
    if (c === strCh && p !== '\\') { inAnyStr = false; strCh = ''; }
    continue;
  }
  if (c === '\'' || c === '"' || c === '`') { inAnyStr = true; strCh = c; continue; }
  if (c === '{') b1++;
  if (c === '}') b1--;
  if (c === '(') b2++;
  if (c === ')') b2--;
  if (c === '[') b3++;
  if (c === ']') b3--;
}
console.log('Balance {}:', b1, '() :', b2, '[] :', b3);
