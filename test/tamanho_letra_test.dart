import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/app.dart';
import 'package:sete_alegrias_de_maria/data/models/tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/tamanho_letra_controller.dart';

const _chave = 'config.tamanho_letra';

Future<ProviderContainer> _criar(Map<String, Object> valoresSalvos) async {
  SharedPreferences.setMockInitialValues(valoresSalvos);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('TamanhoLetraController', () {
    test('sem nada salvo, usa o tamanho normal', () async {
      final container = await _criar({});
      expect(container.read(tamanhoLetraProvider), TamanhoLetra.normal);
    });

    test('restaura o tamanho salvo', () async {
      final container = await _criar({_chave: 'extraGrande'});
      expect(container.read(tamanhoLetraProvider), TamanhoLetra.extraGrande);
    });

    test('valor salvo desconhecido volta para normal', () async {
      final container = await _criar({_chave: 'gigante'});
      expect(container.read(tamanhoLetraProvider), TamanhoLetra.normal);
    });

    test('definir muda o tamanho e salva no celular', () async {
      final container = await _criar({});
      final prefs = container.read(sharedPreferencesProvider);

      container.read(tamanhoLetraProvider.notifier).definir(TamanhoLetra.grande);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(tamanhoLetraProvider), TamanhoLetra.grande);
      expect(prefs.getString(_chave), 'grande');
    });
  });

  testWidgets('botão Aa abre o painel e escolher Grande aumenta a letra',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SeteAlegriasApp(),
      ),
    );

    await tester.tap(find.text('Aa'));
    await tester.pumpAndSettle();
    expect(find.text('Tamanho da letra'), findsOneWidget);

    await tester.tap(find.text('Grande'));
    await tester.pumpAndSettle();

    expect(prefs.getString(_chave), 'grande');

    final media = MediaQuery.of(tester.element(find.text('Tamanho da letra')));
    expect(media.textScaler.scale(10), closeTo(13, 0.01));
  });
}
