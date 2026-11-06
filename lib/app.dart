import 'package:flutter/material.dart';
import 'package:sete_alegrias_de_maria/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/theme/app_theme.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/modo_tema_controller.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/tamanho_letra_controller.dart';
import 'package:sete_alegrias_de_maria/features/home/home_page.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/presentation/lembretes_inicializador.dart';

class SeteAlegriasApp extends ConsumerWidget {
  const SeteAlegriasApp({super.key});

  /// Maior escala de letra aplicada (sistema x escolha do fiel).
  static const escalaMaxima = 2.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fator = ref.watch(tamanhoLetraProvider).fator;
    final modoTema = ref.watch(modoTemaProvider); // <-- 2. Adicione esta linha aqui

    return MaterialApp(
      title: 'Sete Alegrias de Nossa Senhora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.escuro,
      // darkTheme: AppTheme.escuro,
      themeMode: modoTema,
      // Textos prontos do Flutter e do aplicativo (gerados via l10n)
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Aplica o tamanho de letra escolhido a TODAS as telas.
      // Multiplica pela escala do próprio celular, então quem já aumentou a
      // letra nas configurações do Android/iPhone continua bem servido.
      // Limite: acima de [escalaMaxima] as telas não cabem mais no celular.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final escalaDoSistema = media.textScaler.scale(1.0);
        final escala = (escalaDoSistema * fator).clamp(0.0, escalaMaxima);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        );
      },
      home: const LembretesInicializador(child: HomePage()),
    );
  }
}
