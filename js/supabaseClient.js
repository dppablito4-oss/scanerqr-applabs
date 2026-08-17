// ==============================================================================
// CLIENTE SUPABASE - INITIALIZER
// ==============================================================================

import { getSupabaseCredentials } from './config.js';

let supabase = null;

export function initSupabase() {
  const { url, anonKey } = getSupabaseCredentials();

  if (window.supabase && url && anonKey) {
    try {
      supabase = window.supabase.createClient(url, anonKey, {
        auth: {
          persistSession: true,
          autoRefreshToken: true
        }
      });
      return supabase;
    } catch (err) {
      console.error("Error al inicializar cliente Supabase:", err);
      return null;
    }
  }
  return null;
}

export function getSupabase() {
  if (!supabase) {
    return initSupabase();
  }
  return supabase;
}
