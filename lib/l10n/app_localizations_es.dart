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
}
