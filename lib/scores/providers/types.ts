export type GameStatus = 'scheduled' | 'live' | 'finished' | 'postponed' | 'cancelled';

export type NormalizedGame = {
  external_id: string;
  competition: string | null;
  home_team: string;
  away_team: string;
  home_score: number | null;
  away_score: number | null;
  status: GameStatus;
  period: string | null;
  scheduled_at: string | null;
};

export type ScoreProvider = {
  name: string;
  fetchGames: () => Promise<NormalizedGame[]>;
};
