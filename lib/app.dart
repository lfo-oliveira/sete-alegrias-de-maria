import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/theme/app_theme.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/tamanho_letra_controller.dart';
import 'package:sete_alegrias_de_maria/features/home/home_page.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/presentation/lembretes_inicializador.dart';

class SeteAlegriasApp extends ConsumerWidget {
  const SeteAlegriasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fator = ref.watch(tamanhoLetraProvider).fator;

    return MaterialApp(
      title: 'Sete Alegrias de Maria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.escuro,
      themeMode: ThemeMode.system,
      // Aplica o tamanho de letra escolhido a TODAS as telas.
      // Multiplica pela escala do próprio celular, então quem já aumentou a
      // letra nas configurações do Android/iPhone continua bem servido.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final escalaDoSistema = media.textScaler.scale(1.0);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(escalaDoSistema * fator),
          ),
          child: child!,
        );
      },
      home: const LembretesInicializador(child: HomePage()),
    );
  }
}
