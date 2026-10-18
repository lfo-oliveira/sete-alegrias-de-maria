import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

const _chave = 'terco.indice_atual';

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
  test('sem nada salvo, começa no passo 0', () async {
    final container = await _criar({});
    expect(container.read(tercoControllerProvider).indice, 0);
    expect(container.read(tercoControllerProvider).emAndamento, isFalse);
  });

  test('restaura o passo salvo', () async {
    final container = await _criar({_chave: 12});
    expect(container.read(tercoControllerProvider).indice, 12);
    expect(container.read(tercoControllerProvider).emAndamento, isTrue);
  });

  test('avançar e voltar salvam o novo passo', () async {
    final container = await _criar({});
    final controle = container.read(tercoControllerProvider.notifier);
    final prefs = container.read(sharedPreferencesProvider);

    controle.avancar();
    controle.avancar();
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getInt(_chave), 2);

    controle.voltar();
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getInt(_chave), 1);
  });

  test('reiniciar volta ao início e apaga o salvo', () async {
    final container = await _criar({_chave: 20});
    final prefs = container.read(sharedPreferencesProvider);

    container.read(tercoControllerProvider.notifier).reiniciar();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(tercoControllerProvider).indice, 0);
    expect(prefs.getInt(_chave), isNull);
  });

  test('concluir zera o progresso salvo', () async {
    final container = await _criar({_chave: 99});
    final prefs = container.read(sharedPreferencesProvider);

    container.read(tercoControllerProvider.notifier).concluir();
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getInt(_chave), isNull);
  });

  test('valor salvo fora da lista é ignorado', () async {
    final container = await _criar({_chave: 9999});
    expect(container.read(tercoControllerProvider).indice, 0);
  });
}
