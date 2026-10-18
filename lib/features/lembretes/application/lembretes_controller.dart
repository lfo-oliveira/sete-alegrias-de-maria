import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/lembretes_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_padrao.dart';

class LembretesState {
  const LembretesState({required this.lembretes, this.permissaoNegada = false});

  final List<Lembrete> lembretes;

  /// O fiel não permitiu notificações no celular.
  final bool permissaoNegada;

  LembretesState copyWith({
    List<Lembrete>? lembretes,
    bool? permissaoNegada,
  }) =>
      LembretesState(
        lembretes: lembretes ?? this.lembretes,
        permissaoNegada: permissaoNegada ?? this.permissaoNegada,
      );
}

class LembretesController extends Notifier<LembretesState> {
  LembretesRepository get _repo => ref.read(lembretesRepositoryProvider);
  AgendadorLembretes get _agendador => ref.read(agendadorLembretesProvider);

  @override
  LembretesState build() {
    return LembretesState(
      lembretes: [
        for (final l in LembretesPadrao.todos)
          l.copyWith(ativo: _repo.lerAtivo(l.id)),
      ],
    );
  }

  /// Liga ou desliga um lembrete e atualiza o que está agendado.
  Future<void> alternar(int id, bool ativo) async {
    await _repo.salvarAtivo(id, ativo);
    state = state.copyWith(
      lembretes: [
        for (final l in state.lembretes)
          l.id == id ? l.copyWith(ativo: ativo) : l,
      ],
    );
    await sincronizar();
  }

  /// Deixa o agendamento do celular igual ao que está ligado na tela.
  /// Chamado ao abrir o app e sempre que algo muda.
  Future<void> sincronizar() async {
    final temAtivo = state.lembretes.any((l) => l.ativo);

    if (!temAtivo) {
      await _agendador.substituirAgenda(const []);
      return;
    }

    final permitido = await _agendador.pedirPermissao();
    state = state.copyWith(permissaoNegada: !permitido);

    final agora = ref.read(relogioProvider)();
    await _agendador.substituirAgenda(
      permitido ? calcularAgenda(state.lembretes, agora) : const [],
    );
  }
}

final lembretesProvider =
    NotifierProvider<LembretesController, LembretesState>(
  LembretesController.new,
);
