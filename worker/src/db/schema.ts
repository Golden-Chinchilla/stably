import { primaryKey, real, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const stablecoins = sqliteTable('stablecoins', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  symbol: text('symbol').notNull(),
  price: real('price'),
  chainsJson: text('chains_json').notNull(),
  circulatingJson: text('circulating_json').notNull(),
  chainCirculatingJson: text('chain_circulating_json').notNull(),
  pegMechanism: text('peg_mechanism'),
  priceSource: text('price_source'),
  pegType: text('peg_type'),
  updatedAt: text('updated_at').notNull(),
});

export const stablecoinMetrics = sqliteTable('stablecoin_metrics', {
  stablecoinId: text('stablecoin_id').primaryKey(),
  geckoId: text('gecko_id'),
  circulatingPrevDayJson: text('circulating_prev_day_json').notNull(),
  circulatingPrevWeekJson: text('circulating_prev_week_json').notNull(),
  circulatingPrevMonthJson: text('circulating_prev_month_json').notNull(),
  updatedAt: text('updated_at').notNull(),
});

export const stablecoinChains = sqliteTable(
  'stablecoin_chains',
  {
    stablecoinId: text('stablecoin_id').notNull(),
    stablecoinSymbol: text('stablecoin_symbol').notNull(),
    chain: text('chain').notNull(),
    currentJson: text('current_json').notNull(),
    circulatingPrevDayJson: text('circulating_prev_day_json').notNull(),
    circulatingPrevWeekJson: text('circulating_prev_week_json').notNull(),
    circulatingPrevMonthJson: text('circulating_prev_month_json').notNull(),
    updatedAt: text('updated_at').notNull(),
  },
  (table) => ({
    pk: primaryKey({
      columns: [table.stablecoinId, table.chain],
    }),
  }),
);

export const yieldPools = sqliteTable('yield_pools', {
  pool: text('pool').primaryKey(),
  project: text('project').notNull(),
  chain: text('chain').notNull(),
  symbol: text('symbol').notNull(),
  apy: real('apy'),
  tvlUsd: real('tvl_usd'),
  poolMeta: text('pool_meta'),
  updatedAt: text('updated_at').notNull(),
});

export const syncState = sqliteTable('sync_state', {
  key: text('key').primaryKey(),
  value: text('value').notNull(),
  updatedAt: text('updated_at').notNull(),
});
