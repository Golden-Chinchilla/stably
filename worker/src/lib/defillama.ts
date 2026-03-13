import { stablecoinChains, stablecoinMetrics, yieldPools, stablecoins, syncState } from '../db/schema';
import type {
  Env,
  SnapshotRecord,
  StablecoinChainRecord,
  StablecoinRecord,
  YieldPoolRecord,
} from './types';
import { stablecoinsResponseSchema, yieldsResponseSchema } from './validators';
import { getDb } from './db';
import { eq } from 'drizzle-orm';

const STABLECOINS_URL = 'https://stablecoins.llama.fi/stablecoins';
const YIELDS_URL = 'https://yields.llama.fi/pools';
const INSERT_CHUNK_SIZE = 50;
const MAX_TRACKED_STABLECOINS = 20;

const nowIso = () => new Date().toISOString();

const fetchJson = async <T>(url: string): Promise<T> => {
  const response = await fetch(url, {
    headers: {
      accept: 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error(`Upstream request failed: ${url} -> ${response.status}`);
  }

  return (await response.json()) as T;
};

export const fetchStablecoins = async (): Promise<StablecoinRecord[]> => {
  const payload = await fetchJson<unknown>(STABLECOINS_URL);
  const parsed = stablecoinsResponseSchema.parse(payload);

  return parsed.peggedAssets
    .slice()
    .sort(
      (left, right) =>
        getCirculatingPeggedUsd(right.circulating) - getCirculatingPeggedUsd(left.circulating),
    )
    .slice(0, MAX_TRACKED_STABLECOINS)
    .map((item) => ({
      id: item.id,
      name: item.name,
      symbol: item.symbol,
      geckoId: item.gecko_id,
      price: item.price,
      chains: item.chains,
      circulating: item.circulating,
      circulatingPrevDay: item.circulatingPrevDay,
      circulatingPrevWeek: item.circulatingPrevWeek,
      circulatingPrevMonth: item.circulatingPrevMonth,
      chainCirculating: item.chainCirculating,
      pegMechanism: item.pegMechanism,
      priceSource: item.priceSource,
      pegType: item.pegType,
    }));
};

export const fetchYieldPools = (
  trackedSymbols?: ReadonlySet<string>,
): Promise<YieldPoolRecord[]> => fetchTrackedYieldPools(trackedSymbols);

const fetchTrackedYieldPools = async (
  trackedSymbols?: ReadonlySet<string>,
): Promise<YieldPoolRecord[]> => {
  const payload = await fetchJson<unknown>(YIELDS_URL);
  const parsed = yieldsResponseSchema.parse(payload);

  return parsed.data
    .filter((item) =>
      !trackedSymbols || trackedSymbols.size === 0
        ? true
        : matchesTrackedStablecoinSymbol(item.symbol, trackedSymbols),
    )
    .map((item) => ({
      pool: item.pool,
      project: item.project,
      chain: item.chain,
      symbol: item.symbol,
      apy: item.apy,
      tvlUsd: item.tvlUsd,
      poolMeta: item.poolMeta,
    }));
};

export const syncStablecoins = async (
  env: Env,
  data?: StablecoinRecord[],
) => {
  const db = getDb(env);
  const timestamp = nowIso();
  const stablecoinData = data ?? await fetchStablecoins();
  const chainData = stablecoinData.flatMap(buildStablecoinChainRecords);
  await db.delete(stablecoinChains);
  await db.delete(stablecoinMetrics);
  await db.delete(stablecoins);

  if (stablecoinData.length > 0) {
    await executeBatchedStatements(
      env,
      stablecoinData.map((item) =>
        env.DB.prepare(
          `
            INSERT INTO stablecoins (
              id,
              name,
              symbol,
              price,
              chains_json,
              circulating_json,
              chain_circulating_json,
              peg_mechanism,
              price_source,
              peg_type,
              updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `,
        ).bind(
          item.id,
          item.name,
          item.symbol,
          item.price,
          JSON.stringify(item.chains),
          JSON.stringify(item.circulating),
          JSON.stringify(item.chainCirculating),
          item.pegMechanism,
          item.priceSource,
          item.pegType,
          timestamp,
        ),
      ),
    );

    await executeBatchedStatements(
      env,
      stablecoinData.map((item) =>
        env.DB.prepare(
          `
            INSERT INTO stablecoin_metrics (
              stablecoin_id,
              gecko_id,
              circulating_prev_day_json,
              circulating_prev_week_json,
              circulating_prev_month_json,
              updated_at
            ) VALUES (?, ?, ?, ?, ?, ?)
          `,
        ).bind(
          item.id,
          item.geckoId,
          JSON.stringify(item.circulatingPrevDay),
          JSON.stringify(item.circulatingPrevWeek),
          JSON.stringify(item.circulatingPrevMonth),
          timestamp,
        ),
      ),
    );

    if (chainData.length > 0) {
      await executeBatchedStatements(
        env,
        chainData.map((item) =>
          env.DB.prepare(
            `
              INSERT INTO stablecoin_chains (
                stablecoin_id,
                stablecoin_symbol,
                chain,
                current_json,
                circulating_prev_day_json,
                circulating_prev_week_json,
                circulating_prev_month_json,
                updated_at
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `,
          ).bind(
            item.stablecoinId,
            item.stablecoinSymbol,
            item.chain,
            JSON.stringify(item.current),
            JSON.stringify(item.circulatingPrevDay),
            JSON.stringify(item.circulatingPrevWeek),
            JSON.stringify(item.circulatingPrevMonth),
            timestamp,
          ),
        ),
      );
    }
  }

  await upsertSyncState(env, 'stablecoins:lastSyncAt', timestamp);
  return {
    count: stablecoinData.length,
    chainCount: chainData.length,
    syncedAt: timestamp,
  };
};

export const syncYieldPools = async (
  env: Env,
  trackedSymbols?: ReadonlySet<string>,
) => {
  const db = getDb(env);
  const timestamp = nowIso();
  const data = await fetchYieldPools(trackedSymbols);
  await db.delete(yieldPools);

  if (data.length > 0) {
    await executeBatchedStatements(
      env,
      data.map((item) =>
        env.DB.prepare(
          `
            INSERT INTO yield_pools (
              pool,
              project,
              chain,
              symbol,
              apy,
              tvl_usd,
              pool_meta,
              updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          `,
        ).bind(
          item.pool,
          item.project,
          item.chain,
          item.symbol,
          item.apy,
          item.tvlUsd,
          item.poolMeta,
          timestamp,
        ),
      ),
    );
  }

  await upsertSyncState(env, 'yieldPools:lastSyncAt', timestamp);
  return { count: data.length, syncedAt: timestamp };
};

export const syncAll = async (env: Env) => {
  const startedAt = Date.now();
  const attemptedAt = nowIso();

  await setSyncLifecycleState(env, 'sync:lastAttemptAt', attemptedAt);

  try {
    const trackedStablecoins = await fetchStablecoins();
    const trackedSymbols = buildTrackedStablecoinSymbols(trackedStablecoins);
    const stablecoinResult = await syncStablecoins(env, trackedStablecoins);
    const poolResult = await syncYieldPools(env, trackedSymbols);
    const finishedAt = nowIso();
    const durationMs = String(Date.now() - startedAt);

    await Promise.all([
      setSyncLifecycleState(env, 'sync:lastSuccessAt', finishedAt),
      setSyncLifecycleState(env, 'sync:lastDurationMs', durationMs),
      setSyncLifecycleState(env, 'sync:lastStatus', 'success'),
      deleteSyncState(env, 'sync:lastError'),
    ]);

    return {
      stablecoins: stablecoinResult,
      pools: poolResult,
      meta: {
        attemptedAt,
        finishedAt,
        durationMs: Number(durationMs),
        status: 'success',
      },
    };
  } catch (error) {
    const failedAt = nowIso();
    const message = error instanceof Error ? error.message : String(error);

    await Promise.all([
      setSyncLifecycleState(env, 'sync:lastFailureAt', failedAt),
      setSyncLifecycleState(env, 'sync:lastStatus', 'failed'),
      setSyncLifecycleState(env, 'sync:lastError', truncateValue(message)),
      setSyncLifecycleState(env, 'sync:lastDurationMs', String(Date.now() - startedAt)),
    ]);

    throw error;
  }
};

export const getSyncState = async (env: Env, key: string) => {
  const db = getDb(env);
  const rows = await db.select().from(syncState).where(eq(syncState.key, key)).limit(1);
  return rows[0] ?? null;
};

export const getSyncStates = async (env: Env, keys: string[]) => {
  const results = await Promise.all(keys.map((key) => getSyncState(env, key)));
  return new Map(
    results
      .filter((item): item is NonNullable<typeof item> => item !== null)
      .map((item) => [item.key, item]),
  );
};

const upsertSyncState = async (env: Env, key: string, value: string) => {
  const db = getDb(env);
  await db
    .insert(syncState)
    .values({
      key,
      value,
      updatedAt: nowIso(),
    })
    .onConflictDoUpdate({
      target: syncState.key,
      set: {
        value,
        updatedAt: nowIso(),
      },
    });
};

const setSyncLifecycleState = async (env: Env, key: string, value: string) => {
  await upsertSyncState(env, key, value);
};

const deleteSyncState = async (env: Env, key: string) => {
  const db = getDb(env);
  await db.delete(syncState).where(eq(syncState.key, key));
};

const buildStablecoinChainRecords = (stablecoin: StablecoinRecord): StablecoinChainRecord[] => {
  const chainMap = stablecoin.chainCirculating;
  const chainNames = new Set<string>([
    ...stablecoin.chains,
    ...Object.keys(chainMap),
  ]);

  return Array.from(chainNames).map((chain) => {
    const rawValue = chainMap[chain];
    const value =
      rawValue && typeof rawValue === 'object' && !Array.isArray(rawValue)
        ? (rawValue as Record<string, unknown>)
        : {};

    return {
      stablecoinId: stablecoin.id,
      stablecoinSymbol: stablecoin.symbol,
      chain,
      current: ensureSnapshot(value.current),
      circulatingPrevDay: ensureSnapshot(value.circulatingPrevDay),
      circulatingPrevWeek: ensureSnapshot(value.circulatingPrevWeek),
      circulatingPrevMonth: ensureSnapshot(value.circulatingPrevMonth),
    };
  });
};

const buildTrackedStablecoinSymbols = (stablecoins: StablecoinRecord[]) =>
  new Set(
    stablecoins
      .map((item) => normalizeTrackedSymbol(item.symbol))
      .filter((item): item is string => item.length > 0),
  );

const matchesTrackedStablecoinSymbol = (
  symbol: string,
  trackedSymbols: ReadonlySet<string>,
) => {
  const normalized = normalizeTrackedSymbol(symbol);
  if (normalized && trackedSymbols.has(normalized)) {
    return true;
  }

  for (const token of tokenizePoolSymbol(symbol)) {
    if (trackedSymbols.has(token)) {
      return true;
    }
  }

  return false;
};

const tokenizePoolSymbol = (symbol: string) =>
  symbol
    .toUpperCase()
    .split(/[^A-Z0-9]+/)
    .map((item) => item.trim())
    .filter((item) => item.length > 0)
    .map(normalizeTrackedSymbol)
    .filter((item): item is string => item.length > 0);

const normalizeTrackedSymbol = (symbol: string) =>
  symbol
    .trim()
    .toUpperCase()
    .replace(/\.E$/, '');

const ensureSnapshot = (value: unknown): SnapshotRecord => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }

  return value as SnapshotRecord;
};

const executeBatchedStatements = async (
  env: Env,
  statements: D1PreparedStatement[],
) => {
  for (let index = 0; index < statements.length; index += INSERT_CHUNK_SIZE) {
    const chunk = statements.slice(index, index + INSERT_CHUNK_SIZE);
    await env.DB.batch(chunk);
  }
};

const truncateValue = (value: string, maxLength = 300) =>
  value.length <= maxLength ? value : `${value.slice(0, maxLength)}...`;

const getCirculatingPeggedUsd = (value: SnapshotRecord) => {
  const raw = value.peggedUSD;
  return typeof raw === 'number' && Number.isFinite(raw) ? raw : 0;
};
