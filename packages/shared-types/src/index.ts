export type Tier = 'green' | 'blue' | 'vip' | 'exhibitor' | 'press';
export type Locale = 'mn' | 'en';

export interface User {
  id: string;
  email: string;
  name: string;
  tier: Tier;
  locale: Locale;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  tokenType: 'Bearer';
}

// `pnpm --filter @cop17/shared-types gen` → regenerates `api.ts` from docs/openapi.yaml
