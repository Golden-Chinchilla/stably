import { Hono } from 'hono';

const app = new Hono();

app.get('/', (context) => {
  return context.json({
    name: 'stably-worker',
    ok: true,
  });
});

export default app;
