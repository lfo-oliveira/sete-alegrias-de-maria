import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// Título principal do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'Sete Alegrias de Nossa Senhora'**
  String get tituloApp;

  /// Subtítulo do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'Terço da Coroa Franciscana'**
  String get subtituloApp;

  /// No description provided for @rezarTerco.
  ///
  /// In pt, this message translates to:
  /// **'Rezar o terço'**
  String get rezarTerco;

  /// No description provided for @continuarOndeParei.
  ///
  /// In pt, this message translates to:
  /// **'Continuar de onde parei'**
  String get continuarOndeParei;

  /// No description provided for @comecarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Começar de novo'**
  String get comecarDeNovo;

  /// No description provided for @parouNasOracoes.
  ///
  /// In pt, this message translates to:
  /// **'Você parou nas orações.'**
  String get parouNasOracoes;

  /// Mensagem informando em qual alegria o fiel parou
  ///
  /// In pt, this message translates to:
  /// **'Você parou na {alegria}ª alegria.'**
  String parouNaAlegria(int alegria);

  /// No description provided for @dialogRecomecarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Recomeçar o terço?'**
  String get dialogRecomecarTitulo;

  /// No description provided for @dialogRecomecarConteudo.
  ///
  /// In pt, this message translates to:
  /// **'O progresso salvo até aqui será apagado e você voltará ao início.'**
  String get dialogRecomecarConteudo;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @recomecar.
  ///
  /// In pt, this message translates to:
  /// **'Recomeçar'**
  String get recomecar;

  /// No description provided for @voltar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get voltar;

  /// No description provided for @proxima.
  ///
  /// In pt, this message translates to:
  /// **'Próxima'**
  String get proxima;

  /// No description provided for @concluir.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get concluir;

  /// No description provided for @tercoConcluidoMensagem.
  ///
  /// In pt, this message translates to:
  /// **'Terço concluído. Deus te abençoe! 🙏'**
  String get tercoConcluidoMensagem;

  /// No description provided for @erroCarregarOracoes.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as orações.\n{erro}'**
  String erroCarregarOracoes(String erro);

  /// No description provided for @aveMariaContador.
  ///
  /// In pt, this message translates to:
  /// **'Ave-Maria {atual} de {total}'**
  String aveMariaContador(int atual, int total);

  /// No description provided for @ouvir.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir'**
  String get ouvir;

  /// No description provided for @pausar.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get pausar;

  /// No description provided for @avancoAutomatico.
  ///
  /// In pt, this message translates to:
  /// **'Avanço automático'**
  String get avancoAutomatico;

  /// No description provided for @erroTocarAudio.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível tocar este áudio.'**
  String get erroTocarAudio;

  /// No description provided for @velocidadeAudio.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade do áudio: {velocidade}'**
  String velocidadeAudio(String velocidade);

  /// No description provided for @lembretes.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get lembretes;

  /// No description provided for @backup.
  ///
  /// In pt, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @tamanhoLetra.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da letra'**
  String get tamanhoLetra;

  /// No description provided for @temaDoApp.
  ///
  /// In pt, this message translates to:
  /// **'Tema do aplicativo'**
  String get temaDoApp;

  /// No description provided for @temaClaro.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get temaClaro;

  /// No description provided for @temaEscuro.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get temaEscuro;

  /// No description provided for @temaSistema.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get temaSistema;

  /// No description provided for @vibracaoAtivada.
  ///
  /// In pt, this message translates to:
  /// **'Vibração ativada'**
  String get vibracaoAtivada;

  /// No description provided for @vibracaoDesativada.
  ///
  /// In pt, this message translates to:
  /// **'Vibração desativada'**
  String get vibracaoDesativada;

  /// No description provided for @tercosRezados.
  ///
  /// In pt, this message translates to:
  /// **'Terços rezados'**
  String get tercosRezados;

  /// No description provided for @diasSeguidos.
  ///
  /// In pt, this message translates to:
  /// **'Dias seguidos'**
  String get diasSeguidos;

  /// No description provided for @estaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get estaSemana;

  /// No description provided for @compartilhar.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get compartilhar;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @confirmar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirmar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
