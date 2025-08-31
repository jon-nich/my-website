// Extract the JS from the last <script> in dashboard.html and syntax-check it.
// Writes result to tests/check-result.txt for easy reading.
const fs = require('fs');
const path = require('path');

const htmlPath = path.join(__dirname, '..', 'dashboard.html');
const outJsPath = path.join(__dirname, 'dashboard-extracted.js');
const outReport = path.join(__dirname, 'check-result.txt');

function writeReport(msg) {
	try { fs.writeFileSync(outReport, String(msg), 'utf8'); } catch {}
}

try {
	const html = fs.readFileSync(htmlPath, 'utf8');
	const openRe = /<script\b[^>]*>/gi;
	const closeRe = /<\/script>/gi;
	let m, lastOpenIdx = -1, lastOpenLen = 0;
	while ((m = openRe.exec(html))) { lastOpenIdx = m.index + m[0].length; lastOpenLen = m[0].length; }
	if (lastOpenIdx === -1) {
		writeReport('No <script> block found');
		process.exit(1);
	}
	closeRe.lastIndex = lastOpenIdx;
	const cm = closeRe.exec(html);
	if (!cm) {
		writeReport('No closing </script> found');
		process.exit(1);
	}
	const jsRaw = html.slice(lastOpenIdx, cm.index);
	const before = html.slice(0, lastOpenIdx);
	const startLine = (before.match(/\n/g) || []).length + 1; // 1-based

	// Strip ESM import lines for Node Function-based syntax check
	const js = jsRaw
		.split('\n')
		.filter(line => !/^\s*import\b/.test(line))
		.join('\n');

	fs.writeFileSync(outJsPath, js, 'utf8');

	try {
		// new Function checks syntax without executing
		// Wrap in parentheses to allow top-level const/let
		new Function(`(function(){\n${js}\n})();`);
		writeReport('Syntax OK');
	} catch (e) {
		// Attempt to pull line/column
		let msg = String(e && (e.message || e));
		const stack = String(e && e.stack || '');
		let line = null, col = null;
		// V8 stack usually includes anonymous:line:col
		const mm = stack.match(/<anonymous>:(\d+):(\d+)/);
		if (mm) { line = parseInt(mm[1], 10) - 1; col = parseInt(mm[2], 10); } // adjust for wrapper
		if (line != null) {
			const htmlLine = startLine + Math.max(0, line - 1);
			msg += `\nAt extracted js line ${line}, col ${col} (dashboard.html line ${htmlLine})`;
		}
		writeReport(msg + '\n' + stack);
		process.exit(2);
	}
} catch (e) {
	writeReport('Failed: ' + (e && (e.message || e)));
	process.exit(1);
}
