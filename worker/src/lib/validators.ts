import { z } from 'zod';

const unknownRecordSchema = z.record(z.string(), z.unknown());
const chainBreakdownSchema = z.object({
  current: unknownRecordSchema.default({}),
  circulatingPrevDay: unknownRecordSchema.default({}),
  circulatingPrevWeek: unknownRecordSchema.default({}),
  circulatingPrevMonth: unknownRecordSchema.default({}),
});
const stablecoinRootChainSchema = z.object({
  gecko_id: z.string().nullable().optional(),
  totalCirculatingUSD: unknownRecordSchema.default({}),
  tokenSymbol: z.string().nullable().optional(),
  name: z.string(),
});

export const stablecoinSchema = z.object({
  id: z.union([z.string(), z.number()]).transform(String),
  name: z.string(),
  symbol: z.string(),
  gecko_id: z.string().nullable().optional().transform((value) => value ?? null),
  price: z.number().nullable().optional().transform((value) => value ?? null),
  chains: z.array(z.string()).default([]),
  circulating: unknownRecordSchema.default({}),
  circulatingPrevDay: unknownRecordSchema.default({}),
  circulatingPrevWeek: unknownRecordSchema.default({}),
  circulatingPrevMonth: unknownRecordSchema.default({}),
  chainCirculating: z.record(z.string(), chainBreakdownSchema).default({}),
  pegMechanism: z.string().nullable().optional().transform((value) => value ?? null),
  priceSource: z.string().nullable().optional().transform((value) => value ?? null),
  pegType: z.string().nullable().optional().transform((value) => value ?? null),
});

export const stablecoinsResponseSchema = z.object({
  peggedAssets: z.array(stablecoinSchema),
  chains: z.array(stablecoinRootChainSchema).optional().default([]),
});

export const yieldPoolSchema = z.object({
  pool: z.string(),
  project: z.string(),
  chain: z.string(),
  symbol: z.string(),
  apy: z.number().nullable().optional().transform((value) => value ?? null),
  tvlUsd: z.number().nullable().optional().transform((value) => value ?? null),
  poolMeta: z.string().nullable().optional().transform((value) => value ?? null),
});

export const yieldsResponseSchema = z.object({
  status: z.string().optional(),
  data: z.array(yieldPoolSchema),
});
