import { and, desc, eq } from 'drizzle-orm';
import { Hono } from 'hono';
import { cefiProducts } from '../db/schema';
import { ensureSchema } from '../lib/bootstrap';
import { getDb } from '../lib/db';
import { jsonOk, parseLimit, parseSymbol } from '../lib/http';
import type { Env } from '../lib/types';

export const cefiRoutes = new Hono<{ Bindings: Env }>();

cefiRoutes.get('/cefi-products', async (context) => {
  await ensureSchema(context.env);
  const db = getDb(context.env);
  const exchange = context.req.query('exchange')?.trim().toLowerCase();
  const assetSymbol = parseSymbol(context.req.query('asset'));
  const productType = context.req.query('productType')?.trim();
  const limit = parseLimit(context.req.query('limit'), 50, 200);

  let rows;

  if (exchange && assetSymbol && productType) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(
        and(
          eq(cefiProducts.exchange, exchange),
          eq(cefiProducts.assetSymbol, assetSymbol),
          eq(cefiProducts.productType, productType),
        ),
      )
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (exchange && assetSymbol) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(
        and(
          eq(cefiProducts.exchange, exchange),
          eq(cefiProducts.assetSymbol, assetSymbol),
        ),
      )
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (exchange && productType) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(
        and(
          eq(cefiProducts.exchange, exchange),
          eq(cefiProducts.productType, productType),
        ),
      )
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (assetSymbol && productType) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(
        and(
          eq(cefiProducts.assetSymbol, assetSymbol),
          eq(cefiProducts.productType, productType),
        ),
      )
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (exchange) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(eq(cefiProducts.exchange, exchange))
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (assetSymbol) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(eq(cefiProducts.assetSymbol, assetSymbol))
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else if (productType) {
    rows = await db
      .select()
      .from(cefiProducts)
      .where(eq(cefiProducts.productType, productType))
      .orderBy(desc(cefiProducts.apr))
      .limit(limit);
  } else {
    rows = await db.select().from(cefiProducts).orderBy(desc(cefiProducts.apr)).limit(limit);
  }

  return context.json(
    jsonOk(
      rows.map((row) => ({
        id: row.id,
        exchange: row.exchange,
        assetSymbol: row.assetSymbol,
        apr: row.apr,
        productType: normalizeProductType(row.productType, row.termDays),
        termDays: normalizeTermDays(row.productType, row.termDays),
        status: normalizeStatus(row.status, row.canPurchase),
      })),
      { count: rows.length },
    ),
  );
});

const parseBoolean = (value: string | null) => {
  if (value === null) {
    return null;
  }

  return value === 'true';
};

const normalizeProductType = (value: string | null, termDays: number | null) => {
  const normalized = (value ?? '').trim().toLowerCase();

  if (
    normalized.includes('flex') ||
    normalized.includes('saving') ||
    normalized.includes('current') ||
    normalized === '0'
  ) {
    return 'flexible';
  }

  if (
    normalized.includes('fixed') ||
    normalized.includes('lock') ||
    normalized.includes('period')
  ) {
    return 'fixed';
  }

  if ((termDays ?? 0) > 0) {
    return 'fixed';
  }

  return 'flexible';
};

const normalizeTermDays = (productType: string | null, termDays: number | null) => {
  if (normalizeProductType(productType, termDays) == 'flexible') {
    return 0;
  }

  return termDays ?? null;
};

const normalizeStatus = (
  status: string | null,
  canPurchaseValue: string | null,
) => {
  const normalized = (status ?? '').trim().toLowerCase();
  const canPurchase = parseBoolean(canPurchaseValue);

  if (
    normalized.includes('sold') ||
    normalized.includes('full') ||
    normalized.includes('limit')
  ) {
    return 'sold_out';
  }

  if (
    normalized.includes('end') ||
    normalized.includes('expire') ||
    normalized.includes('closed')
  ) {
    return 'ended';
  }

  if (
    normalized.includes('avail') ||
    normalized.includes('purchasing') ||
    normalized.includes('progress') ||
    normalized.includes('start') ||
    normalized.includes('active') ||
    normalized.includes('pending') ||
    normalized.includes('off')
  ) {
    return 'available';
  }

  if (canPurchase === true) {
    return 'available';
  }
  if (canPurchase === false) {
    return 'sold_out';
  }

  return 'unknown';
};
