import { HTTPException } from 'hono/http-exception';

export const jsonOk = <T>(data: T, init?: Record<string, unknown>) => ({
  ok: true,
  ...init,
  data,
});

export const jsonError = (message: string, init?: { code?: string; details?: unknown }) => ({
  ok: false,
  error: {
    message,
    code: init?.code ?? 'INTERNAL_ERROR',
    details: init?.details ?? null,
  },
});

export const parseLimit = (value: string | undefined, fallback = 20, max = 500) => {
  const parsed = Number(value ?? String(fallback));
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }

  return Math.min(parsed, max);
};

export const parseSymbol = (value: string | undefined) => value?.trim().toUpperCase() ?? undefined;

export const throwNotFound = (message: string) => {
  throw new HTTPException(404, {
    message,
  });
};
