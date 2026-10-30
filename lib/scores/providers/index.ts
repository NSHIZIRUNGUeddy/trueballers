import { basketballApiProvider } from './basketballapi';
import { genericFeedProvider } from './generic';
import type { ScoreProvider } from './types';

export function getProviders(): ScoreProvider[] {
  const url = process.env.SCORES_FEED_URL;
  if (!url) return [];

  const name = (process.env.SCORES_FEED_NAME || '').toLowerCase().replace(/[^a-z0-9]/g, '');

  if (name === 'basketballapi' || (!name && url.includes('basketballapi.net'))) {
    return [basketballApiProvider];
  }

  return [genericFeedProvider];
}

export type { GameStatus, NormalizedGame, ScoreProvider } from './types';
