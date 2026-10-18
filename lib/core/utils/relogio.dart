import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Devolve a data/hora de agora. Fica num provider só para os testes
/// poderem "fingir" que é outro dia.
final relogioProvider = Provider<DateTime Function()>((ref) => DateTime.now);
