import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
  ];

  static const _localizedValues = <String, Map<String, String>>{
    'zh': {
      'Stably': 'Stably',
      'Yield Discovery': '收益发现',
      'Allocation': '分配',
      'Portfolio': '组合',
      'Alerts': '提醒',
      'Settings': '设置',
      'Stablecoin': '稳定币',
      'Market Overview': '市场概览',
      'Coverage Snapshot': '覆盖快照',
      'CeFi Snapshot': 'CeFi 快照',
      'Top Yield Pools': '头部收益池',
      'Top Stablecoins': '头部稳定币',
      'Risk Notes': '风险说明',
      'Discovery Overview': '发现概览',
      'Search': '搜索',
      'Top 20 Stablecoins': '前 20 稳定币',
      'Stablecoin Coverage': '稳定币覆盖',
      'Yield Pool Board': '收益池面板',
      'CeFi Board': 'CeFi 面板',
      'Research Notes': '研究说明',
      'Allocation Overview': '分配概览',
      'Scenario Inputs': '场景输入',
      'Suggested Allocation': '建议分配',
      'Plan Notes': '方案说明',
      'Portfolio Overview': '组合概览',
      'Portfolio Snapshot': '组合快照',
      'Tracked Positions': '已跟踪持仓',
      'Portfolio Notes': '组合说明',
      'Alerts Overview': '提醒概览',
      'Alerts Snapshot': '提醒快照',
      'Alert Rules': '提醒规则',
      'Alert Notes': '提醒说明',
      'Product tone': '产品定位',
      'Appearance': '外观',
      'Language': '语言',
      'Data scope': '数据范围',
      'Data status': '数据状态',
      'Compliance': '合规说明',
      'Core Profile': '核心资料',
      'Circulating USD Trend': '流通规模趋势',
      'Chain Coverage': '链覆盖',
      'Related Yield Pools': '相关收益池',
      'Project Details': '项目资料',
      'Current sources': '当前数据源',
      'Last successful updates': '最近成功更新时间',
      'Theme mode': '主题模式',
      'Tracked coverage': '跟踪范围',
      'Stablecoins': '稳定币',
      'DeFi pools': 'DeFi 池子',
      'CeFi board': 'CeFi 面板',
      'Dark': '深色',
      'Light': '浅色',
      'Current scope': '当前范围',
      'Add': '新增',
      'Clear': '清空',
      'Add position': '新增持仓',
      'Add rule': '新增规则',
      'Edit': '编辑',
      'Delete': '删除',
      'Cancel': '取消',
      'Save': '保存',
      'Update': '更新',
      'Enable': '启用',
      'Pause': '暂停',
      'Refresh': '刷新',
      'Retry': '重试',
      'Open discovery': '打开发现页',
      'Open {symbol}': '打开 {symbol}',
      'Top 20': '前 20',
      'No data': '无数据',
      'Fiat-backed': '法币抵押',
      'Yield pools': '收益池',
      'Circulating USD': '流通美元',
      'Last sync': '最近同步',
      'Ready': '已就绪',
      'CeFi offers': 'CeFi 产品',
      'Top CeFi APY': '最高 CeFi 年化',
      'Detail': '详情',
      'Allocate': '分配',
      'No tracked positions yet': '还没有已跟踪持仓',
      'No alert rules yet': '还没有提醒规则',
      'No allocation plan yet': '当前没有可用分配方案',
      'No yield pools yet': '当前没有收益池',
      'No stablecoins yet': '当前没有稳定币',
      'No CeFi products yet': '当前没有 CeFi 产品',
      'No related yield pools': '当前没有相关收益池',
      'Tracked positions cleared.': '已清空已跟踪持仓。',
      'Alert rules cleared.': '已清空提醒规则。',
      'Position saved.': '持仓已保存。',
      'Position updated.': '持仓已更新。',
      'Position deleted.': '持仓已删除。',
      'Alert rule saved.': '提醒规则已保存。',
      'Alert rule updated.': '提醒规则已更新。',
      'Alert rule deleted.': '提醒规则已删除。',
      'Alert rule enabled.': '提醒规则已启用。',
      'Alert rule paused.': '提醒规则已暂停。',
      'Clear tracked positions': '清空已跟踪持仓',
      'Remove all locally tracked positions from this device?': '要从当前设备移除所有本地持仓记录吗？',
      'Clear all': '全部清空',
      'Delete position': '删除持仓',
      'Delete alert rule': '删除提醒规则',
      'The current product scope is intentionally narrow and data-led.': '当前产品范围刻意保持收敛，并以数据驱动为主。',
      'Switch between warm daylight and quiet luxury dark mode.': '在浅色模式与深色模式之间切换。',
      'DefiLlama coverage is limited to the current top 20 stablecoins by circulating USD. Related DeFi pools are filtered to that same market set.': 'DefiLlama 数据当前只覆盖按流通美元排序的前 20 个稳定币，相关 DeFi 池子也只保留这组市场范围内的数据。',
      'CeFi rates currently come from Binance and OKX only, and the app shows six core fields for each offer.': 'CeFi 收益当前只来自 Binance 和 OKX，列表只展示 6 个核心字段。',
      'DefiLlama for top-20 stablecoins and related DeFi pools. Binance and OKX for CeFi rates.': 'DefiLlama 用于前 20 稳定币及相关 DeFi 池子，Binance 和 OKX 用于 CeFi 收益。',
      'Stably aggregates public data and local simulations only. It does not execute trades, custody assets, or provide investment advice.': 'Stably 只聚合公开数据和本地模拟，不执行交易、不托管资产，也不提供投资建议。',
      'Not synced yet': '尚未同步',
      'Weighted from the tracked position mix.': '按当前跟踪组合的权重计算。',
      'Locally saved entries.': '本地保存的记录。',
      'Estimated annual carry': '预估年度收益',
      'Directional estimate using the current APY tied to each tracked position.': '基于当前 APY 与持仓匹配的方向性估算。',
      'Local': '本地',
      'Portfolio fields': '组合字段',
      'Tracked capital': '已跟踪资金',
      'Highest APY': '最高 APY',
      'Balances are manually recorded': '余额为手动记录',
      'The app does not read exchange accounts or on-chain wallets in this version.': '当前版本不会读取交易所账户或链上钱包。',
      'Projected carry is directional': '收益预估只供参考',
      'Actual outcomes depend on changing rates, reward mechanics, and real user actions.': '实际结果取决于利率变动、奖励机制和用户的真实操作。',
      'Manual APY': '手动 APY',
      'Live APY': '实时 APY',
      'Store a local position for a stablecoin, platform, and chain. Current market matches can be used to prefill the form.': '记录一条本地持仓。可使用当前市场匹配项来预填表单。',
      'Market matches': '市场匹配',
      'Platform': '平台',
      'Chain': '链',
      'Amount': '金额',
      'Stored APY': '记录 APY',
      'Note': '备注',
      'Optional memo': '可选备注',
      'Required': '必填',
      'Enter a value greater than 0': '请输入大于 0 的数值',
      'Enter a valid APY': '请输入有效 APY',
      'Alerts suggest review, not action': '提醒用于复查，不用于执行',
      'The product surfaces information but does not execute transfers or recommendations.': '产品只提供信息，不会执行转移或给出建议。',
      'Short-lived promos may expire before action': '短期活动可能在操作前结束',
      'Final availability should always be verified on the destination platform.': '最终可用性应以目标平台的官方信息为准。',
      'Tracked yield pools': '已跟踪收益池',
      'Alert rules': '提醒规则',
      'Current market lead': '当前市场领先',
      'Current': '当前',
      'Price': '价格',
      'Peg mechanism': '锚定机制',
      'Price source': '价格来源',
      'Gecko ID': 'Gecko ID',
      'Unknown': '未知',
      'All chains': '所有链',
      'Focused': '已聚焦',
      'Focused chain': '已聚焦链',
      'Focus chain': '聚焦该链',
      'There are no tracked top-20 stablecoin pools for this symbol right now.': '当前没有与该稳定币相关的前 20 收益池。',
      'There are no tracked top-20 stablecoin pools for this symbol on {chain} right now.': '当前在 {chain} 上没有与该稳定币相关的前 20 收益池。',
      'Search top 20 stablecoins, pools, CeFi, or chains': '搜索前 20 稳定币、收益池、CeFi 或链',
      'Top APY': '最高 APY',
      'Baseline pool': '基准池',
      'Flexible offers': '活期产品',
      'CeFi is limited to Binance and OKX': 'CeFi 当前仅限 Binance 和 OKX',
      'The CeFi board currently tracks six core fields from Binance and OKX only.': 'CeFi 面板当前只跟踪 Binance 和 OKX 的 6 个核心字段。',
      'DeFi is filtered to the top 20 stablecoins': 'DeFi 已过滤为前 20 稳定币',
      'DefiLlama pools outside the current top 20 stablecoin set are intentionally excluded from discovery.': '当前前 20 稳定币集合之外的 DefiLlama 池子会被刻意排除在发现页之外。',
      'Run a backend sync to populate the current top 20 stablecoin board.': '请先执行一次后端同步以填充当前前 20 稳定币面板。',
      'Run a backend sync, then refresh to load the current pool board.': '请先执行一次后端同步，然后刷新以加载当前收益池面板。',
      'Run a backend sync, then refresh to populate the stablecoin board.': '请先执行一次后端同步，然后刷新以填充稳定币面板。',
    },
  };

  String tr(String key, [Map<String, String> params = const {}]) {
    final languageCode = locale.languageCode;
    final base = _localizedValues[languageCode]?[key] ?? key;

    var resolved = base;
    for (final entry in params.entries) {
      resolved = resolved.replaceAll('{${entry.key}}', entry.value);
    }
    return resolved;
  }

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale('en'));
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (item) => item.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String key, [Map<String, String> params = const {}]) =>
      l10n.tr(key, params);
}
