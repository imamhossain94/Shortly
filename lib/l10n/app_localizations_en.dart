// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Shortly';

  @override
  String get shorten => 'Shorten';

  @override
  String get expand => 'Expand';

  @override
  String get history => 'History';

  @override
  String get shortenLink => 'Shorten your link';

  @override
  String get shortenDesc => 'Select a provider and enter your long URL below.';

  @override
  String get expandLink => 'Expand your link';

  @override
  String get expandDesc => 'Reveal the destination of shortened URLs.';

  @override
  String get enterUrl => 'Please enter a URL';

  @override
  String get longUrl => 'Long URL';

  @override
  String get shortenedUrl => 'Shortened URL';

  @override
  String get provider => 'Provider';

  @override
  String get paste => 'Paste';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get errorShortening => 'Failed to shorten URL. Please try again.';

  @override
  String get errorExpanding => 'Failed to expand URL.';

  @override
  String get noHistory => 'No history yet';

  @override
  String get delete => 'Delete';

  @override
  String get original => 'Original';

  @override
  String get expanded => 'Expanded';

  @override
  String get qrCode => 'QR Code';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get refresh => 'Refresh';

  @override
  String get options => 'Options';

  @override
  String get close => 'Close';
}
