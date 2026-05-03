import 'package:flutter_sankey_diagram/flutter_sankey_diagram.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Sankey Diagram Data Integrity Tests', () {
    test('Total Source Value must match Total Target Values in each node', () {
      final node = SankeySourceNode(
        "Gaji",
        Colors.blue,
        10000,
        targets: [SankeyTarget("Makan", 7000), SankeyTarget("Olahraga", 3000)],
      );

      final double totalTargets = node.targets.fold(
        0,
        (sum, item) => sum + item.value,
      );

      expect(totalTargets, node.value);
    });

    test('Global Left total must equal Global Right total', () {
      final leftNodes = [
        SankeySourceNode(
          "Gaji",
          Colors.blue,
          5000,
          targets: [SankeyTarget("A", 3000), SankeyTarget("B", 2000)],
        ),
      ];

      final rightNodes = [
        SankeyDestinationNode("A", Colors.red, value: 3000),
        SankeyDestinationNode("B", Colors.green, value: 2000),
      ];

      final double totalLeft = leftNodes.fold(
        0,
        (sum, item) => sum + item.value,
      );
      final double totalRight = rightNodes.fold(
        0,
        (sum, item) => sum + item.value,
      );

      expect(totalLeft, totalRight);
    });

    testWidgets('SankeyDiagram should render without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SankeyDiagram(
              leftNodes: [
                SankeySourceNode(
                  "Gaji",
                  Colors.blue,
                  1000,
                  targets: [SankeyTarget("Makan", 1000)],
                ),
              ],
              rightNodes: [
                SankeyDestinationNode("Makan", Colors.red, value: 1000),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SankeyDiagram), findsOneWidget);
    });
  });
}
