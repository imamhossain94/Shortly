import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Shortly'**
  String get appName;

  /// No description provided for @shorten.
  ///
  /// In en, this message translates to:
  /// **'Shorten'**
  String get shorten;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @shortenLink.
  ///
  /// In en, this message translates to:
  /// **'Shorten your link'**
  String get shortenLink;

  /// No description provided for @shortenDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a provider and enter your long URL below.'**
  String get shortenDesc;

  /// No description provided for @expandLink.
  ///
  /// In en, this message translates to:
  /// **'Expand your link'**
  String get expandLink;

  /// No description provided for @expandDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveal the destination of shortened URLs.'**
  String get expandDesc;

  /// No description provided for @enterUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL'**
  String get enterUrl;

  /// No description provided for @longUrl.
  ///
  /// In en, this message translates to:
  /// **'Long URL'**
  String get longUrl;

  /// No description provided for @shortenedUrl.
  ///
  /// In en, this message translates to:
  /// **'Shortened URL'**
  String get shortenedUrl;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @errorShortening.
  ///
  /// In en, this message translates to:
  /// **'Failed to shorten URL. Please try again.'**
  String get errorShortening;

  /// No description provided for @errorExpanding.
  ///
  /// In en, this message translates to:
  /// **'Failed to expand URL.'**
  String get errorExpanding;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @expanded.
  ///
  /// In en, this message translates to:
  /// **'Expanded'**
  String get expanded;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @espanol.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get espanol;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @searchLinks.
  ///
  /// In en, this message translates to:
  /// **'Search links...'**
  String get searchLinks;

  /// No description provided for @tellUsMore.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about the issue...'**
  String get tellUsMore;

  /// No description provided for @exampleUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bit.ly/example'**
  String get exampleUrl;

  /// No description provided for @shortenedLink.
  ///
  /// In en, this message translates to:
  /// **'Shortened Link'**
  String get shortenedLink;

  /// No description provided for @expandedLink.
  ///
  /// In en, this message translates to:
  /// **'Expanded Link'**
  String get expandedLink;

  /// No description provided for @pasteLongUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste your long URL'**
  String get pasteLongUrl;

  /// No description provided for @shortenNow.
  ///
  /// In en, this message translates to:
  /// **'Shorten Now'**
  String get shortenNow;

  /// No description provided for @recentLinks.
  ///
  /// In en, this message translates to:
  /// **'Recent Links'**
  String get recentLinks;

  /// No description provided for @noLinksShortened.
  ///
  /// In en, this message translates to:
  /// **'No links shortened yet'**
  String get noLinksShortened;

  /// No description provided for @expandShortenedLink.
  ///
  /// In en, this message translates to:
  /// **'Expand Shortened Link'**
  String get expandShortenedLink;

  /// No description provided for @expandShortenedLinkDesc.
  ///
  /// In en, this message translates to:
  /// **'Safely reveal the full destination behind any shortened link.'**
  String get expandShortenedLinkDesc;

  /// No description provided for @expandAndVerify.
  ///
  /// In en, this message translates to:
  /// **'Expand & Verify'**
  String get expandAndVerify;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @pasteShortUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste your short URL'**
  String get pasteShortUrlTitle;

  /// No description provided for @pasteShortUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy any bit.ly, tinyurl, or other shortened link.'**
  String get pasteShortUrlDesc;

  /// No description provided for @tapExpandVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Expand & Verify'**
  String get tapExpandVerifyTitle;

  /// No description provided for @tapExpandVerifyDesc.
  ///
  /// In en, this message translates to:
  /// **'We follow the redirect chain to find the destination.'**
  String get tapExpandVerifyDesc;

  /// No description provided for @seeFullUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'See the full URL'**
  String get seeFullUrlTitle;

  /// No description provided for @seeFullUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'The complete original URL is revealed instantly.'**
  String get seeFullUrlDesc;

  /// No description provided for @shortlyPro.
  ///
  /// In en, this message translates to:
  /// **'Shortly Pro'**
  String get shortlyPro;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @shortlyUser.
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get shortlyUser;

  /// No description provided for @enjoyingAdFree.
  ///
  /// In en, this message translates to:
  /// **'Enjoying ad-free experience'**
  String get enjoyingAdFree;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @upgradeProDesc.
  ///
  /// In en, this message translates to:
  /// **'Upgrade pro to remove ads, enjoy seamless experience.'**
  String get upgradeProDesc;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now – Remove Ads'**
  String get upgradeNow;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @otherApps.
  ///
  /// In en, this message translates to:
  /// **'Other Apps'**
  String get otherApps;

  /// No description provided for @myLinks.
  ///
  /// In en, this message translates to:
  /// **'My Links'**
  String get myLinks;

  /// No description provided for @linksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Links'**
  String linksCount(int count);

  /// No description provided for @shortenedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Shortened'**
  String shortenedCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
