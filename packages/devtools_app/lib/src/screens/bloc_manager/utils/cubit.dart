import 'dart:async';

/// A minimal implementation of the `Cubit` class from the
/// [flutter_bloc](https://pub.dev/packages/flutter_bloc) package.
abstract class Cubit<S extends Object> {
  Cubit(S initialState) : _state = initialState {
    emit(_state);
  }

  S _state;

  /// The latest state emitted by this cubit.
  S get state => _state;

  final _controller = StreamController<S>.broadcast();

  /// A stream that gets state updates and exposes them to the subscribers.
  Stream<S> get stream => _controller.stream;

  /// Updates the [state] with the passed [newState] and pushes the [newState]
  /// to the [stream].
  void emit(S newState) {
    _controller.add(newState);
    _state = newState;
  }

  /// Closes the connection with the [stream].
  Future<void> close() => _controller.close();
}
