import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { HTTPException } from 'hono/http-exception';
import { ensureSchema } from './lib/bootstrap';
import { jsonError, jsonOk } from './lib/http';
import type { Env } from './lib/types';
import { healthRoutes } from './routes/health';
import { poolRoutes } from './routes/pools';
import { stablecoinRoutes } from './routes/stablecoins';
import { syncRoutes } from './routes/sync';

const app = new Hono<{ Bindings: Env }>();

app.use(
  '*',
  cors({
    origin: '*',
    allowMethods: ['GET', 'POST', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Accept'],
  }),
);

app.get('/', async (context) => {
  await ensureSchema(context.env);

  return context.json(
    jsonOk({
      name: 'stably-worker',
      endpoints: [
        '/api/health',
        '/api/stablecoins',
        '/api/stablecoins/:id',
        '/api/stablecoin-chains',
        '/api/chains/:chain/stablecoins',
        '/api/pools',
        '/api/sync',
      ],
    }),
  );
});

app.route('/api', healthRoutes);
app.route('/api', syncRoutes);
app.route('/api', stablecoinRoutes);
app.route('/api', poolRoutes);

app.notFound((context) =>
  context.json(jsonError('Route not found', { code: 'NOT_FOUND' }), 404),
);

app.onError((error, context) => {
  if (error instanceof HTTPException) {
    return context.json(
      jsonError(error.message, {
        code: error.status === 404 ? 'NOT_FOUND' : 'HTTP_ERROR',
      }),
      error.status,
    );
  }

  return context.json(
    jsonError('Internal server error', {
      code: 'INTERNAL_ERROR',
      details: formatErrorDetails(error),
    }),
    500,
  );
});

export default {
  fetch: app.fetch,
  scheduled: async (_event: ScheduledController, env: Env) => {
    await ensureSchema(env);
    const { syncAll } = await import('./lib/defillama');
    await syncAll(env);
  },
};

const formatErrorDetails = (error: unknown) => {
  const raw = error instanceof Error ? error.message : String(error);
  const normalized = raw.replaceAll(/\s+/g, ' ').trim();

  if (normalized.length <= 300) {
    return normalized;
  }

  return `${normalized.slice(0, 300)}...`;
};
