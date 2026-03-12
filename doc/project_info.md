# Stably 项目总览

## 一、项目定位

- 项目名称：`Stably`
- 产品类型：稳定币收益发现、分配辅助与本地组合追踪应用
- 客户端形态：`Flutter` 开发，面向 `iOS`、`Android`，当前支持 `Web` 预览
- 产品边界：
  - 不托管用户资产
  - 不连接真实钱包
  - 不直接执行交易
  - 以公开数据聚合、收益比较、分配建议、提醒与本地记录为主

## 二、文档目录

- 产品需求文档：`doc/prd.md`
- 项目总览：`doc/project_info.md`
- 阶段性方案文档：`doc/phases/`
- 技能文档目录：`doc/skills/`
- 当前 UI 技能文档：`doc/skills/ui.md`

## 三、前端技术栈

- 框架：`Flutter`
- 状态管理：`flutter_riverpod`
- 路由：`go_router`
- 屏幕适配：`flutter_screenutil`
- 字体：`google_fonts`
- 动画：
  - 以 Flutter 原生隐式动画为主
  - 局部可使用 `flutter_animate`
- 图标：`CupertinoIcons`

## 四、当前 UI 方向

- 风格基调：`Playful Minimalism & Quiet Luxury`
- 参考气质：`Aave`、`Phantom`、克制的 DeFi 高级感
- 当前主色：
  - 品牌主色：`#4A5D23`
  - 主色浅阶：`#E4E8DE`
  - 深色背景：`#181A17`
  - 卡片表面：`#222620`
- 强调色：
  - 成功：`#B2E159`
  - 警示：`#D9A05B`
  - 信息：`#5E93A5`

## 五、当前工程结构

- `lib/app/`
  - 应用启动、主题、路由、全局 provider
- `lib/shared/`
  - 设计 token、通用组件、通用 UI 结构
- `lib/features/`
  - 各业务页面与页面级展示代码
- `worker/`
  - Cloudflare 后端工程
- `doc/`
  - 项目文档、PRD、skills、阶段性方案

## 六、当前页面结构

- 主页面：
  - `Home`
  - `Discover`
  - `Allocate`
  - `Portfolio`
  - `Alerts`
- 次级页面：
  - `Settings`

## 七、当前后端方向

- 部署平台：`Cloudflare`
- 当前规划服务：
  - `Workers`
  - `Cron Triggers`
  - `D1`
- 后续可选：
  - `KV`

## 八、当前工程说明

- 当前 App 使用 `MaterialApp` 作为应用外壳
- 页面视觉已脱离默认 Material 风格，采用自定义设计系统
- 图标体系已切换到 `CupertinoIcons`
- 底部导航为自定义 icon-only 结构，并带选中动画
- 当前工程采用主流方案：
  - `Material` 负责底层应用框架
  - 自定义组件负责业务 UI 风格
  - `CupertinoIcons` 提供更贴近目标气质的图标语言

## 九、当前校验状态

- `flutter analyze` 通过
- `flutter test` 通过

