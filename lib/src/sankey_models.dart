import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
abstract class SankeyNodeBase {
  final String label;
  final Color color;
  final double value;

  const SankeyNodeBase({
    required this.label,
    required this.color,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SankeyNodeBase &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, color, value);
}

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
class SankeySourceNode extends SankeyNodeBase {
  final List<SankeyTarget> targets;

  const SankeySourceNode(
    String label,
    Color color,
    double value, {
    this.targets = const [],
  }) : super(label: label, color: color, value: value);

  SankeySourceNode copyWith({
    String? label,
    Color? color,
    double? value,
    List<SankeyTarget>? targets,
  }) {
    return SankeySourceNode(
      label ?? this.label,
      color ?? this.color,
      value ?? this.value,
      targets: targets ?? this.targets,
    );
  }

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
class SankeyDestinationNode extends SankeyNodeBase {
  const SankeyDestinationNode(String label, Color color, {required super.value})
    : super(label: label, color: color);

  SankeyDestinationNode copyWith({String? label, Color? color, double? value}) {
    return SankeyDestinationNode(
      label ?? this.label,
      color ?? this.color,
      value: value ?? this.value,
    );
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

enum SankeyNodeSide { left, right }

@immutable
class SankeyLink {
  final int sourceIndex;
  final int targetIndex;
  final double value;
  final Color color;

  const SankeyLink({
    required this.sourceIndex,
    required this.targetIndex,
    required this.value,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SankeyLink &&
          runtimeType == other.runtimeType &&
          sourceIndex == other.sourceIndex &&
          targetIndex == other.targetIndex &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => Object.hash(sourceIndex, targetIndex, value, color);
}

@immutable
class NodeLayout {
  final double top;
  final double height;

  const NodeLayout({required this.top, required this.height});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeLayout &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          height == other.height;

  @override
  int get hashCode => Object.hash(top, height);
}
