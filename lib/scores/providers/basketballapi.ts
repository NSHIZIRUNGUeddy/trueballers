import type { GameStatus, NormalizedGame, ScoreProvider } from './types';

const statusMap: Record<string, GameStatus> = {
  scheduled: 'scheduled',
  not_started: 'scheduled',
  upcoming: 'scheduled',
  live: 'live',
  in_progress: 'live',
  playing: 'live',
  halftime: 'live',
  final: 'finished',
  finished: 'finished',
  full_time: 'finished',
  complete: 'finished',
  completed: 'finished',
  ended: 'finished',
  postponed: 'postponed',
  cancelled: 'cancelled',
  canceled: 'cancelled',
};

function normalizeStatus(value: unknown): GameStatus {
  const key = String(value ?? '').trim().toLowerCase().replace(/[\s-]+/g, '_');
  return statusMap[key] ?? 'scheduled';
}

function scoreValue(value: unknown): number | null {
  if (value === null || value === undefined || value === '') return null;
  const score = Number(value);
  return Number.isFinite(score) ? score : null;
}

function isoDate(value: unknown): string | null {
  if (!value) return null;
  const date = new Date(String(value));
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}

function normalizeGame(item: any): NormalizedGame | null {
  const game = item?.game ?? item;
  if (!game || typeof game !== 'object') return null;

  const externalId = game.id;
  const homeTeam = game.home?.name;
  const awayTeam = game.away?.name;
  if (!externalId || !homeTeam || !awayTeam) return null;

  const live = item?.game ? item : null;
  const status = normalizeStatus(live?.status ?? game.status);

  return {
    external_id: String(externalId),
    competition: game.competition?.name ?? null,
    home_team: String(homeTeam),
    away_team: String(awayTeam),
    home_score: scoreValue(live?.score?.home ?? game.home_score),
    away_score: scoreValue(live?.score?.away ?? game.away_score),
    status,
    period: live?.period !== null && live?.period !== undefined ? String(live.period) : null,
    scheduled_at: isoDate(game.tip_off ?? game.date),
  };
}

export const basketballApiProvider: ScoreProvider = {
  name: process.env.SCORES_FEED_NAME || 'basketballapi',
  async fetchGames() {
    const baseUrl = process.env.SCORES_FEED_URL;
    if (!baseUrl) return [];

    const path = process.env.SCORES_FEED_PATH || '/games';
    const url = `${baseUrl.replace(/\/+$/, '')}${path.startsWith('/') ? path : `/${path}`}`;

    const headers: Record<string, string> = { Accept: 'application/json' };
    const apiKey = process.env.SCORES_FEED_API_KEY;
    if (apiKey) {
      const headerName = process.env.SCORES_FEED_AUTH_HEADER || 'Authorization';
      const prefix = process.env.SCORES_FEED_AUTH_PREFIX ?? 'Bearer ';
      headers[headerName] = prefix ? `${prefix}${apiKey}` : apiKey;
    }

    const response = await fetch(url, { headers, cache: 'no-store' });
    const payload = await response.json().catch(() => null);

    if (!response.ok) {
      const message = payload?.error?.message || `Basketball API request failed with ${response.status}`;
      throw new Error(message);
    }

    if (!Array.isArray(payload?.data)) {
      throw new Error('Basketball API response did not contain a data array');
    }

    return payload.data.map(normalizeGame).filter((game: NormalizedGame | null): game is NormalizedGame => Boolean(game));
  },
};
