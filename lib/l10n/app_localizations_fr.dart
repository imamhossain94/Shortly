// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Shortly';

  @override
  String get shorten => 'Raccourcir';

  @override
  String get expand => 'Développer';

  @override
  String get history => 'Historique';

  @override
  String get shortenLink => 'Raccourcissez votre lien';

  @override
  String get shortenDesc =>
      'Sélectionnez un fournisseur et entrez votre URL longue ci-dessous.';

  @override
  String get expandLink => 'Développez votre lien';

  @override
  String get expandDesc => 'Révélez la destination des URL raccourcies.';

  @override
  String get enterUrl => 'Veuillez entrer une URL';

  @override
  String get longUrl => 'URL longue';

  @override
  String get shortenedUrl => 'URL raccourcie';

  @override
  String get provider => 'Fournisseur';

  @override
  String get paste => 'Coller';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get errorShortening =>
      'Échec du raccourcissement de l\'URL. Veuillez réessayer.';

  @override
  String get errorExpanding => 'Échec du développement de l\'URL.';

  @override
  String get noHistory => 'Aucun historique pour le moment';

  @override
  String get delete => 'Supprimer';

  @override
  String get original => 'Original';

  @override
  String get expanded => 'Développé';

  @override
  String get qrCode => 'Code QR';

  @override
  String get settings => 'Paramètres';

  @override
  String get theme => 'Thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get all => 'Tout';

  @override
  String get refresh => 'Actualiser';

  @override
  String get options => 'Options';

  @override
  String get close => 'Fermer';

  @override
  String get shareLink => 'Partager le lien';

  @override
  String get openInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get english => 'Anglais';

  @override
  String get espanol => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get portuguese => 'Portugais';

  @override
  String get italian => 'Italien';

  @override
  String get hindi => 'Hindi';

  @override
  String get chinese => 'Chinois';

  @override
  String get arabic => 'Arabe';

  @override
  String get searchLinks => 'Rechercher des liens...';

  @override
  String get tellUsMore => 'Dites-nous en plus sur le problème...';

  @override
  String get exampleUrl => 'https://bit.ly/exemple';

  @override
  String get shortenedLink => 'Lien raccourci';

  @override
  String get expandedLink => 'Lien développé';

  @override
  String get pasteLongUrl => 'Collez votre URL longue';

  @override
  String get shortenNow => 'Raccourcir maintenant';

  @override
  String get recentLinks => 'Liens récents';

  @override
  String get noLinksShortened => 'Aucun lien raccourci pour le moment';

  @override
  String get expandShortenedLink => 'Développer le lien raccourci';

  @override
  String get expandShortenedLinkDesc =>
      'Révélez en toute sécurité la destination complète derrière tout lien raccourci.';

  @override
  String get expandAndVerify => 'Développer et vérifier';

  @override
  String get howItWorks => 'Comment ça marche';

  @override
  String get pasteShortUrlTitle => 'Collez votre URL courte';

  @override
  String get pasteShortUrlDesc =>
      'Copiez n\'importe quel lien bit.ly, tinyurl ou autre lien raccourci.';

  @override
  String get tapExpandVerifyTitle => 'Appuyez sur Développer et vérifier';

  @override
  String get tapExpandVerifyDesc =>
      'Nous suivons la chaîne de redirection pour trouver la destination.';

  @override
  String get seeFullUrlTitle => 'Voir l\'URL complète';

  @override
  String get seeFullUrlDesc =>
      'L\'URL d\'origine complète est révélée instantanément.';

  @override
  String get shortlyPro => 'Shortly Pro';

  @override
  String get active => 'Actif';

  @override
  String get shortlyUser => 'Utilisateur Premium';

  @override
  String get enjoyingAdFree => 'Profite d\'une expérience sans publicité';

  @override
  String get free => 'Gratuit';

  @override
  String get upgradeProDesc =>
      'Passez à la version Pro pour supprimer les publicités et profiter d\'une expérience fluide.';

  @override
  String get upgradeNow => 'Mettre à niveau - Supprimer les pubs';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get feedback => 'Commentaires';

  @override
  String get rateApp => 'Évaluer l\'application';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get otherApps => 'Autres applications';

  @override
  String get myLinks => 'Mes liens';

  @override
  String linksCount(int count) {
    return '$count Liens';
  }

  @override
  String shortenedCount(int count) {
    return '$count Raccourcis';
  }
}
