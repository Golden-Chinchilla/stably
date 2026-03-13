import { Hono } from 'hono';
import { ensureSchema } from '../lib/bootstrap';
import { syncCefiProducts } from '../lib/cefi';
import { syncAll } from '../lib/defillama';
import { jsonOk } from '../lib/http';
import type { Env } from '../lib/types';

export const syncRoutes = new Hono<{ Bindings: Env }>();

syncRoutes.get('/sync', async (context) => {
  await ensureSchema(context.env);

  return context.json(
    jsonOk({
      message: 'Use POST /api/sync to trigger a full sync.',
      method: 'POST',
      endpoint: '/api/sync',
    }),
  );
});

syncRoutes.post('/sync', async (context) => {
  await ensureSchema(context.env);
  const [result, cefi] = await Promise.all([
    syncAll(context.env),
    syncCefiProducts(context.env),
  ]);

  return context.json(
    jsonOk({
      ...result,
      cefi,
    }),
  );
});
