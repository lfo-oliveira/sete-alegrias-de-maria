import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';

/// Reagenda os lembretes quando o app abre e quando volta para a frente.
/// Assim a janela de dias agendados se renova sozinha.
class LembretesInicializador extends ConsumerStatefulWidget {
  const LembretesInicializador({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LembretesInicializador> createState() =>
      _LembretesInicializadorState();
}

class _LembretesInicializadorState
    extends ConsumerState<LembretesInicializador> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sincronizar();
  }

  void _sincronizar() {
    // Falha ao agendar (ex.: aparelho sem suporte) não pode derrubar o app.
    ref.read(lembretesProvider.notifier).sincronizar().catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
