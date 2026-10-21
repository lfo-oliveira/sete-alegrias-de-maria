import 'package:flutter/material.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/dias_semana.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';

/// O que o fiel decidiu na tela de edição.
class ResultadoEditor {
  const ResultadoEditor.salvar({
    required this.hora,
    required this.minuto,
    required this.dias,
  }) : excluir = false;

  const ResultadoEditor.excluir()
      : hora = 0,
        minuto = 0,
        dias = const {},
        excluir = true;

  final int hora;
  final int minuto;
  final Set<int> dias;
  final bool excluir;
}

/// Abre a folha para criar ([atual] nulo) ou editar um lembrete do terço.
Future<ResultadoEditor?> mostrarEditorLembrete(
  BuildContext context, {
  Lembrete? atual,
}) {
  return showModalBottomSheet<ResultadoEditor>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _Editor(atual: atual),
  );
}

class _Editor extends StatefulWidget {
  const _Editor({this.atual});

  final Lembrete? atual;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late TimeOfDay _horario;
  late Set<int> _dias;

  @override
  void initState() {
    super.initState();
    final atual = widget.atual;
    _horario = atual == null
        ? const TimeOfDay(hour: 20, minute: 0)
        : TimeOfDay(hour: atual.hora, minute: atual.minuto);
    _dias = {...(atual?.dias ?? todosOsDias)};
  }

  Future<void> _escolherHorario() async {
    final escolhido = await showTimePicker(
      context: context,
      initialTime: _horario,
      helpText: 'Que horas você quer rezar o terço?',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (escolhido != null) setState(() => _horario = escolhido);
  }

  String get _horarioTexto =>
      '${_horario.hour.toString().padLeft(2, '0')}:'
      '${_horario.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final editando = widget.atual != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editando ? 'Editar lembrete do terço' : 'Novo lembrete do terço',
              style: tema.titleLarge,
            ),
            const SizedBox(height: 20),
            Text('Horário', style: tema.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _escolherHorario,
              icon: const Icon(Icons.access_time),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_horarioTexto, style: tema.headlineSmall),
              ),
            ),
            const SizedBox(height: 20),
            Text('Dias da semana', style: tema.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final dia in diasNaOrdemDoCalendario)
                  FilterChip(
                    label: Text(abreviacaoDoDia(dia)),
                    selected: _dias.contains(dia),
                    onSelected: (marcado) => setState(() {
                      marcado ? _dias.add(dia) : _dias.remove(dia);
                    }),
                  ),
              ],
            ),
            if (_dias.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Escolha pelo menos um dia.',
                  style: tema.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _dias.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(
                        ResultadoEditor.salvar(
                          hora: _horario.hour,
                          minuto: _horario.minute,
                          dias: {..._dias},
                        ),
                      ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Salvar'),
              ),
            ),
            if (editando)
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(const ResultadoEditor.excluir()),
                child: const Text('Excluir este lembrete'),
              ),
          ],
        ),
      ),
    );
  }
}
