import 'dart:developer' show postEvent;

import 'equatable.dart';

/// Model for operations that are emitted by [postEvent] in `BlocManager`.
///
/// An operation is an event sent by the `BlocManager` package. It holds a bloc,
/// its current state and the [BlocEvent] that
///
/// This class holds the data provided by the event's payload.
class BlocManagerOperation extends Equatable {
  const BlocManagerOperation({
    required this.event,
    required this.blocName,
    required this.state,
    required this.key,
  });

  /// Initializes a new [BlocManagerOperation] from a JSON Map.
  factory BlocManagerOperation.fromMap(Map<String, dynamic> map) {
    return BlocManagerOperation(
      event: BlocEvent.fromString(map['event']),
      blocName: map['bloc'],
      state: map['state'],
      key: map['key'],
    );
  }

  /// The type of event sent by the `BlocManager` library.
  final BlocEvent event;

  /// The name of the bloc on which the event has been applied.
  final String blocName;

  /// The state of the bloc at the time the event was fired.
  final String state;

  /// The key identifier of the bloc in the manager's repository.
  final String key;

  BlocManagerOperation copyWith({
    BlocEvent? event,
    String? blocName,
    String? state,
    String? key,
  }) =>
      BlocManagerOperation(
        event: event ?? this.event,
        blocName: blocName ?? this.blocName,
        state: state ?? this.state,
        key: key ?? this.key,
      );

  @override
  List<Object> get props => [event, blocName, state, key];
}

/// Types of events that `BlocManager` package sends.
enum BlocEvent {
  /// Event triggered by `BlocManager.register`.
  register,

  /// Event triggered by  `BlocManager.dispose`.
  dispose,

  /// Event triggered by  `BlocManager.fetch`.
  fetch,

  /// Event triggered by `BlocManager.addListener`.
  add_subscription,

  /// Event triggered by `BlocManager.removeListener`.
  remove_subscription;

  /// Gets the correct [BlocEvent] value from a string.
  factory BlocEvent.fromString(String val) => BlocEvent.values.firstWhere(
        (v) => v.name == val,
      );
}
