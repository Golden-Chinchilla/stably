import { Hono } from 'hono';
import { sql } from 'drizzle-orm';
import { stablecoinChains, stablecoins, yieldPools } from '../db/schema';
import { ensureSchema } from '../lib/bootstrap';
import { getSyncStates } from '../lib/defillama';
import { getDb } from '../lib/db';
import { jsonOk } from '../lib/http';
import type { Env } from '../lib/types';

export const healthRoutes = new Hono<{ Bindings: Env }>();

healthRoutes.get('/health', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);

  const [syncStates, stablecoinCountRows, stablecoinChainCountRows, poolCountRows] = await Promise.all([
    getSyncStates(context.env, [
      'stablecoins:lastSyncAt',
      'yieldPools:lastSyncAt',
      'sync:lastAttemptAt',
      'sync:lastSuccessAt',
      'sync:lastFailureAt',
      'sync:lastStatus',
      'sync:lastError',
      'sync:lastDurationMs',
    ]),
    db.select({ count: sql<number>`count(*)` }).from(stablecoins),
    db.select({ count: sql<number>`count(*)` }).from(stablecoinChains),
    db.select({ count: sql<number>`count(*)` }).from(yieldPools),
  ]);

  return context.json(
    jsonOk({
      syncState: {
        stablecoins: syncStates.get('stablecoins:lastSyncAt')?.value ?? null,
        pools: syncStates.get('yieldPools:lastSyncAt')?.value ?? null,
        lastAttemptAt: syncStates.get('sync:lastAttemptAt')?.value ?? null,
        lastSuccessAt: syncStates.get('sync:lastSuccessAt')?.value ?? null,
        lastFailureAt: syncStates.get('sync:lastFailureAt')?.value ?? null,
        lastStatus: syncStates.get('sync:lastStatus')?.value ?? null,
        lastError: syncStates.get('sync:lastError')?.value ?? null,
        lastDurationMs: syncStates.get('sync:lastDurationMs')?.value ?? null,
      },
      counts: {
        stablecoins: stablecoinCountRows[0]?.count ?? 0,
        stablecoinChains: stablecoinChainCountRows[0]?.count ?? 0,
        pools: poolCountRows[0]?.count ?? 0,
      },
    }),
  );
});
