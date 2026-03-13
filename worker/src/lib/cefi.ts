import { cefiProducts, syncState } from '../db/schema';
import { getDb } from './db';
import type { CefiProductRecord, Env } from './types';

const INSERT_CHUNK_SIZE = 50;
const TARGET_STABLECOINS = new Set(['USDT', 'USDC', 'FDUSD', 'USDE']);

const nowIso = () => new Date().toISOString();

export const syncCefiProducts = async (env: Env) => {
  const timestamp = nowIso();
  const products = await fetchAllCefiProducts(env);
  const db = getDb(env);

  await db.delete(cefiProducts);

  if (products.length > 0) {
    await executeBatchedStatements(
      env,
      products.map((item) =>
        env.DB.prepare(
          `
            INSERT INTO cefi_products (
              id,
              exchange,
              asset_symbol,
              product_name,
              product_type,
              term_days,
              status,
              apr,
              base_apr,
              bonus_apr,
              min_amount,
              max_amount,
              quota_limit,
              can_purchase,
              can_redeem,
              requires_auth,
              start_time,
              end_time,
              tier_rates_json,
              source_url,
              raw_json,
              updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `,
        ).bind(
          item.id,
          item.exchange,
          item.assetSymbol,
          item.productName,
          item.productType,
          item.termDays,
          item.status,
          item.apr,
          item.baseApr,
          item.bonusApr,
          item.minAmount,
          item.maxAmount,
          item.quotaLimit,
          String(item.canPurchase),
          String(item.canRedeem),
          String(item.requiresAuth),
          item.startTime,
          item.endTime,
          JSON.stringify(item.tierRates),
          item.sourceUrl,
          JSON.stringify(item.raw),
          timestamp,
        ),
      ),
    );
  }

  await upsertSyncState(env, 'cefi:lastSyncAt', timestamp);

  return {
    count: products.length,
    exchanges: Array.from(new Set(products.map((item) => item.exchange))),
    syncedAt: timestamp,
  };
};

export const fetchAllCefiProducts = async (env: Env) => {
  const sources = [
    { exchange: 'binance', fetcher: () => fetchBinanceProducts(env) },
    { exchange: 'okx', fetcher: () => fetchOkxProducts(env) },
  ] as const;
  const results = await Promise.allSettled(sources.map((source) => source.fetcher()));

  const products: CefiProductRecord[] = [];

  for (const [index, result] of results.entries()) {
    const exchange = sources[index].exchange;
    if (result.status === 'fulfilled') {
      console.log(
        JSON.stringify({
          type: 'cefi.fetch.success',
          exchange,
          count: result.value.length,
        }),
      );
      products.push(...result.value);
      continue;
    }

    console.warn(
      JSON.stringify({
        type: 'cefi.fetch.error',
        exchange,
        error: result.reason instanceof Error ? result.reason.message : String(result.reason),
      }),
    );
  }

  return products;
};

const fetchBinanceProducts = async (env: Env): Promise<CefiProductRecord[]> => {
  if (!env.BINANCE_API_KEY || !env.BINANCE_API_SECRET) {
    return [];
  }

  const flexible = await signedBinanceGet<{
    rows?: Array<Record<string, unknown>>;
  }>(env, '/sapi/v1/simple-earn/flexible/list', {
    current: '1',
    size: '100',
  });

  const locked = await signedBinanceGet<{
    rows?: Array<Record<string, unknown>>;
  }>(env, '/sapi/v1/simple-earn/locked/list', {
    current: '1',
    size: '100',
  });

  const products: CefiProductRecord[] = [];

  for (const item of flexible.rows ?? []) {
    const asset = toUpperString(item.asset);
    if (!isTargetStablecoin(asset)) {
      continue;
    }

    const latestApr = parseFractionOrPercent(item.latestAnnualPercentageRate);
    const bonusApr = parseFractionOrPercent(item.airDropPercentageRate);

    products.push({
      id: `binance:flexible:${toStringValue(item.productId)}`,
      exchange: 'binance',
      assetSymbol: asset,
      productName: `${asset} Flexible Earn`,
      productType: 'flexible',
      termDays: 0,
      status: toStringValue(item.status),
      apr: latestApr,
      baseApr: latestApr,
      bonusApr,
      minAmount: parseNullableNumber(item.minPurchaseAmount),
      maxAmount: null,
      quotaLimit: null,
      canPurchase: toNullableBoolean(item.canPurchase),
      canRedeem: toNullableBoolean(item.canRedeem),
      requiresAuth: true,
      startTime: toIsoTimestamp(item.subscriptionStartTime),
      endTime: null,
      tierRates: parseBinanceTierRates(item.tierAnnualPercentageRate),
      sourceUrl: 'https://developers.binance.com/docs/simple_earn/flexible-locked/account/Get-Simple-Earn-Flexible-Product-List',
      raw: item,
    });
  }

  for (const item of locked.rows ?? []) {
    const detail = toRecord(item.detail);
    const quota = toRecord(item.quota);
    const asset = toUpperString(detail.asset);
    if (!isTargetStablecoin(asset)) {
      continue;
    }

    const baseApr = parseFractionOrPercent(detail.apr);
    const bonusApr = parseFractionOrPercent(detail.extraRewardAPR);

    products.push({
      id: `binance:locked:${toStringValue(item.projectId)}`,
      exchange: 'binance',
      assetSymbol: asset,
      productName: `${asset} Locked Earn`,
      productType: 'fixed',
      termDays: parseNullableNumber(detail.duration),
      status: toStringValue(detail.status),
      apr: sumNullable(baseApr, bonusApr),
      baseApr,
      bonusApr,
      minAmount: parseNullableNumber(quota.minimum),
      maxAmount: parseNullableNumber(quota.totalPersonalQuota),
      quotaLimit: parseNullableNumber(quota.totalPersonalQuota),
      canPurchase: toNullableBoolean(detail.isSoldOut) === null ? null : !toNullableBoolean(detail.isSoldOut)!,
      canRedeem: toNullableBoolean(detail.renewable),
      requiresAuth: true,
      startTime: toIsoTimestamp(detail.subscriptionStartTime),
      endTime: null,
      tierRates: [],
      sourceUrl: 'https://developers.binance.com/docs/simple_earn/flexible-locked/account/Get-Simple-Earn-Locked-Product-List',
      raw: item,
    });
  }

  return products;
};

const fetchOkxProducts = async (_env: Env): Promise<CefiProductRecord[]> => {
  const products: CefiProductRecord[] = [];

  for (const asset of TARGET_STABLECOINS) {
    try {
      const payload = await fetchJson<{
        code?: string;
        data?: Array<Record<string, unknown>>;
        msg?: string;
      }>(`${getRequiredBaseUrl(_env, 'OKX_API_BASE_URL')}/api/v5/finance/savings/lending-rate-summary?ccy=${asset}`);

      const item = payload.data?.[0];
      if (!item) {
        continue;
      }

      const estRate = parseFractionOrPercent(item.estRate);
      const avgRate = parseFractionOrPercent(item.avgRate);

      products.push({
        id: `okx:flexible:${asset}`,
        exchange: 'okx',
        assetSymbol: asset,
        productName: `${asset} Savings`,
        productType: 'flexible',
        termDays: 0,
        status: 'available',
        apr: estRate ?? avgRate,
        baseApr: avgRate,
        bonusApr: null,
        minAmount: null,
        maxAmount: null,
        quotaLimit: null,
        canPurchase: true,
        canRedeem: true,
        requiresAuth: false,
        startTime: null,
        endTime: null,
        tierRates: [],
        sourceUrl: 'https://www.okx.com/docs-v5/en/#financial-product-earn-get-saving-balance',
        raw: item,
      });
    } catch (error) {
      console.log(
        JSON.stringify({
          type: 'cefi.fetch.okx.skip',
          asset,
          error: error instanceof Error ? error.message : String(error),
        }),
      );
    }
  }

  if (products.length === 0) {
    console.log(
      JSON.stringify({
        type: 'cefi.fetch.okx.empty',
        queriedAssets: Array.from(TARGET_STABLECOINS),
      }),
    );
  }

  return products;
};

const signedBinanceGet = async <T>(
  env: Env,
  path: string,
  params: Record<string, string>,
): Promise<T> => {
  const timestamp = Date.now().toString();
  const baseUrl = getRequiredBaseUrl(env, 'BINANCE_API_BASE_URL');
  const query = new URLSearchParams({
    ...params,
    recvWindow: '5000',
    timestamp,
  });
  const signature = await signHmacSha256(env.BINANCE_API_SECRET!, query.toString());
  query.set('signature', signature);

  return fetchJson<T>(`${baseUrl}${path}?${query.toString()}`, {
    headers: {
      'X-MBX-APIKEY': env.BINANCE_API_KEY!,
      Accept: 'application/json',
    },
  });
};

const fetchJson = async <T>(url: string, init?: RequestInit): Promise<T> => {
  const response = await fetch(url, init);

  if (!response.ok) {
    throw new Error(`Upstream request failed: ${url} -> ${response.status}`);
  }

  return (await response.json()) as T;
};

const signHmacSha256 = async (secret: string, payload: string) => {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(payload));
  return [...new Uint8Array(signature)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
};

const parseBinanceTierRates = (value: unknown) => {
  const record = toRecord(value);
  return Object.entries(record).map(([tierLabel, apr]) => ({
    tierLabel,
    apr: parseFractionOrPercent(apr),
  }));
};

const parseFractionOrPercent = (value: unknown) => {
  if (typeof value === 'string' && value.trim().endsWith('%')) {
    const parsed = Number(value.trim().slice(0, -1));
    return Number.isFinite(parsed) ? parsed : null;
  }

  const parsed = parseNullableNumber(value);
  if (parsed === null) {
    return null;
  }

  return parsed <= 1 ? parsed * 100 : parsed;
};

const parseNullableNumber = (value: unknown) => {
  if (value === null || value === undefined || value === '') {
    return null;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
};

const toIsoTimestamp = (value: unknown) => {
  const parsed = parseNullableNumber(value);
  if (parsed === null || parsed <= 0) {
    return null;
  }

  const timestamp = parsed > 10_000_000_000 ? parsed : parsed * 1000;
  return new Date(timestamp).toISOString();
};

const toStringValue = (value: unknown) => (typeof value === 'string' ? value : value == null ? '' : String(value));
const toUpperString = (value: unknown) => toStringValue(value).trim().toUpperCase();
const toRecord = (value: unknown) =>
  value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : {};

const toNullableBoolean = (value: unknown) => {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'string') {
    if (value === 'true') {
      return true;
    }
    if (value === 'false') {
      return false;
    }
  }
  return null;
};

const isTargetStablecoin = (asset: string) => TARGET_STABLECOINS.has(asset);

const sumNullable = (left: number | null, right: number | null) => {
  if (left === null && right === null) {
    return null;
  }

  return (left ?? 0) + (right ?? 0);
};

const getRequiredBaseUrl = (
  env: Env,
  key: 'BINANCE_API_BASE_URL' | 'OKX_API_BASE_URL',
) => {
  const value = env[key]?.trim();
  if (!value) {
    throw new Error(`Missing required env var: ${key}`);
  }
  return value.replace(/\/+$/, '');
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

const executeBatchedStatements = async (
  env: Env,
  statements: D1PreparedStatement[],
) => {
  for (let index = 0; index < statements.length; index += INSERT_CHUNK_SIZE) {
    const chunk = statements.slice(index, index + INSERT_CHUNK_SIZE);
    await env.DB.batch(chunk);
  }
};
