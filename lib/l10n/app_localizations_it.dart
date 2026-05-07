// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Shortly';

  @override
  String get shorten => 'Abbrevia';

  @override
  String get expand => 'Espandi';

  @override
  String get history => 'Cronologia';

  @override
  String get shortenLink => 'Abbrevia il tuo link';

  @override
  String get shortenDesc =>
      'Seleziona un provider e inserisci il tuo URL lungo qui sotto.';

  @override
  String get expandLink => 'Espandi il tuo link';

  @override
  String get expandDesc => 'Rivela la destinazione degli URL abbreviati.';

  @override
  String get enterUrl => 'Inserisci un URL';

  @override
  String get longUrl => 'URL lungo';

  @override
  String get shortenedUrl => 'URL abbreviato';

  @override
  String get provider => 'Provider';

  @override
  String get paste => 'Incolla';

  @override
  String get copy => 'Copia';

  @override
  String get share => 'Condividi';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get errorShortening => 'Impossibile abbreviare l\'URL. Riprova.';

  @override
  String get errorExpanding => 'Impossibile espandere l\'URL.';

  @override
  String get noHistory => 'Nessuna cronologia';

  @override
  String get delete => 'Elimina';

  @override
  String get original => 'Originale';

  @override
  String get expanded => 'Espanso';

  @override
  String get qrCode => 'Codice QR';

  @override
  String get settings => 'Impostazioni';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get search => 'Cerca';

  @override
  String get filter => 'Filtra';

  @override
  String get all => 'Tutti';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get options => 'Opzioni';

  @override
  String get close => 'Chiudi';

  @override
  String get shareLink => 'Condividi Link';

  @override
  String get openInBrowser => 'Apri nel Browser';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get english => 'Inglese';

  @override
  String get espanol => 'Spagnolo';

  @override
  String get french => 'Francese';

  @override
  String get german => 'Tedesco';

  @override
  String get portuguese => 'Portoghese';

  @override
  String get italian => 'Italiano';

  @override
  String get hindi => 'Hindi';

  @override
  String get chinese => 'Cinese';

  @override
  String get arabic => 'Arabo';

  @override
  String get searchLinks => 'Cerca link...';

  @override
  String get tellUsMore => 'Dicci di più sul problema...';

  @override
  String get exampleUrl => 'https://bit.ly/esempio';

  @override
  String get shortenedLink => 'Link Abbreviato';

  @override
  String get expandedLink => 'Link Espanso';

  @override
  String get pasteLongUrl => 'Incolla il tuo URL lungo';

  @override
  String get shortenNow => 'Abbrevia Ora';

  @override
  String get recentLinks => 'Link Recenti';

  @override
  String get noLinksShortened => 'Nessun link abbreviato';

  @override
  String get expandShortenedLink => 'Espandi Link Abbreviato';

  @override
  String get expandShortenedLinkDesc =>
      'Rivela in sicurezza l\'intera destinazione dietro qualsiasi link abbreviato.';

  @override
  String get expandAndVerify => 'Espandi e Verifica';

  @override
  String get howItWorks => 'Come funziona';

  @override
  String get pasteShortUrlTitle => 'Incolla il tuo URL corto';

  @override
  String get pasteShortUrlDesc =>
      'Copia qualsiasi link bit.ly, tinyurl o altri link abbreviati.';

  @override
  String get tapExpandVerifyTitle => 'Tocca Espandi e Verifica';

  @override
  String get tapExpandVerifyDesc =>
      'Seguiamo la catena di reindirizzamento per trovare la destinazione.';

  @override
  String get seeFullUrlTitle => 'Vedi l\'URL completo';

  @override
  String get seeFullUrlDesc =>
      'L\'URL originale completo viene rivelato all\'istante.';

  @override
  String get shortlyPro => 'Shortly Pro';

  @override
  String get active => 'Attivo';

  @override
  String get shortlyUser => 'Utente Premium';

  @override
  String get enjoyingAdFree => 'Godendo di un\'esperienza senza pubblicità';

  @override
  String get free => 'Gratis';

  @override
  String get upgradeProDesc =>
      'Passa a Pro per rimuovere gli annunci e goderti un\'esperienza senza interruzioni.';

  @override
  String get upgradeNow => 'Aggiorna Ora - Rimuovi Annunci';

  @override
  String get appearance => 'Aspetto';

  @override
  String get language => 'Lingua';

  @override
  String get feedback => 'Feedback';

  @override
  String get rateApp => 'Valuta App';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get about => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get otherApps => 'Altre App';

  @override
  String get myLinks => 'I Miei Link';

  @override
  String linksCount(int count) {
    return '$count Link';
  }

  @override
  String shortenedCount(int count) {
    return '$count Abbreviati';
  }
}
