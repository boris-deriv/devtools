part of 'bloc_manager_repository_cubit.dart';

@immutable
abstract class BlocManagerRepositoryState extends Equatable {
  const BlocManagerRepositoryState();

  @override
  List<Object?> get props => [];
}

class BlocManagerRepositoryInitial extends BlocManagerRepositoryState {
  const BlocManagerRepositoryInitial();
}

class BlocManagerRepositoryLoading extends BlocManagerRepositoryState {
  const BlocManagerRepositoryLoading();
}

class BlocManagerRepositoryLoaded extends BlocManagerRepositoryState {
  const BlocManagerRepositoryLoaded(this.nodes);

  final List<BlocNode> nodes;

  @override
  List<Object> get props => [...nodes];
}

class BlocManagerRepositoryFailure extends BlocManagerRepositoryState {
  const BlocManagerRepositoryFailure({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}
