import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/indicador_contas.dart';

void main() {
  testWidgets('mostra o texto do contador e o número correto de contas',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IndicadorContas(atual: 3, total: 10),
        ),
      ),
    );

    // Confere se exibiu '3 de 10'
    expect(find.text('3 de 10'), findsOneWidget);

    // As duas primeiras contas rezadas devem ter o ícone de check
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('na primeira conta nenhuma tem check', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IndicadorContas(atual: 1, total: 10),
        ),
      ),
    );

    expect(find.text('1 de 10'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });
}