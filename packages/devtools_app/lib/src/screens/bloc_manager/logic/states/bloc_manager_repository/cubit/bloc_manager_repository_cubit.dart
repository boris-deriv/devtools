import 'package:meta/meta.dart';

import '../../../../../../shared/eval_on_dart_library.dart';
import '../../../../models/bloc_node.dart';
import '../../../../models/equatable.dart';
import '../../../../utils/cubit.dart';

part 'bloc_manager_repository_state.dart';

class BlocManagerRepositoryCubit extends Cubit<BlocManagerRepositoryState> {
  BlocManagerRepositoryCubit({Disposable? isAlive})
      : _isAlive = isAlive ?? Disposable(),
        super(const BlocManagerRepositoryInitial());

  final Disposable _isAlive;

  /// Gets blocs from the `BlocManager` object's repository.
  Future<void> getRegisteredBlocs(EvalOnDartLibrary blocManagerEval) async {
    emit(const BlocManagerRepositoryLoading());
    try {
      final nodes = await _getRepositoryContent(blocManagerEval);
      emit(BlocManagerRepositoryLoaded(nodes));
    } catch (e) {
      emit(BlocManagerRepositoryFailure(message: '$e'));
    }
  }

  Future<List<BlocNode>> _getRepositoryContent(EvalOnDartLibrary eval) async {
    final bmRef = await eval.safeEval(
      'BlocManager.instance.repository',
      isAlive: _isAlive,
    );

    final instance = await eval.getInstance(bmRef, _isAlive);

    final associations = instance?.associations;
    final items = <BlocNode>[];

    if (associations != null) {
      items.addAll(associations.map(BlocNode.fromMapAssociation));
    }

    return items;
  }
}

class DisposableEvalOnLibrary extends EvalOnDartLibrary with Disposable {
  DisposableEvalOnLibrary(
    super.libraryName,
    super.service, {
    super.isolate,
    super.disableBreakpoints = true,
    super.oneRequestAtATime = false,
  });
}
