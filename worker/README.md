# Stably Worker

## 当前职责
- 拉取 DefiLlama 稳定币与收益池数据
- 通过 Cloudflare Workers 对外提供查询 API
- 通过 Cron Triggers 定时同步数据到 D1

## 目录
- `src/index.ts`
  - Worker 入口
- `src/routes/`
  - 路由定义
- `src/lib/`
  - 上游抓取、D1 初始化、通用 HTTP 工具
- `src/db/schema.ts`
  - Drizzle 表结构
- `drizzle/0000_init.sql`
  - D1 初始化 SQL

## 当前表
- `stablecoins`
- `stablecoin_metrics`
- `stablecoin_chains`
- `yield_pools`
- `sync_state`

## 当前接口
- `GET /api/health`
- `GET /api/stablecoins`
- `GET /api/stablecoins/:id`
- `GET /api/stablecoin-chains`
- `GET /api/chains/:chain/stablecoins`
- `GET /api/pools`
- `GET /api/sync`
- `POST /api/sync`

## 常用命令
- 安装依赖：`npm install`
- 本地开发：`npm run dev`
- 类型检查：`npm run typecheck`
- 生成 drizzle 迁移：`npm run db:generate`
- 本地执行 D1 初始化：`npm run db:migrate:local`
- 远端执行 D1 初始化：`npm run db:migrate:remote`
- 部署：`npm run deploy`
