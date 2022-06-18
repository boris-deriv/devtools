import 'package:meta/meta.dart';

import '../../../../../../shared/eval_on_dart_library.dart';
import '../../../../models/bloc_node.dart';
import '../../../../models/equatable.dart';
import '../../../../utils/cubit.dart';

part 'bloc_manager_repository_state.dart';

class BlocManagerRepositoryCubit extends Cubit<BlocManagerRepositoryState> {
  BlocManagerRepositoryCubit(this._libraryEval)
      : super(const BlocManagerRepositoryInitial());

  final DisposableEvalOnLibrary _libraryEval;

  Future<void> getNodes() async {
    emit(const BlocManagerRepositoryLoading());
    try {
      final nodes = await _fetchBlocNodes();
      emit(BlocManagerRepositoryLoaded(nodes));
    } catch (e) {
      emit(BlocManagerRepositoryFailure(message: '$e'));
    }
  }

  Future<List<BlocNode>> _fetchBlocNodes() async {
    final bmRef = await _libraryEval.safeEval(
      'BlocManager.instance.repository',
      isAlive: _libraryEval,
    );

    final instance = await _libraryEval.getInstance(bmRef, _libraryEval);

    final associations = instance?.associations;
    final items = <BlocNode>[];

    if (associations != null) {
      items.addAll(associations.map(BlocNode.fromMapAssociation));
    }

    return items;
  }

  @override
  Future<void> close() async {
    _libraryEval.dispose();
    await super.close();
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
