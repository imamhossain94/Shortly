// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Shortly';

  @override
  String get shorten => 'Acortar';

  @override
  String get expand => 'Expandir';

  @override
  String get history => 'Historial';

  @override
  String get shortenLink => 'Acorta tu enlace';

  @override
  String get shortenDesc =>
      'Selecciona un proveedor e ingresa tu URL larga a continuación.';

  @override
  String get expandLink => 'Expande tu enlace';

  @override
  String get expandDesc => 'Revela el destino de las URLs acortadas.';

  @override
  String get enterUrl => 'Por favor ingresa una URL';

  @override
  String get longUrl => 'URL larga';

  @override
  String get shortenedUrl => 'URL acortada';

  @override
  String get provider => 'Proveedor';

  @override
  String get paste => 'Pegar';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get errorShortening => 'Error al acortar la URL. Inténtalo de nuevo.';

  @override
  String get errorExpanding => 'Error al expandir la URL.';

  @override
  String get noHistory => 'Aún no hay historial';

  @override
  String get delete => 'Eliminar';

  @override
  String get original => 'Original';

  @override
  String get expanded => 'Expandido';

  @override
  String get qrCode => 'Código QR';

  @override
  String get settings => 'Ajustes';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get all => 'Todos';

  @override
  String get refresh => 'Actualizar';

  @override
  String get options => 'Opciones';

  @override
  String get close => 'Cerrar';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get english => 'Inglés';

  @override
  String get espanol => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get portuguese => 'Portugués';

  @override
  String get italian => 'Italiano';

  @override
  String get hindi => 'Hindi';

  @override
  String get chinese => 'Chino';

  @override
  String get arabic => 'Árabe';

  @override
  String get searchLinks => 'Buscar enlaces...';

  @override
  String get tellUsMore => 'Cuéntanos más sobre el problema...';

  @override
  String get exampleUrl => 'https://bit.ly/ejemplo';

  @override
  String get shortenedLink => 'Enlace acortado';

  @override
  String get expandedLink => 'Enlace expandido';

  @override
  String get pasteLongUrl => 'Pega tu URL larga';

  @override
  String get shortenNow => 'Acortar ahora';

  @override
  String get recentLinks => 'Enlaces recientes';

  @override
  String get noLinksShortened => 'Aún no hay enlaces acortados';

  @override
  String get expandShortenedLink => 'Expandir enlace acortado';

  @override
  String get expandShortenedLinkDesc =>
      'Revela de forma segura el destino completo detrás de cualquier enlace acortado.';

  @override
  String get expandAndVerify => 'Expandir y verificar';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get pasteShortUrlTitle => 'Pega tu URL corta';

  @override
  String get pasteShortUrlDesc =>
      'Copia cualquier bit.ly, tinyurl u otro enlace acortado.';

  @override
  String get tapExpandVerifyTitle => 'Toca Expandir y verificar';

  @override
  String get tapExpandVerifyDesc =>
      'Seguimos la cadena de redireccionamiento para encontrar el destino.';

  @override
  String get seeFullUrlTitle => 'Ver la URL completa';

  @override
  String get seeFullUrlDesc =>
      'La URL original completa se revela al instante.';

  @override
  String get shortlyPro => 'Shortly Pro';

  @override
  String get active => 'Activo';

  @override
  String get shortlyUser => 'Usuario Premium';

  @override
  String get enjoyingAdFree => 'Disfrutando de una experiencia sin anuncios';

  @override
  String get free => 'Gratis';

  @override
  String get upgradeProDesc =>
      'Actualiza a Pro para eliminar los anuncios y disfrutar de una experiencia perfecta.';

  @override
  String get upgradeNow => 'Actualizar ahora - Eliminar anuncios';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get feedback => 'Comentarios';

  @override
  String get rateApp => 'Calificar aplicación';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get otherApps => 'Otras aplicaciones';

  @override
  String get myLinks => 'Mis enlaces';

  @override
  String linksCount(int count) {
    return '$count Enlaces';
  }

  @override
  String shortenedCount(int count) {
    return '$count Acortados';
  }
}
