// Generate a minimal config.js at build time using environment variables.
// This lets Netlify Git auto-deploys work without committing secrets.
// Required env vars in Netlify: SUPABASE_URL, SUPABASE_ANON_KEY

import { writeFileSync } from 'fs';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('[generate-config] Missing SUPABASE_URL or SUPABASE_ANON_KEY in environment variables.');
  process.exit(1);
}

const configContent = `
window.SUPABASE_URL = "${SUPABASE_URL}";
window.SUPABASE_ANON_KEY = "${SUPABASE_ANON_KEY}";
`;

writeFileSync('config.js', configContent.trim() + '\n');
console.log('[generate-config] Wrote config.js for Supabase.');
