export interface Env {
  DB: D1Database;
  BINANCE_API_KEY?: string;
  BINANCE_API_SECRET?: string;
  BINANCE_API_BASE_URL?: string;
  OKX_API_KEY?: string;
  OKX_API_SECRET?: string;
  OKX_API_PASSPHRASE?: string;
  OKX_API_BASE_URL?: string;
}

export type SnapshotRecord = Record<string, unknown>;

export interface StablecoinRecord {
  id: string;
  name: string;
  symbol: string;
  geckoId: string | null;
  price: number | null;
  chains: string[];
  circulating: SnapshotRecord;
  circulatingPrevDay: SnapshotRecord;
  circulatingPrevWeek: SnapshotRecord;
  circulatingPrevMonth: SnapshotRecord;
  chainCirculating: Record<string, unknown>;
  pegMechanism: string | null;
  priceSource: string | null;
  pegType: string | null;
}

export interface StablecoinChainRecord {
  stablecoinId: string;
  stablecoinSymbol: string;
  chain: string;
  current: SnapshotRecord;
  circulatingPrevDay: SnapshotRecord;
  circulatingPrevWeek: SnapshotRecord;
  circulatingPrevMonth: SnapshotRecord;
}

export interface YieldPoolRecord {
  pool: string;
  project: string;
  chain: string;
  symbol: string;
  apy: number | null;
  tvlUsd: number | null;
  poolMeta: string | null;
}

export type CefiExchange = 'binance' | 'okx';

export interface CefiProductRecord {
  id: string;
  exchange: CefiExchange;
  assetSymbol: string;
  productName: string;
  productType: string;
  termDays: number | null;
  status: string | null;
  apr: number | null;
  baseApr: number | null;
  bonusApr: number | null;
  minAmount: number | null;
  maxAmount: number | null;
  quotaLimit: number | null;
  canPurchase: boolean | null;
  canRedeem: boolean | null;
  requiresAuth: boolean;
  startTime: string | null;
  endTime: string | null;
  tierRates: Array<{
    tierLabel: string;
    apr: number | null;
  }>;
  sourceUrl: string | null;
  raw: Record<string, unknown>;
}
