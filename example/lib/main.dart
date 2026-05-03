import 'package:flutter/material.dart';
import 'package:flutter_sankey_diagram/flutter_sankey_diagram.dart';

void main() => runApp(
  const MaterialApp(
    themeMode: .dark,
    debugShowCheckedModeBanner: false,
    home: SankeyShowcase(),
  ),
);

class SankeyShowcase extends StatefulWidget {
  const SankeyShowcase({super.key});

  @override
  State<SankeyShowcase> createState() => _SankeyShowcaseState();
}

class _SankeyShowcaseState extends State<SankeyShowcase> {
  List<SankeySourceNode> _lNode = [
    SankeySourceNode(
      "Main Salary",
      Colors.indigo,
      50000000,
      targets: [
        SankeyTarget("Mortgage", 15000000),
        SankeyTarget("Wedding Savings", 15000000),
        SankeyTarget("Monthly Expenses", 10000000),
        SankeyTarget("Insurance", 5000000),
        SankeyTarget("Emergency Fund", 5000000),
      ],
    ),
    SankeySourceNode(
      "Annual Bonus",
      Colors.deepOrange,
      25000000,
      targets: [
        SankeyTarget("Stock Investment", 20000000),
        SankeyTarget("Self Reward", 5000000),
      ],
    ),
    SankeySourceNode(
      "Flutter Projects",
      Colors.blue,
      15000000,
      targets: [
        SankeyTarget("Stock Investment", 10000000),
        SankeyTarget("Work Tools / IT", 5000000),
      ],
    ),
    SankeySourceNode(
      "Freelance C++",
      Colors.red,
      10000000,
      targets: [SankeyTarget("Wedding Savings", 10000000)],
    ),
    SankeySourceNode(
      "Stock Dividends",
      Colors.teal,
      7000000,
      targets: [
        SankeyTarget("Stock Investment", 5000000),
        SankeyTarget("Property Maintenance", 2000000),
      ],
    ),
    SankeySourceNode(
      "Rental Income",
      Colors.green,
      6000000,
      targets: [
        SankeyTarget("Utilities & Internet", 4000000),
        SankeyTarget("Property Maintenance", 2000000),
      ],
    ),
    SankeySourceNode(
      "Crypto Trading",
      Colors.orange,
      5000000,
      targets: [
        SankeyTarget("Stock Investment", 3000000),
        SankeyTarget("Emergency Fund", 2000000),
      ],
    ),
    SankeySourceNode(
      "YouTube Ads",
      Colors.redAccent,
      3000000,
      targets: [SankeyTarget("Self Reward", 3000000)],
    ),
    SankeySourceNode(
      "Referral Bonus",
      Colors.cyan,
      2500000,
      targets: [SankeyTarget("Charity", 2500000)],
    ),
    SankeySourceNode(
      "Tax Refund",
      Colors.grey,
      1500000,
      targets: [SankeyTarget("Emergency Fund", 1500000)],
    ),
  ];
  List<SankeyDestinationNode> _rNode = [
    SankeyDestinationNode("Stock Investment", Colors.green, value: 38000000),
    SankeyDestinationNode("Wedding Savings", Colors.pink, value: 25000000),
    SankeyDestinationNode("Mortgage", Colors.red, value: 15000000),
    SankeyDestinationNode("Monthly Expenses", Colors.orange, value: 10000000),
    SankeyDestinationNode("Emergency Fund", Colors.teal, value: 8500000),
    SankeyDestinationNode("Self Reward", Colors.purple, value: 8000000),
    SankeyDestinationNode("Insurance", Colors.blue, value: 5000000),
    SankeyDestinationNode("Work Tools / IT", Colors.brown, value: 5000000),
    SankeyDestinationNode(
      "Property Maintenance",
      Colors.blueGrey,
      value: 4000000,
    ),
    SankeyDestinationNode("Utilities & Internet", Colors.amber, value: 4000000),
    SankeyDestinationNode("Charity", Colors.lightGreen, value: 2500000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F0F0F),
        title: const Text(
          "Flutter Sankey Diagram",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (_lNode.isEmpty || _rNode.isEmpty) return;
              setState(() {
                final newLeft = List<SankeySourceNode>.from(_lNode);
                final newRight = List<SankeyDestinationNode>.from(_rNode);
                newLeft.removeAt(0);
                newRight.removeAt(0);
                _lNode = newLeft;
                _rNode = newRight;
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: SankeyDiagram(
            minNodeHeight: 14,
            unselectedColor: Colors.grey.withValues(alpha: 0.05),
            labelBuilder: (context, node, isActive, isLeft, value) {
              final formattedValue = value
                  .toStringAsFixed(0)
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black.withValues(alpha: 0.8) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${node.label} ${isActive ? '(\$ $formattedValue)' : ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              );
            },

            leftNodes: _lNode,
            rightNodes: _rNode,
          ),
        ),
      ),
    );
  }
}
