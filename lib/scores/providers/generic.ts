import type { GameStatus, NormalizedGame, ScoreProvider } from './types';

const statusMap: Record<string, GameStatus> = {
  scheduled: 'scheduled',
  not_started: 'scheduled',
  upcoming: 'scheduled',
  live: 'live',
  in_progress: 'live',
  playing: 'live',
  finished: 'finished',
  final: 'finished',
  full_time: 'finished',
  ft: 'finished',
  ended: 'finished',
  postponed: 'postponed',
  cancelled: 'cancelled',
  canceled: 'cancelled',
};

function teamName(value: unknown): string | null {
  if (typeof value === 'string') return value;
  if (value && typeof value === 'object') {
    const team = value as Record<string, unknown>;
    const name = team.name ?? team.displayName ?? team.display_name ?? team.short_name;
    return name ? String(name) : null;
  }
  return null;
}

function competitionName(value: unknown): string | null {
  if (typeof value === 'string') return value;
  if (value && typeof value === 'object') {
    const competition = value as Record<string, unknown>;
    const name = competition.name ?? competition.displayName ?? competition.display_name;
    return name ? String(name) : null;
  }
  return null;
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

function normalizeStatus(value: unknown): GameStatus {
  if (value && typeof value === 'object') {
    const status = value as Record<string, unknown>;
    return normalizeStatus(status.short ?? status.long ?? status.description ?? status.type);
  }
  const key = String(value ?? '').trim().toLowerCase().replace(/[\s-]+/g, '_');
  return statusMap[key] ?? 'scheduled';
}

export function normalizeGame(raw: any): NormalizedGame | null {
  if (!raw || typeof raw !== 'object') return null;

  const externalId = raw.id ?? raw.game_id ?? raw.match_id ?? raw.external_id;
  const homeTeam = teamName(raw.home_team ?? raw.homeTeam ?? raw.home);
  const awayTeam = teamName(raw.away_team ?? raw.awayTeam ?? raw.away);

  if (externalId === null || externalId === undefined || !homeTeam || !awayTeam) return null;

  return {
    external_id: String(externalId),
    competition: competitionName(raw.competition ?? raw.league ?? raw.tournament),
    home_team: homeTeam,
    away_team: awayTeam,
    home_score: scoreValue(raw.home_score ?? raw.homeScore ?? raw.score?.home),
    away_score: scoreValue(raw.away_score ?? raw.awayScore ?? raw.score?.away),
    status: normalizeStatus(raw.status),
    period: raw.period ? String(raw.period) : null,
    scheduled_at: isoDate(raw.scheduled_at ?? raw.scheduledAt ?? raw.tip_off ?? raw.starts_at ?? raw.start_time ?? raw.date),
  };
}

export const genericFeedProvider: ScoreProvider = {
  name: process.env.SCORES_FEED_NAME || 'generic',
  async fetchGames() {
    const url = process.env.SCORES_FEED_URL;
    if (!url) return [];

    const headers: Record<string, string> = { Accept: 'application/json' };
    const apiKey = process.env.SCORES_FEED_API_KEY;
    if (apiKey) {
      const headerName = process.env.SCORES_FEED_AUTH_HEADER || 'Authorization';
      const prefix = process.env.SCORES_FEED_AUTH_PREFIX ?? 'Bearer ';
      headers[headerName] = prefix ? `${prefix}${apiKey}` : apiKey;
    }

    const response = await fetch(url, { headers, cache: 'no-store' });
    if (!response.ok) throw new Error(`Score feed request failed with ${response.status}`);

    const payload = await response.json();
    const list = Array.isArray(payload)
      ? payload
      : payload.games ?? payload.data ?? payload.results ?? payload.events ?? [];

    if (!Array.isArray(list)) throw new Error('Score feed response did not contain a games array');

    return list.map(normalizeGame).filter((game): game is NormalizedGame => Boolean(game));
  },
};
