# Stably

Stably is a Flutter app plus Cloudflare Worker backend for comparing stablecoin yield opportunities across DeFi and CeFi.

## Current MVP Scope

- DefiLlama data is limited to the current top 20 stablecoins by circulating USD.
- DeFi yield pools are limited to pools related to that top-20 stablecoin set.
- CeFi data currently covers `Binance` and `OKX` only.
- The CeFi board displays six core fields:
  - `platform`
  - `asset`
  - `apr`
  - `product type`
  - `term`
  - `status`
- The app does not provide local portfolio tracking or local allocation simulation anymore.
- The product still does not execute trades, custody funds, or connect wallets in the current MVP.

## Stack

- Flutter app in [`lib/`](/f:/vibecoding/stably/lib)
- Cloudflare Worker in [`worker/`](/f:/vibecoding/stably/worker)
- D1 for persistence

## Key Flows

- Browse the top 20 stablecoins and related DeFi pools
- Compare Binance and OKX CeFi savings rates
- View stablecoin details, chain coverage, and related pools
- Create simple local alert rules based on current market data

## Worker Notes

- Worker runtime docs live in [`worker/README.md`](/f:/vibecoding/stably/worker/README.md)
- Non-sensitive base URLs are configured in [`worker/wrangler.jsonc`](/f:/vibecoding/stably/worker/wrangler.jsonc)
- Exchange keys and secrets should stay in Cloudflare Variables and Secrets
