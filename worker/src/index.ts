import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { HTTPException } from 'hono/http-exception';
import { ensureSchema } from './lib/bootstrap';
import { jsonError, jsonOk } from './lib/http';
import type { Env } from './lib/types';
import { healthRoutes } from './routes/health';
import { poolRoutes } from './routes/pools';
import { cefiRoutes } from './routes/cefi';
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
        '/api/cefi-products',
        '/api/sync',
      ],
    }),
  );
});

app.route('/api', healthRoutes);
app.route('/api', syncRoutes);
app.route('/api', stablecoinRoutes);
app.route('/api', poolRoutes);
app.route('/api', cefiRoutes);

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
  scheduled: async (event: ScheduledController, env: Env) => {
    const startedAt = Date.now();
    const trigger = event.cron;

    console.log(
      JSON.stringify({
        type: 'scheduled.start',
        trigger,
        scheduledTime: event.scheduledTime,
      }),
    );

    try {
      await ensureSchema(env);

      const { syncAll } = await import('./lib/defillama');
      const { syncCefiProducts } = await import('./lib/cefi');

      if (trigger === '*/10 * * * *') {
        const defiStartedAt = Date.now();
        const defi = await syncAll(env);
        console.log(
          JSON.stringify({
            type: 'scheduled.sync.defi',
            trigger,
            durationMs: Date.now() - defiStartedAt,
            stablecoins: defi.stablecoins.count,
            stablecoinChains: defi.stablecoins.chainCount,
            pools: defi.pools.count,
            status: defi.meta.status,
          }),
        );
      } else if (trigger === '5-59/10 * * * *') {
        const cefiStartedAt = Date.now();
        const cefi = await syncCefiProducts(env);
        console.log(
          JSON.stringify({
            type: 'scheduled.sync.cefi',
            trigger,
            durationMs: Date.now() - cefiStartedAt,
            products: cefi.count,
            exchanges: cefi.exchanges,
          }),
        );
      } else {
        console.log(
          JSON.stringify({
            type: 'scheduled.skip',
            trigger,
            reason: 'unrecognized trigger',
          }),
        );
      }

      console.log(
        JSON.stringify({
          type: 'scheduled.success',
          trigger,
          durationMs: Date.now() - startedAt,
        }),
      );
    } catch (error) {
      console.error(
        JSON.stringify({
          type: 'scheduled.error',
          trigger,
          durationMs: Date.now() - startedAt,
          error: formatErrorDetails(error),
        }),
      );
      throw error;
    }
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
