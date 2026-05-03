import 'dart:math';

import 'package:flutter/material.dart';
import 'sankey_models.dart';

class SankeyPainter extends CustomPainter {
  final Color? unselectedColor;
  final List<SankeyLink> links;
  final Map<int, NodeLayout> leftLayouts, rightLayouts;
  final int? selectedLeft, selectedRight;
  final double progress;
  final bool flowForward;
  final List<SankeySourceNode> leftNodes;
  final List<SankeyDestinationNode> rightNodes;
  final bool hasInteracted;

  SankeyPainter({
    this.unselectedColor,
    required this.links,
    required this.leftLayouts,
    required this.rightLayouts,
    this.selectedLeft,
    this.selectedRight,
    required this.progress,
    required this.flowForward,
    required this.leftNodes,
    required this.rightNodes,
    required this.hasInteracted,
  });

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final bool anySel = selectedLeft != null || selectedRight != null;

    Map<int, double> sUsed = {};
    Map<int, double> tUsed = {};
    Map<int, double> sourceTotals = {};
    Map<int, double> targetTotals = {};

    final Set<int> activeLeftNodes = {};
    final Set<int> activeRightNodes = {};

    for (var link in links) {
      sourceTotals[link.sourceIndex] =
          (sourceTotals[link.sourceIndex] ?? 0) + link.value;
      targetTotals[link.targetIndex] =
          (targetTotals[link.targetIndex] ?? 0) + link.value;
    }

    for (var link in links) {
      final l = leftLayouts[link.sourceIndex]!;
      final r = rightLayouts[link.targetIndex]!;

      final sTotal = sourceTotals[link.sourceIndex]!;
      final tTotal = targetTotals[link.targetIndex]!;

      double sHeight = (link.value / sTotal) * l.height;
      double tHeight = (link.value / tTotal) * r.height;

      double sTop = l.top + (sUsed[link.sourceIndex] ?? 0);
      double tTop = r.top + (tUsed[link.targetIndex] ?? 0);

      double sBottom = sTop + sHeight;
      double tBottom = tTop + tHeight;

      sUsed[link.sourceIndex] = (sUsed[link.sourceIndex] ?? 0) + sHeight;
      tUsed[link.targetIndex] = (tUsed[link.targetIndex] ?? 0) + tHeight;

      bool isActive =
          ((selectedLeft == link.sourceIndex) ||
              (selectedRight == link.targetIndex)) &&
          hasInteracted;

      if (isActive) {
        activeLeftNodes.add(link.sourceIndex);
        activeRightNodes.add(link.targetIndex);
      }

      final fullPath = Path()
        ..moveTo(28, sTop)
        ..cubicTo(
          size.width * 0.4,
          sTop,
          size.width * 0.6,
          tTop,
          size.width - 28,
          tTop,
        )
        ..lineTo(size.width - 28, tBottom)
        ..cubicTo(
          size.width * 0.6,
          tBottom,
          size.width * 0.4,
          sBottom,
          28,
          sBottom,
        )
        ..close();

      final paint = Paint()..style = PaintingStyle.fill;

      if (isActive) {
        final Rect rect = Rect.fromLTRB(
          28,
          min(sTop, tTop),
          size.width - 28,
          max(sBottom, tBottom),
        );

        final Color sourceColor = link.color;
        final Color targetColor = rightNodes[link.targetIndex].color;

        paint.shader = LinearGradient(
          begin: flowForward ? Alignment.centerLeft : Alignment.centerRight,
          end: flowForward ? Alignment.centerRight : Alignment.centerLeft,
          colors: flowForward
              ? [
                  sourceColor.withValues(alpha: 0.9),
                  Color.lerp(sourceColor, targetColor, 0.5)!,
                  targetColor.withValues(alpha: 0.9),
                ]
              : [
                  targetColor.withValues(alpha: 0.9),
                  Color.lerp(targetColor, sourceColor, 0.5)!,
                  sourceColor.withValues(alpha: 0.9),
                ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);
      } else {
        paint.color =
            unselectedColor ??
            Colors.grey.withValues(alpha: anySel ? 0.05 : 0.1);
      }

      if (isActive && progress < 1.0) {
        canvas.save();
        final curveProgress = Curves.easeInOutCubic.transform(progress);
        if (flowForward) {
          final clipRect = Rect.fromLTRB(
            0,
            0,
            28 + (size.width - 56) * curveProgress,
            size.height,
          );
          canvas.clipRect(clipRect);
        } else {
          final clipRect = Rect.fromLTRB(
            (size.width - 28) - (size.width - 56) * curveProgress,
            0,
            size.width,
            size.height,
          );
          canvas.clipRect(clipRect);
        }
        canvas.drawPath(fullPath, paint);
        canvas.restore();
      } else {
        canvas.drawPath(fullPath, paint);
      }
    }

    for (int i = 0; i < leftNodes.length; i++) {
      bool isNodeActive = anySel
          ? (selectedLeft == i ||
                (activeLeftNodes.contains(i) && progress == 1.0))
          : true;
      _drawNode(canvas, 12, leftLayouts[i]!, leftNodes[i].color, isNodeActive);
    }
    for (int i = 0; i < rightNodes.length; i++) {
      bool isNodeActive = anySel
          ? (selectedRight == i ||
                (activeRightNodes.contains(i) && progress == 1.0))
          : true;
      _drawNode(
        canvas,
        size.width - 22,
        rightLayouts[i]!,
        rightNodes[i].color,
        isNodeActive,
      );
    }
  }

  void _drawNode(Canvas canvas, double x, NodeLayout l, Color c, bool active) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        x,
        l.top,
        x + 10,
        l.top + l.height,
        const Radius.circular(2),
      ),
      Paint()..color = active ? c : Colors.grey.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant SankeyPainter old) => true;
}
