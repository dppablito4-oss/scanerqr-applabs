// ==============================================================================
// CONFIGURACIÓN DE SUPABASE - COPIADORA GRAFIPLOT
// ==============================================================================

// Credenciales por defecto de Supabase (Copiadora Grafiplot)
const DEFAULT_SUPABASE_URL = "https://kahdnjjzzvliklxwlpse.supabase.co";
const DEFAULT_SUPABASE_ANON_KEY = "sb_publishable_88GyJuBlUZeIT5YlTbma1w_994h7mGd";

// Claves en localStorage
const STORAGE_KEY_URL = "grafiplot_supabase_url";
const STORAGE_KEY_KEY = "grafiplot_supabase_key";

export function getSupabaseCredentials() {
  const customUrl = localStorage.getItem(STORAGE_KEY_URL);
  const customKey = localStorage.getItem(STORAGE_KEY_KEY);

  return {
    url: (customUrl && customUrl.trim()) ? customUrl.trim() : DEFAULT_SUPABASE_URL,
    anonKey: (customKey && customKey.trim()) ? customKey.trim() : DEFAULT_SUPABASE_ANON_KEY
  };
}

export function saveSupabaseCredentials(url, anonKey) {
  if (url) localStorage.setItem(STORAGE_KEY_URL, url.trim());
  if (anonKey) localStorage.setItem(STORAGE_KEY_KEY, anonKey.trim());
}

export function isSupabaseConfigured() {
  const creds = getSupabaseCredentials();
  return creds.url && !creds.url.includes("your-supabase-project") && creds.anonKey && !creds.anonKey.includes("your-supabase-anon-key");
}
