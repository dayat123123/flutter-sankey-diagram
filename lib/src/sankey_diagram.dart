import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'sankey_models.dart';
import 'sankey_painter.dart';

class SankeyDiagram extends StatefulWidget {
  final List<SankeySourceNode> leftNodes;
  final List<SankeyDestinationNode> rightNodes;
  final Color? unselectedColor;
  final double minNodeHeight;
  final Widget Function(BuildContext, SankeyNodeBase, bool, bool, double)?
  labelBuilder;

  final bool showHeader;
  final Widget Function(BuildContext context, bool isActive, bool isLeft)?
  headerBuilder;
  final Widget? footer;

  const SankeyDiagram({
    super.key,
    required this.leftNodes,
    required this.rightNodes,
    this.labelBuilder,
    this.unselectedColor,
    this.minNodeHeight = 16.0,
    this.showHeader = false,
    this.headerBuilder,
    this.footer,
  });

  @override
  State<SankeyDiagram> createState() => _SankeyDiagramState();
}

class _SankeyDiagramState extends State<SankeyDiagram>
    with SingleTickerProviderStateMixin {
  int? selectedLeft, selectedRight;
  bool flowForward = true;
  bool hasInteracted = false;
  late AnimationController _controller;
  late List<SankeySourceNode> _sLeft;
  late List<SankeyDestinationNode> _sRight;
  late List<SankeyLink> _links;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _initData();

    if (!hasInteracted && _sLeft.isNotEmpty) {
      selectedLeft = 0;
      flowForward = true;
    }

    _controller.forward();
  }

  void _initData() {
    Map<String, double> totals = {};
    for (var node in widget.leftNodes) {
      for (var t in node.targets) {
        totals[t.label] = (totals[t.label] ?? 0) + t.value;
      }
    }

    _sLeft = List<SankeySourceNode>.from(widget.leftNodes)
      ..sort((a, b) => b.value.compareTo(a.value));

    _sRight = List<SankeyDestinationNode>.from(widget.rightNodes)
      ..sort((a, b) => b.value.compareTo(a.value));

    _links = [];
    for (int i = 0; i < _sLeft.length; i++) {
      for (var t in _sLeft[i].targets) {
        int rIdx = _sRight.indexWhere((node) => node.label == t.label);
        if (rIdx != -1) {
          _links.add(
            SankeyLink(
              sourceIndex: i,
              targetIndex: rIdx,
              value: t.value,
              color: _sLeft[i].color,
            ),
          );
        }
      }
    }
  }

  void _onTapDown(
    TapDownDetails details,
    BoxConstraints constraints,
    Map<int, NodeLayout> lLayouts,
    Map<int, NodeLayout> rLayouts,
  ) {
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;

    int? nL;
    int? nR;

    if (x < 80) {
      for (final entry in lLayouts.entries) {
        final rect = entry.value;

        if (y >= rect.top && y <= rect.top + rect.height) {
          nL = entry.key;
          break;
        }
      }
    } else if (x > constraints.maxWidth - 80) {
      for (final entry in rLayouts.entries) {
        final rect = entry.value;

        if (y >= rect.top && y <= rect.top + rect.height) {
          nR = entry.key;
          break;
        }
      }
    }

    if (nL == null && nR == null) return;

    final bool nextFlowForward = nL != null;

    final bool isSameSelection =
        selectedLeft == nL &&
        selectedRight == nR &&
        flowForward == nextFlowForward;

    if (isSameSelection) {
      return;
    }

    _controller
      ..reset()
      ..forward();

    setState(() {
      hasInteracted = true;
      selectedLeft = nL;
      selectedRight = nR;
      flowForward = nextFlowForward;
    });
  }

  @override
  void didUpdateWidget(covariant SankeyDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool dataChanged =
        !listEquals(widget.leftNodes, oldWidget.leftNodes) ||
        !listEquals(widget.rightNodes, oldWidget.rightNodes);

    if (dataChanged) {
      setState(() {
        _initData();
        if (!hasInteracted && _sLeft.isNotEmpty) {
          selectedLeft = 0;
          selectedRight = null;
          flowForward = true;
        }
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lLayouts = _calculateLayout(_sLeft, constraints.maxHeight);
        final rLayouts = _calculateLayout(_sRight, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _onTapDown(details, constraints, lLayouts, rLayouts),
          child: Stack(
            children: [
              if (widget.showHeader && widget.headerBuilder != null)
                Positioned(
                  top: 0,
                  left: 12,
                  child: IgnorePointer(
                    child: widget.headerBuilder?.call(
                      context,
                      selectedLeft != null,
                      true,
                    ),
                  ),
                ),
              if (widget.showHeader && widget.headerBuilder != null)
                Positioned(
                  top: 0,
                  right: 12,
                  child: IgnorePointer(
                    child: widget.headerBuilder?.call(
                      context,
                      selectedRight != null,
                      false,
                    ),
                  ),
                ),
              Positioned.fill(
                top: widget.showHeader ? 12 : 0,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: SankeyPainter(
                      unselectedColor: widget.unselectedColor,
                      links: _links,
                      leftLayouts: lLayouts,
                      rightLayouts: rLayouts,
                      selectedLeft: selectedLeft,
                      selectedRight: selectedRight,
                      progress: _controller.value,
                      flowForward: flowForward,
                      leftNodes: _sLeft,
                      rightNodes: _sRight,
                      hasInteracted: true,
                    ),
                  ),
                ),
              ),
              ..._buildLabels(lLayouts, rLayouts, _links, _sLeft, _sRight),
              if (widget.footer != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(child: widget.footer!),
                ),
            ],
          ),
        );
      },
    );
  }

  Map<int, NodeLayout> _calculateLayout(
    List<dynamic> nodes,
    double totalAvailableHeight,
  ) {
    final footerSpacing = widget.footer != null ? 30.0 : 0.0;
    Map<int, NodeLayout> layouts = {};
    double usableHeight = totalAvailableHeight - 30 - footerSpacing;
    double gap = 14.0;

    if ((nodes.length * widget.minNodeHeight) + (nodes.length * gap) >
        usableHeight) {
      gap =
          (usableHeight - (nodes.length * widget.minNodeHeight)) / nodes.length;
      if (gap < 2.0) gap = 2.0;
    }

    double totalValue = nodes.fold(0, (sum, item) => sum + item.value);
    double gapTotal = gap * (nodes.length - 1);
    double drawHeight = (usableHeight - gapTotal).clamp(0, usableHeight);

    double smallNodesUsedHeight = 0;
    double largeNodesTotalValue = 0;
    List<int> smallIndices = [];

    for (int i = 0; i < nodes.length; i++) {
      double idealH = (nodes[i].value / totalValue) * drawHeight;
      if (idealH < widget.minNodeHeight) {
        smallNodesUsedHeight += widget.minNodeHeight;
        smallIndices.add(i);
      } else {
        largeNodesTotalValue += nodes[i].value;
      }
    }

    double remainingH = (drawHeight - smallNodesUsedHeight).clamp(
      0,
      usableHeight,
    );
    double currentY = 20.0;

    for (int i = 0; i < nodes.length; i++) {
      double h = smallIndices.contains(i)
          ? widget.minNodeHeight
          : (largeNodesTotalValue > 0
                ? (nodes[i].value / largeNodesTotalValue) * remainingH
                : 0);

      layouts[i] = NodeLayout(top: currentY, height: h);
      currentY += h + gap;
    }
    return layouts;
  }

  List<Widget> _buildLabels(
    Map<int, NodeLayout> l,
    Map<int, NodeLayout> r,
    List<SankeyLink> links,
    List<SankeySourceNode> sL,
    List<SankeyDestinationNode> sR,
  ) {
    List<Widget> widgets = [];
    Map<int, double> leftContribution = {};
    Map<int, double> rightContribution = {};
    final Set<int> activeL = {};
    final Set<int> activeR = {};

    for (final link in links) {
      bool isLinkActive = false;
      if (selectedLeft != null && link.sourceIndex == selectedLeft) {
        isLinkActive = true;
        rightContribution[link.targetIndex] =
            (rightContribution[link.targetIndex] ?? 0) + link.value;
      } else if (selectedRight != null && link.targetIndex == selectedRight) {
        isLinkActive = true;
        leftContribution[link.sourceIndex] =
            (leftContribution[link.sourceIndex] ?? 0) + link.value;
      }
      if (isLinkActive) {
        activeL.add(link.sourceIndex);
        activeR.add(link.targetIndex);
      }
    }

    l.forEach((i, layout) {
      bool isActive = selectedLeft == i || activeL.contains(i);
      double displayValue = selectedLeft == i
          ? sL[i].value
          : (leftContribution[i] ?? sL[i].value);
      widgets.add(
        Positioned(
          top: layout.top + (layout.height / 2) - 10,
          left: 32,
          child: IgnorePointer(
            child: widget.labelBuilder?.call(
              context,
              sL[i],
              isActive,
              true,
              displayValue,
            ),
          ),
        ),
      );
    });

    r.forEach((i, layout) {
      bool isActive = selectedRight == i || activeR.contains(i);
      double displayValue = selectedRight == i
          ? sR[i].value
          : (rightContribution[i] ?? sR[i].value);
      widgets.add(
        Positioned(
          top: layout.top + (layout.height / 2) - 10,
          right: 32,
          child: IgnorePointer(
            child: widget.labelBuilder?.call(
              context,
              sR[i],
              isActive,
              false,
              displayValue,
            ),
          ),
        ),
      );
    });

    return widgets;
  }
}
