import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class SankeyTarget {
  final String label;
  final double value;
  const SankeyTarget(this.label, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SankeyTarget &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

@immutable
class SankeySourceNode {
  final String label;
  final Color color;
  final double value;
  final List<SankeyTarget> targets;

  const SankeySourceNode(
    this.label,
    this.color,
    this.value, {
    required this.targets,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SankeySourceNode &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          value == other.value &&
          listEquals(targets, other.targets);

  @override
  int get hashCode => Object.hash(label, color, value, Object.hashAll(targets));
}

@immutable
class SankeyDestinationNode {
  final String label;
  final Color color;
  final double value;

  const SankeyDestinationNode(this.label, this.color, {this.value = 0});

  SankeyDestinationNode copyWith({double? value}) {
    return SankeyDestinationNode(label, color, value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SankeyDestinationNode &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, color, value);
}

@immutable
class SankeyLink {
  final int sourceIndex, targetIndex;
  final double value;
  final Color color;
  const SankeyLink({
    required this.sourceIndex,
    required this.targetIndex,
    required this.value,
    required this.color,
  });
}

class NodeLayout {
  final double top, height;
  const NodeLayout({required this.top, required this.height});
}
