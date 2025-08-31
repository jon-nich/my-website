// Minimal Supabase client + auth helpers. Import with type="module" scripts.
// Reads window.CONFIG from config.js; falls back to localStorage keys for dev.
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

let _client = null;
export function getSupabase() {
  if (_client) return _client;
  const cfg = (globalThis.CONFIG || globalThis.SUPER_SECRET_CONFIG || {});
  const url = (cfg.supabaseUrl || localStorage.getItem('SUPABASE_URL') || '').trim();
  const key = (cfg.supabaseKey || localStorage.getItem('SUPABASE_ANON_KEY') || '').trim();
  if (!/^https?:\/\//i.test(url) || !key) {
    throw new Error('Supabase config missing. Provide supabaseUrl and supabaseKey in config.js');
  }
  _client = createClient(url, key);
  return _client;
}

// Ensure user is authenticated; returns { user, session } or redirects to index.html
export async function requireAuth(options = {}) {
  const supabase = getSupabase();
  const { data } = await supabase.auth.getSession();
  const session = data?.session || null;
  const user = session?.user || null;
  if (!user) {
    if (!options.silent) {
      location.replace(options.loginUrl || 'index.html');
    }
    return { user: null, session: null };
  }
  return { user, session };
}

// Try to read a student profile by auth user id; fallback by email; return null if not found or blocked by RLS
export async function getStudentProfile(user) {
  const supabase = getSupabase();
  try {
    // Prefer id match if your table uses id uuid = auth uid
    const byId = await supabase.from('students').select('id, full_name, section, email').eq('id', user.id).limit(1);
    const row = byId.data && byId.data[0];
    if (row) return row;
  } catch {}
  try {
    const byEmail = await supabase.from('students').select('id, full_name, section, email').eq('email', user.email).limit(1);
    return byEmail.data && byEmail.data[0] || null;
  } catch {
    return null;
  }
}

export async function signOutAndGo(url = 'index.html') {
  try { await getSupabase().auth.signOut(); } catch {}
  location.replace(url);
}
