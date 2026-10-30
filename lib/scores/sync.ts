import { createClient } from '@supabase/supabase-js';
import { getProviders } from './providers';
import type { NormalizedGame } from './providers/types';

const BATCH_SIZE = 200;

export type SyncResult = {
  provider: string;
  fetched: number;
  updated: number;
  ok: boolean;
  error?: string;
};

function adminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  }

  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export async function syncScores(): Promise<SyncResult[]> {
  const providers = getProviders();
  if (!providers.length) return [];

  const supabase = adminClient();
  const results: SyncResult[] = [];

  for (const provider of providers) {
    try {
      const games = await provider.fetchGames();
      const uniqueGames = new Map<string, NormalizedGame>();

      for (const game of games) {
        uniqueGames.set(game.external_id, game);
      }

      const rows = Array.from(uniqueGames.values()).map((game) => ({
        ...game,
        source: provider.name,
        updated_at: new Date().toISOString(),
      }));

      for (let index = 0; index < rows.length; index += BATCH_SIZE) {
        const batch = rows.slice(index, index + BATCH_SIZE);
        const { error } = await supabase
          .from('games')
          .upsert(batch, { onConflict: 'source,external_id' });

        if (error) throw new Error(error.message);
      }

      results.push({
        provider: provider.name,
        fetched: games.length,
        updated: rows.length,
        ok: true,
      });
    } catch (error) {
      results.push({
        provider: provider.name,
        fetched: 0,
        updated: 0,
        ok: false,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return results;
}
