import { and, desc, eq } from 'drizzle-orm';
import { Hono } from 'hono';
import { yieldPools } from '../db/schema';
import { ensureSchema } from '../lib/bootstrap';
import { getDb } from '../lib/db';
import { jsonOk, parseLimit, parseSymbol } from '../lib/http';
import type { Env } from '../lib/types';

export const poolRoutes = new Hono<{ Bindings: Env }>();

poolRoutes.get('/pools', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const symbol = parseSymbol(context.req.query('symbol'));
  const chain = context.req.query('chain');
  const project = context.req.query('project');
  const limit = parseLimit(context.req.query('limit'), 20);

  let rows;

  if (symbol && chain && project) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(and(eq(yieldPools.symbol, symbol), eq(yieldPools.chain, chain), eq(yieldPools.project, project)))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (symbol && chain) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(and(eq(yieldPools.symbol, symbol), eq(yieldPools.chain, chain)))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (symbol && project) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(and(eq(yieldPools.symbol, symbol), eq(yieldPools.project, project)))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (chain && project) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(and(eq(yieldPools.chain, chain), eq(yieldPools.project, project)))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (symbol) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(eq(yieldPools.symbol, symbol))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (chain) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(eq(yieldPools.chain, chain))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else if (project) {
    rows = await db
      .select()
      .from(yieldPools)
      .where(eq(yieldPools.project, project))
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  } else {
    rows = await db
      .select()
      .from(yieldPools)
      .orderBy(desc(yieldPools.apy))
      .limit(limit);
  }

  return context.json(
    jsonOk(rows, { count: rows.length }),
  );
});
