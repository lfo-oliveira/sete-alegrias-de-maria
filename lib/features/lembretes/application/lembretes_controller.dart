import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/lembretes_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_padrao.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_terco.dart';

class LembretesState {
  const LembretesState({
    required this.lembretes,
    this.personalizados = const [],
    this.permissaoNegada = false,
  });

  /// Lembretes fixos do app (Hora da Ave-Maria).
  final List<Lembrete> lembretes;

  /// Lembretes do terço criados pelo fiel.
  final List<Lembrete> personalizados;

  /// O fiel não permitiu notificações no celular.
  final bool permissaoNegada;

  List<Lembrete> get todos => [...lembretes, ...personalizados];

  LembretesState copyWith({
    List<Lembrete>? lembretes,
    List<Lembrete>? personalizados,
    bool? permissaoNegada,
  }) =>
      LembretesState(
        lembretes: lembretes ?? this.lembretes,
        personalizados: personalizados ?? this.personalizados,
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
      personalizados: _repo.lerPersonalizados(),
    );
  }

  /// Liga ou desliga um lembrete (fixo ou criado pelo fiel).
  Future<void> alternar(int id, bool ativo) async {
    final personalizado = state.personalizados.any((l) => l.id == id);
    if (personalizado) {
      await _guardarPersonalizados([
        for (final l in state.personalizados)
          l.id == id ? l.copyWith(ativo: ativo) : l,
      ]);
    } else {
      await _repo.salvarAtivo(id, ativo);
      state = state.copyWith(
        lembretes: [
          for (final l in state.lembretes)
            l.id == id ? l.copyWith(ativo: ativo) : l,
        ],
      );
    }
    // Ligar é um gesto do fiel: aí vale perguntar de novo pela permissão.
    await sincronizar(pedirPermissao: ativo);
  }

  /// Cria um lembrete do terço no horário e nos dias escolhidos.
  Future<void> adicionar({
    required int hora,
    required int minuto,
    required Set<int> dias,
  }) async {
    final maior = state.personalizados.fold<int>(
      primeiroIdPersonalizado - 1,
      (m, l) => l.id > m ? l.id : m,
    );
    final novo = LembretesTerco.criar(
      id: maior + 1,
      hora: hora,
      minuto: minuto,
      dias: dias,
    );
    await _guardarPersonalizados([...state.personalizados, novo]);
    await sincronizar(pedirPermissao: true);
  }

  /// Muda horário e dias de um lembrete criado pelo fiel.
  /// Editar também liga o lembrete de novo.
  Future<void> editar(
    int id, {
    required int hora,
    required int minuto,
    required Set<int> dias,
  }) async {
    await _guardarPersonalizados([
      for (final l in state.personalizados)
        l.id == id
            ? LembretesTerco.criar(
                id: id,
                hora: hora,
                minuto: minuto,
                dias: dias,
              )
            : l,
    ]);
    await sincronizar(pedirPermissao: true);
  }

  Future<void> remover(int id) async {
    await _guardarPersonalizados([
      for (final l in state.personalizados)
        if (l.id != id) l,
    ]);
    await sincronizar();
  }

  Future<void> _guardarPersonalizados(List<Lembrete> lista) async {
    await _repo.salvarPersonalizados(lista);
    state = state.copyWith(personalizados: lista);
  }

  /// Deixa o agendamento do celular igual ao que está ligado na tela.
  /// Chamado ao abrir o app e sempre que algo muda.
  ///
  /// A permissão só é PEDIDA na primeira vez ou quando [pedirPermissao] é
  /// true (o fiel ligou ou criou um lembrete). Nas outras vezes (ex.: ao
  /// voltar para o app) só é conferida, para não insistir com quem negou.
  Future<void> sincronizar({bool pedirPermissao = false}) async {
    final temAtivo = state.todos.any((l) => l.ativo);

    if (!temAtivo) {
      await _agendador.substituirAgenda(const []);
      return;
    }

    final bool permitido;
    if (pedirPermissao || !_repo.permissaoJaPedida()) {
      // Marca antes: o próprio diálogo de permissão faz o app "voltar" e
      // sincronizar de novo, e isso não pode virar um segundo pedido.
      await _repo.marcarPermissaoPedida();
      permitido = await _agendador.pedirPermissao();
    } else {
      permitido = await _agendador.permissaoConcedida();
    }
    state = state.copyWith(permissaoNegada: !permitido);

    final agora = ref.read(relogioProvider)();
    await _agendador.substituirAgenda(
      permitido ? calcularAgenda(state.todos, agora) : const [],
    );
  }
}

final lembretesProvider = NotifierProvider<LembretesController, LembretesState>(
  LembretesController.new,
);
