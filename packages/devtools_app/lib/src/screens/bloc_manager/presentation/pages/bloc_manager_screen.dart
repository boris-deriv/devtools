import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../devtools_app.dart';
import '../../logic/states/bloc_manager_operation/bloc_manager_operation_cubit.dart';
import '../../logic/states/bloc_manager_repository/cubit/bloc_manager_repository_cubit.dart';
import '../../utils/extensions.dart';

class BlocManagerScreen extends Screen {
  const BlocManagerScreen()
      : super.conditional(
          id: id,
          title: 'Bloc Manager',
          requiresDartVm: true,
          icon: Icons.line_style_rounded,
          worksOffline: true,
          requiresLibrary: libraryPath,
        );

  static const id = 'bloc_manager';
  static const libraryPath = 'package:flutter_deriv_bloc_manager/manager.dart';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VmServiceWrapper>(
      initialData: serviceManager.service,
      stream: serviceManager.onConnectionAvailable,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final service = snapshot.data!;
          return Provider(
            create: (context) => BlocManagerOperationsCubit(),
            child: BlocManagerScreenBody(service: service),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return const Center(child: Text('Unknown error'));
      },
    );
  }
}

class BlocManagerScreenBody extends StatefulWidget {
  const BlocManagerScreenBody({required this.service, super.key});

  final VmServiceWrapper service;

  @override
  State<BlocManagerScreenBody> createState() => _BlocManagerScreenBodyState();
}

class _BlocManagerScreenBodyState extends State<BlocManagerScreenBody> {
  late final BlocManagerRepositoryCubit _nodesCubit;
  late final eval = DisposableEvalOnLibrary(
    'package:flutter_deriv_bloc_manager/bloc_managers/bloc_manager.dart',
    widget.service,
  );

  @override
  void initState() {
    super.initState();

    _nodesCubit = BlocManagerRepositoryCubit(eval)..getNodes();

    widget
      ..service
          .onExtensionEvent
          .where((event) => event.isBlocManagerEvent)
          .listen((event) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BlocManagerOperationsCubit>().getOperations(event);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Split(
      initialFractions: const [0.33, 0.67],
      axis: Split.axisFor(context, 0.75),
      children: [
        OutlineDecoration(
          child: Column(
            children: [
              AreaPaneHeader(
                needsTopBorder: false,
                title: Text(
                  'Registered Blocs',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: StreamBuilder<BlocManagerRepositoryState>(
                  stream: _nodesCubit.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final state = snapshot.data!;
                      if (state is BlocManagerRepositoryLoaded) {
                        final nodes = state.nodes;
                        return ListView.builder(
                          itemBuilder: (context, i) {
                            final node = nodes[i];
                            return ListTile(
                              title: Text(node.blocName),
                              subtitle: Text(node.fileUri),
                            );
                          },
                          itemCount: nodes.length,
                        );
                      }
                      if (state is BlocManagerRepositoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return const Center(child: Text('Unknown Error'));
                  },
                ),
              ),
            ],
          ),
        ),
        OutlineDecoration(
          child: Column(
            children: [
              AreaPaneHeader(
                needsTopBorder: false,
                title: Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: StreamBuilder<OperationState>(
                  stream: context.read<BlocManagerOperationsCubit>().stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      final state = snapshot.data;
                      if (state is OperationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is OperationLoaded) {
                        return ListTile(
                          isThreeLine: true,
                          title: Text(state.operation.blocName),
                          subtitle: Text(state.operation.state),
                        );
                      }
                    }
                    return const Center(child: Text('Unknown Error>'));
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    eval.dispose();
    super.dispose();
  }
}
