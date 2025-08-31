const fs = require('fs');
const path = 'c:/Users/jon.n/Desktop/my-website/dashboard.html';
const c = fs.readFileSync(path, 'utf8');
let back=0, lc=0, rc=0, lp=0, rp=0, lb=0, rb=0;
for (const ch of c) {
  if (ch === '`') back++;
  else if (ch === '{') lc++;
  else if (ch === '}') rc++;
  else if (ch === '(') lp++;
  else if (ch === ')') rp++;
  else if (ch === '[') lb++;
  else if (ch === ']') rb++;
}
console.log({ backticks: back, curly: `${lc}/${rc}`, paren: `${lp}/${rp}`, bracket: `${lb}/${rb}` });
