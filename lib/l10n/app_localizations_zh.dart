// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Shortly';

  @override
  String get shorten => '缩短';

  @override
  String get expand => '还原';

  @override
  String get history => '历史';

  @override
  String get shortenLink => '缩短您的链接';

  @override
  String get shortenDesc => '选择一个提供商并在下方输入您的长网址。';

  @override
  String get expandLink => '还原您的链接';

  @override
  String get expandDesc => '揭示缩短网址的目的地。';

  @override
  String get enterUrl => '请输入网址';

  @override
  String get longUrl => '长网址';

  @override
  String get shortenedUrl => '短网址';

  @override
  String get provider => '提供商';

  @override
  String get paste => '粘贴';

  @override
  String get copy => '复制';

  @override
  String get share => '分享';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get errorShortening => '缩短网址失败。请重试。';

  @override
  String get errorExpanding => '还原网址失败。';

  @override
  String get noHistory => '暂无历史';

  @override
  String get delete => '删除';

  @override
  String get original => '原网址';

  @override
  String get expanded => '已还原';

  @override
  String get qrCode => '二维码';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get system => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get search => '搜索';

  @override
  String get filter => '筛选';

  @override
  String get all => '全部';

  @override
  String get refresh => '刷新';

  @override
  String get options => '选项';

  @override
  String get close => '关闭';

  @override
  String get shareLink => '分享链接';

  @override
  String get openInBrowser => '在浏览器中打开';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get english => '英语';

  @override
  String get espanol => '西班牙语';

  @override
  String get french => '法语';

  @override
  String get german => '德语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get italian => '意大利语';

  @override
  String get hindi => '印地语';

  @override
  String get chinese => '中文';

  @override
  String get arabic => '阿拉伯语';

  @override
  String get searchLinks => '搜索链接...';

  @override
  String get tellUsMore => '告诉我们更多关于这个问题...';

  @override
  String get exampleUrl => 'https://bit.ly/示例';

  @override
  String get shortenedLink => '缩短的链接';

  @override
  String get expandedLink => '还原的链接';

  @override
  String get pasteLongUrl => '粘贴您的长网址';

  @override
  String get shortenNow => '立即缩短';

  @override
  String get recentLinks => '最近的链接';

  @override
  String get noLinksShortened => '暂无缩短的链接';

  @override
  String get expandShortenedLink => '还原短链接';

  @override
  String get expandShortenedLinkDesc => '安全地揭示任何短链接背后的完整目的地。';

  @override
  String get expandAndVerify => '还原与验证';

  @override
  String get howItWorks => '运作方式';

  @override
  String get pasteShortUrlTitle => '粘贴您的短网址';

  @override
  String get pasteShortUrlDesc => '复制任何 bit.ly、tinyurl 或其他短链接。';

  @override
  String get tapExpandVerifyTitle => '点击还原与验证';

  @override
  String get tapExpandVerifyDesc => '我们遵循重定向链来找到目的地。';

  @override
  String get seeFullUrlTitle => '查看完整网址';

  @override
  String get seeFullUrlDesc => '完整的原始网址将立即显现。';

  @override
  String get shortlyPro => 'Shortly Pro';

  @override
  String get active => '已激活';

  @override
  String get shortlyUser => 'Shortly 用户';

  @override
  String get enjoyingAdFree => '享受无广告体验';

  @override
  String get free => '免费';

  @override
  String get upgradeProDesc => '升级到 Pro 版本以移除广告并享受无缝体验。';

  @override
  String get upgradeNow => '立即升级 - 移除广告';

  @override
  String get appearance => '外观';

  @override
  String get language => '语言';

  @override
  String get feedback => '反馈';

  @override
  String get rateApp => '评价应用';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get otherApps => '其他应用';

  @override
  String get myLinks => '我的链接';

  @override
  String linksCount(int count) {
    return '$count 个链接';
  }

  @override
  String shortenedCount(int count) {
    return '$count 个已缩短';
  }
}
