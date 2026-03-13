CREATE TABLE IF NOT EXISTS stablecoins (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  symbol TEXT NOT NULL,
  price REAL,
  chains_json TEXT NOT NULL,
  circulating_json TEXT NOT NULL,
  chain_circulating_json TEXT NOT NULL,
  peg_mechanism TEXT,
  price_source TEXT,
  peg_type TEXT,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS stablecoin_metrics (
  stablecoin_id TEXT PRIMARY KEY NOT NULL,
  gecko_id TEXT,
  circulating_prev_day_json TEXT NOT NULL,
  circulating_prev_week_json TEXT NOT NULL,
  circulating_prev_month_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS stablecoin_chains (
  stablecoin_id TEXT NOT NULL,
  stablecoin_symbol TEXT NOT NULL,
  chain TEXT NOT NULL,
  current_json TEXT NOT NULL,
  circulating_prev_day_json TEXT NOT NULL,
  circulating_prev_week_json TEXT NOT NULL,
  circulating_prev_month_json TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (stablecoin_id, chain)
);

CREATE TABLE IF NOT EXISTS yield_pools (
  pool TEXT PRIMARY KEY NOT NULL,
  project TEXT NOT NULL,
  chain TEXT NOT NULL,
  symbol TEXT NOT NULL,
  apy REAL,
  tvl_usd REAL,
  pool_meta TEXT,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS cefi_products (
  id TEXT PRIMARY KEY NOT NULL,
  exchange TEXT NOT NULL,
  asset_symbol TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_type TEXT NOT NULL,
  term_days REAL,
  status TEXT,
  apr REAL,
  base_apr REAL,
  bonus_apr REAL,
  min_amount REAL,
  max_amount REAL,
  quota_limit REAL,
  can_purchase TEXT,
  can_redeem TEXT,
  requires_auth TEXT NOT NULL,
  start_time TEXT,
  end_time TEXT,
  tier_rates_json TEXT NOT NULL,
  source_url TEXT,
  raw_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sync_state (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_stablecoins_symbol ON stablecoins(symbol);
CREATE INDEX IF NOT EXISTS idx_stablecoins_peg_type ON stablecoins(peg_type);
CREATE INDEX IF NOT EXISTS idx_yield_pools_symbol ON yield_pools(symbol);
CREATE INDEX IF NOT EXISTS idx_yield_pools_chain ON yield_pools(chain);
CREATE INDEX IF NOT EXISTS idx_yield_pools_project ON yield_pools(project);
CREATE INDEX IF NOT EXISTS idx_cefi_products_exchange ON cefi_products(exchange);
CREATE INDEX IF NOT EXISTS idx_cefi_products_asset_symbol ON cefi_products(asset_symbol);
CREATE INDEX IF NOT EXISTS idx_cefi_products_product_type ON cefi_products(product_type);
CREATE INDEX IF NOT EXISTS idx_stablecoin_chains_chain ON stablecoin_chains(chain);
CREATE INDEX IF NOT EXISTS idx_stablecoin_chains_symbol ON stablecoin_chains(stablecoin_symbol);
