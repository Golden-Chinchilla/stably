# Stably Worker

## Responsibilities
- Fetch DefiLlama stablecoin and yield-pool data
- Fetch CeFi earn product data
- Expose query APIs through Cloudflare Workers
- Sync data to D1 on a schedule

## Key Routes
- `GET /api/health`
- `GET /api/stablecoins`
- `GET /api/stablecoins/:id`
- `GET /api/stablecoin-chains`
- `GET /api/chains/:chain/stablecoins`
- `GET /api/pools`
- `GET /api/cefi-products`
- `GET /api/sync`
- `POST /api/sync`

## CeFi Output
`GET /api/cefi-products` returns only these six display fields:
- `exchange`
- `assetSymbol`
- `apr`
- `productType`
- `termDays`
- `status`

## Supported CeFi Sources
- `Binance`: Simple Earn Flexible / Locked, requires `API key + secret`
- `OKX`: Auto Earn status from account balance, requires `API key + secret + passphrase`

## Required Env Vars
- `BINANCE_API_KEY`
- `BINANCE_API_SECRET`
- `BINANCE_API_BASE_URL`
- `OKX_API_KEY`
- `OKX_API_SECRET`
- `OKX_API_PASSPHRASE`
- `OKX_API_BASE_URL`

## Common Commands
- Install deps: `npm install`
- Local dev: `npm run dev`
- Typecheck: `npm run typecheck`
- Generate drizzle migration: `npm run db:generate`
- Run local D1 migration: `npm run db:migrate:local`
- Run remote D1 migration: `npm run db:migrate:remote`
- Deploy: `npm run deploy`
