export interface Env {
  DB: D1Database;
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
