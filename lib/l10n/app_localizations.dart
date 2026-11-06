import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
  ];

  String get tituloApp;
  String get subtituloApp;
  String get rezarTerco;
  String get continuarOndeParei;
  String get comecarDeNovo;
  String get parouNasOracoes;
  String parouNaAlegria(int alegria);
  String get dialogRecomecarTitulo;
  String get dialogRecomecarConteudo;
  String get cancelar;
  String get recomecar;
  String get voltar;
  String get proxima;
  String get concluir;
  String get tercoConcluidoMensagem;
  String erroCarregarOracoes(String erro);
  String aveMariaContador(int atual, int total);
  String get ouvir;
  String get pausar;
  String get avancoAutomatico;
  String get erroTocarAudio;
  String velocidadeAudio(String velocidade);
  String get lembretes;
  String get backup;
  String get tamanhoLetra;
  String get temaDoApp;
  String get temaClaro;
  String get temaEscuro;
  String get temaSistema;
  String get vibracaoAtivada;
  String get vibracaoDesativada;
  String get tercosRezados;
  String get diasSeguidos;
  String get estaSemana;
  String get compartilhar;
  String get fechar;
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
  bool isSupported(Locale locale) => <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'pt':
    default:
      return AppLocalizationsPt();
  }
}
