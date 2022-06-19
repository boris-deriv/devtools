import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../devtools_app.dart';
import '../../../../shared/eval_on_dart_library.dart';
import '../../logic/states/bloc_manager_operation/bloc_manager_operation_cubit.dart';
import '../../logic/states/bloc_manager_repository/cubit/bloc_manager_repository_cubit.dart';
import '../../utils/cubit.dart';
import '../../utils/extensions.dart';
import '../widgets/bloc_manager_events_record.dart';
import '../widgets/registered_blocs_counter.dart';
import '../widgets/registered_blocs_list.dart';

class BlocManagerScreen extends Screen {
  const BlocManagerScreen()
      : super.conditional(
          id: id,
          title: 'Bloc Manager',
          requiresDartVm: true,
          icon: Icons.line_style_rounded,
          worksOffline: true,
          requiresLibrary: libraryURI,
        );

  /// Id of the [BlocManagerScreen] screen.
  static const id = 'bloc_manager';

  /// URI of the Bloc Manager package.
  static const libraryURI = 'package:flutter_deriv_bloc_manager/manager.dart';

  /// Path to the `BlocManager` class.
  static const blocManagerClassPath =
      'package:flutter_deriv_bloc_manager/bloc_managers/bloc_manager.dart';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VmServiceWrapper>(
      initialData: serviceManager.service,
      stream: serviceManager.onConnectionAvailable,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final service = snapshot.data!;
          return MultiProvider(
            providers: [
              CubitProvider<BlocManagerOperationsCubit>(
                create: (context) => BlocManagerOperationsCubit(),
              ),
              CubitProvider<BlocManagerRepositoryCubit>(
                create: (context) => BlocManagerRepositoryCubit(),
              ),
            ],
            child: BlocManagerScreenBody(service: service),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredCircularProgressIndicator();
        }

        return const CenteredMessage('Unknown error');
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
  late final _eval = EvalOnDartLibrary(
    BlocManagerScreen.blocManagerClassPath,
    widget.service,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupCubits());
  }

  @override
  Widget build(BuildContext context) {
    return Split(
      initialFractions: const [0.4, 0.6],
      axis: Split.axisFor(context, 0.75),
      children: [
        OutlineDecoration(
          child: Column(
            children: [
              AreaPaneHeader(
                needsTopBorder: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registered Blocs',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const RegisteredBlocsCounter()
                  ],
                ),
              ),
              const Expanded(child: RegisteredBlocsList()),
            ],
          ),
        ),
        OutlineDecoration(
          child: Column(
            children: [
              AreaPaneHeader(
                needsTopBorder: false,
                title: Text(
                  'Bloc Manager Events',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(child: BlocManagerEventsRecord())
            ],
          ),
        )
      ],
    );
  }

  void _setupCubits() {
    context.read<BlocManagerRepositoryCubit>().getRegisteredBlocs(_eval);

    widget.service.onExtensionEvent
        .where((event) => event.isBlocManagerEvent)
        .listen((event) {
      if (mounted) {
        context.read<BlocManagerOperationsCubit>().getOperations(event);
      }
    });
  }

  @override
  void dispose() {
    _eval.dispose();
    super.dispose();
  }
}
