part of 'bloc_manager_operation_cubit.dart';

/// Base state
abstract class OperationState extends Equatable {
  const OperationState();

  @override
  List<Object> get props => [];
}

class OperationInitial extends OperationState {
  const OperationInitial();
}

class OperationLoading extends OperationState {
  const OperationLoading();
}

class OperationLoaded extends OperationState {
  const OperationLoaded({required this.operation});

  final BlocManagerOperation operation;

  @override
  List<Object> get props => [operation];
}

class OperationFailed extends OperationState {
  const OperationFailed({this.message});

  final String? message;
}

abstract class BlocManagerException implements Exception {
  const BlocManagerException({required this.mesage});

  final String mesage;
}

class IncompatibleEvent extends BlocManagerException {
  const IncompatibleEvent({
    super.mesage = 'The passed event is not a bloc manager event',
  });
}
