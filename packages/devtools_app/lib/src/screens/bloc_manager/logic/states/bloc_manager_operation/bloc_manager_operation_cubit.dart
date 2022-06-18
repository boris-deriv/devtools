import 'dart:developer';

import 'package:vm_service/vm_service.dart';

import '../../../../../service/vm_service_wrapper.dart';
import '../../../models/bloc_manager_operation.dart';
import '../../../models/equatable.dart';
import '../../../utils/cubit.dart';
import '../../../utils/extensions.dart';

part 'bloc_manager_operation_state.dart';

/// A [Cubit] that manages the states of of [BlocManagerOperation].
class BlocManagerOperationsCubit extends Cubit<OperationState> {
  /// Initializes a new [BlocManagerOperationsCubit].
  BlocManagerOperationsCubit() : super(const OperationInitial());

  /// Gets all the [BlocManagerOperation] object in the passed [event] then
  /// emit them in a [OperationLoaded]. If an error occurs, a [OperationFailed]
  /// will be emitted instead.
  ///
  /// This method can be used to capture events sent by the `BlocManager` package
  /// using [postEvent].
  ///
  /// These events can be captured from a [VmServiceWrapper] object such as.
  ///
  /// Example:
  /// ```dart
  /// final cubit = BlocManagerOperationsCubit();
  ///
  /// serviceManager.service
  ///        ?.onExtensionEvent
  ///        .where(
  ///          (event) => event.isBlocManagerEvent,
  ///        )
  ///        .listen(cubit.getOperations);
  ///
  /// ```
  ///
  /// In the example above, every time a new event is sent to the service, this
  /// method will be called.
  ///
  /// The extension should be `bloc_management_event`.
  void getOperations(Event event) {
    if (!event.isBlocManagerEvent || !event.hasData) {
      return;
    }

    emit(const OperationLoading());

    try {
      final operation = BlocManagerOperation.fromMap(event.payload!);
      emit(OperationLoaded(operation: operation));
    } catch (e) {
      emit(OperationFailed(message: '$e'));
    }
  }
}
