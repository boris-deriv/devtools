import 'package:flutter/foundation.dart';

/// Utility class that provides value equality to all its subclasses.
abstract class Equatable {
  const Equatable();
  List<Object?> get props;

  @override
  int get hashCode => Object.hashAll(props);

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType ||
      other is Equatable && listEquals(props, other.props);

  @override
  String toString() => '$runtimeType($props)';
}
