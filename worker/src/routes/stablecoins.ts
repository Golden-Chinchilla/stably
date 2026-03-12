import { and, desc, eq, inArray, sql } from 'drizzle-orm';
import { Hono } from 'hono';
import { stablecoinChains, stablecoinMetrics, stablecoins } from '../db/schema';
import { ensureSchema } from '../lib/bootstrap';
import { getDb } from '../lib/db';
import { jsonOk, parseLimit, parseSymbol, throwNotFound } from '../lib/http';
import type { Env } from '../lib/types';

export const stablecoinRoutes = new Hono<{ Bindings: Env }>();

stablecoinRoutes.get('/stablecoins', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const symbol = parseSymbol(context.req.query('symbol'));
  const id = context.req.query('id')?.trim();
  const pegType = context.req.query('pegType')?.trim();
  const limit = parseLimit(context.req.query('limit'), 20);

  let rows;

  if (id) {
    rows = await db.select().from(stablecoins).where(eq(stablecoins.id, id)).limit(1);
  } else if (symbol && pegType) {
    rows = await db
      .select()
      .from(stablecoins)
      .where(and(eq(stablecoins.symbol, symbol), eq(stablecoins.pegType, pegType)))
      .orderBy(desc(sql`json_extract(${stablecoins.circulatingJson}, '$.peggedUSD')`))
      .limit(limit);
  } else if (symbol) {
    rows = await db.select().from(stablecoins).where(eq(stablecoins.symbol, symbol)).limit(20);
  } else if (pegType) {
    rows = await db
      .select()
      .from(stablecoins)
      .where(eq(stablecoins.pegType, pegType))
      .orderBy(desc(sql`json_extract(${stablecoins.circulatingJson}, '$.peggedUSD')`))
      .limit(limit);
  } else {
    rows = await db
      .select()
      .from(stablecoins)
      .orderBy(desc(sql`json_extract(${stablecoins.circulatingJson}, '$.peggedUSD')`))
      .limit(limit);
  }

  const ids = rows.map((row) => row.id);
  const metricRows =
    ids.length > 0
      ? await db.select().from(stablecoinMetrics).where(inArray(stablecoinMetrics.stablecoinId, ids))
      : [];
  const metricMap = new Map(metricRows.map((row) => [row.stablecoinId, row]));

  return context.json(
    jsonOk(
      rows.map((row) => {
        const metrics = metricMap.get(row.id);

        return {
          id: row.id,
          name: row.name,
          symbol: row.symbol,
          geckoId: metrics?.geckoId ?? null,
          price: row.price,
          chains: JSON.parse(row.chainsJson),
          circulating: JSON.parse(row.circulatingJson),
          circulatingPrevDay: JSON.parse(metrics?.circulatingPrevDayJson ?? '{}'),
          circulatingPrevWeek: JSON.parse(metrics?.circulatingPrevWeekJson ?? '{}'),
          circulatingPrevMonth: JSON.parse(metrics?.circulatingPrevMonthJson ?? '{}'),
          chainCirculating: JSON.parse(row.chainCirculatingJson),
          pegMechanism: row.pegMechanism,
          priceSource: row.priceSource,
          pegType: row.pegType,
          updatedAt: row.updatedAt,
        };
      }),
      { count: rows.length },
    ),
  );
});

stablecoinRoutes.get('/stablecoins/:id', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const stablecoinId = context.req.param('id');

  const rows = await db.select().from(stablecoins).where(eq(stablecoins.id, stablecoinId)).limit(1);
  const row = rows[0];

  if (!row) {
    throwNotFound(`Stablecoin not found: ${stablecoinId}`);
  }

  const metricRows = await db
    .select()
    .from(stablecoinMetrics)
    .where(eq(stablecoinMetrics.stablecoinId, stablecoinId))
    .limit(1);
  const metrics = metricRows[0];

  const chainRows = await db
    .select()
    .from(stablecoinChains)
    .where(eq(stablecoinChains.stablecoinId, stablecoinId))
    .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`));

  return context.json(
    jsonOk({
      id: row.id,
      name: row.name,
      symbol: row.symbol,
      geckoId: metrics?.geckoId ?? null,
      price: row.price,
      chains: JSON.parse(row.chainsJson),
      circulating: JSON.parse(row.circulatingJson),
      circulatingPrevDay: JSON.parse(metrics?.circulatingPrevDayJson ?? '{}'),
      circulatingPrevWeek: JSON.parse(metrics?.circulatingPrevWeekJson ?? '{}'),
      circulatingPrevMonth: JSON.parse(metrics?.circulatingPrevMonthJson ?? '{}'),
      chainCirculating: JSON.parse(row.chainCirculatingJson),
      pegMechanism: row.pegMechanism,
      priceSource: row.priceSource,
      pegType: row.pegType,
      updatedAt: row.updatedAt,
      chainData: chainRows.map((item) => ({
        stablecoinId: item.stablecoinId,
        stablecoinSymbol: item.stablecoinSymbol,
        chain: item.chain,
        current: JSON.parse(item.currentJson),
        circulatingPrevDay: JSON.parse(item.circulatingPrevDayJson),
        circulatingPrevWeek: JSON.parse(item.circulatingPrevWeekJson),
        circulatingPrevMonth: JSON.parse(item.circulatingPrevMonthJson),
        updatedAt: item.updatedAt,
      })),
    }),
  );
});

stablecoinRoutes.get('/stablecoin-chains', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const stablecoinId = context.req.query('stablecoinId');
  const symbol = parseSymbol(context.req.query('symbol'));
  const chain = context.req.query('chain');
  const limit = parseLimit(context.req.query('limit'), 20, 1000);

  let rows;

  if (stablecoinId && chain) {
    rows = await db
      .select()
      .from(stablecoinChains)
      .where(and(eq(stablecoinChains.stablecoinId, stablecoinId), eq(stablecoinChains.chain, chain)))
      .limit(limit);
  } else if (stablecoinId) {
    rows = await db
      .select()
      .from(stablecoinChains)
      .where(eq(stablecoinChains.stablecoinId, stablecoinId))
      .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`))
      .limit(limit);
  } else if (symbol && chain) {
    rows = await db
      .select()
      .from(stablecoinChains)
      .where(and(eq(stablecoinChains.stablecoinSymbol, symbol), eq(stablecoinChains.chain, chain)))
      .limit(limit);
  } else if (symbol) {
    rows = await db
      .select()
      .from(stablecoinChains)
      .where(eq(stablecoinChains.stablecoinSymbol, symbol))
      .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`))
      .limit(limit);
  } else if (chain) {
    rows = await db
      .select()
      .from(stablecoinChains)
      .where(eq(stablecoinChains.chain, chain))
      .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`))
      .limit(limit);
  } else {
    rows = await db
      .select()
      .from(stablecoinChains)
      .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`))
      .limit(limit);
  }

  return context.json(
    jsonOk(
      rows.map((row) => ({
        stablecoinId: row.stablecoinId,
        stablecoinSymbol: row.stablecoinSymbol,
        chain: row.chain,
        current: JSON.parse(row.currentJson),
        circulatingPrevDay: JSON.parse(row.circulatingPrevDayJson),
        circulatingPrevWeek: JSON.parse(row.circulatingPrevWeekJson),
        circulatingPrevMonth: JSON.parse(row.circulatingPrevMonthJson),
        updatedAt: row.updatedAt,
      })),
      { count: rows.length },
    ),
  );
});

stablecoinRoutes.get('/chains/:chain/stablecoins', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const chain = context.req.param('chain');
  const limit = parseLimit(context.req.query('limit'), 20, 1000);

  const rows = await db
    .select()
    .from(stablecoinChains)
    .where(eq(stablecoinChains.chain, chain))
    .orderBy(desc(sql`json_extract(${stablecoinChains.currentJson}, '$.peggedUSD')`))
    .limit(limit);

  return context.json(
    jsonOk(
      rows.map((row) => ({
        stablecoinId: row.stablecoinId,
        stablecoinSymbol: row.stablecoinSymbol,
        chain: row.chain,
        current: JSON.parse(row.currentJson),
        circulatingPrevDay: JSON.parse(row.circulatingPrevDayJson),
        circulatingPrevWeek: JSON.parse(row.circulatingPrevWeekJson),
        circulatingPrevMonth: JSON.parse(row.circulatingPrevMonthJson),
        updatedAt: row.updatedAt,
      })),
      { count: rows.length },
    ),
  );
});
