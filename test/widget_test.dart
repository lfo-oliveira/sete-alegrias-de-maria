import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/app.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';

import 'helpers/agendador_falso.dart';

Future<Widget> _montarApp(Map<String, Object> valoresSalvos) async {
  SharedPreferences.setMockInitialValues(valoresSalvos);
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      agendadorLembretesProvider.overrideWithValue(AgendadorFalso()),
    ],
    child: const SeteAlegriasApp(),
  );
}

void main() {
  testWidgets('sem progresso salvo mostra o botão Rezar o terço',
      (tester) async {
    await tester.pumpWidget(await _montarApp({}));

    expect(find.text('Rezar o terço'), findsOneWidget);
    expect(find.text('Continuar de onde parei'), findsNothing);
  });

  testWidgets('com progresso salvo mostra Continuar e Começar de novo',
      (tester) async {
    await tester.pumpWidget(await _montarApp({'terco.indice_atual': 5}));

    expect(find.text('Continuar de onde parei'), findsOneWidget);
    expect(find.text('Começar de novo'), findsOneWidget);
    expect(find.text('Rezar o terço'), findsNothing);
  });

  testWidgets('Começar de novo pede confirmação; Cancelar mantém o lugar',
      (tester) async {
    await tester.pumpWidget(await _montarApp({'terco.indice_atual': 5}));

    await tester.tap(find.text('Começar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Começar de novo?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Continuar de onde parei'), findsOneWidget);
  });
}
