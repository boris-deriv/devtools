import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../devtools_app.dart';
import '../../shared/eval_on_dart_library.dart';

class BlocManagerScreen extends Screen {
  const BlocManagerScreen()
      : super.conditional(
          id: id,
          title: 'Bloc Manager',
          requiresDartVm: true,
          icon: Icons.line_style_rounded,
          worksOffline: true,
          requiresLibrary: 'package:flutter_deriv_bloc_manager/manager.dart',
        );

  static const id = 'bloc_manager';

  @override
  Widget build(BuildContext context) {
    return const BlocManagerScreenBody();
  }
}

class BlocManagerScreenBody extends StatefulWidget {
  const BlocManagerScreenBody({super.key});

  @override
  State<BlocManagerScreenBody> createState() => _BlocManagerScreenBodyState();
}

class _BlocManagerScreenBodyState extends State<BlocManagerScreenBody> {
  late final ValueNotifier<BlocDetails?> _blocNotifier;
  late final ValueNotifier<List<BlocDetails>> _storeNotifier;

  late final Disposable _isAlive = Disposable();

  Future<List<BlocDetails>> _getBlocDetails() async {
    final eval = EvalOnDartLibrary(
      'package:flutter_deriv_bloc_manager/bloc_managers/bloc_manager.dart',
      serviceManager.service!,
    );
    final bmRef = await eval.safeEval(
      'BlocManager.instance.repository',
      isAlive: _isAlive,
    );
    final instance = await eval.getInstance(bmRef, _isAlive);

    final associations = instance?.associations;
    final items = <BlocDetails>[];

    if (associations != null) {
      items.addAll(
        associations.map<BlocDetails>((e) {
          return BlocDetails(e.key.valueAsString);
        }),
      );
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    _blocNotifier = ValueNotifier(null);
    _storeNotifier = ValueNotifier(const [])
      ..addListener(() {
        _blocNotifier.value ??= _storeNotifier.value.first;
      });

    serviceManager
      ..isolateManager.onIsolateExited.listen((_) {
        _storeNotifier.value = const [];
      })
      ..service
          ?.onExtensionEvent
          .where(
            (event) => event.extensionKind == 'bloc_manager_event',
          )
          .listen((event) {
        _getBlocDetails().then((items) {
          final stated = items.map((b) {
            var item = b;
            String? state;
            // print('Date: ${event.extensionData?.data}');
            if (event.extensionData != null) {
              if (event.extensionData!.data.keys.contains(b.name)) {
                b = StatedBlocDetails.fromMap(
                  event.extensionData!.data,
                  b.value,
                );
              }
            }
            return item;
          });

          final isEqual = listEquals(_storeNotifier.value, stated.toList());
          if (!isEqual) {
            _storeNotifier.value = stated.toList();
          }
        });
      });
  }

  @override
  void dispose() {
    _blocNotifier.dispose();
    _storeNotifier.dispose();
    _isAlive.dispose();
    super.dispose();
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
                child: ValueListenableBuilder<List<BlocDetails>>(
                  valueListenable: _storeNotifier,
                  builder: (context, blocs, _) => ListView.builder(
                    itemBuilder: (context, i) {
                      final bloc = blocs[i];
                      return ListTile(
                        onTap: () {
                          _blocNotifier.value = bloc;
                        },
                        title: Text(bloc.name),
                        subtitle: Text(
                          bloc.key,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(color: Colors.teal),
                        ),
                      );
                    },
                    itemCount: blocs.length,
                  ),
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
                child: ValueListenableBuilder<BlocDetails?>(
                  valueListenable: _blocNotifier,
                  builder: (context, bloc, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Bloc: '),
                            Text(
                              '${bloc?.name}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class BlocDetails {
  const BlocDetails(this.value);
  final String value;

  static const _separator = '::';

  String get name {
    if (!value.contains(_separator)) {
      return value;
    }
    return value.substring(0, value.indexOf(_separator));
  }

  String get key {
    if (!value.contains(_separator)) {
      return value;
    }
    return value.substring(value.indexOf(_separator) + 2);
  }
}

class StatedBlocDetails extends BlocDetails {
  const StatedBlocDetails(
    super.value, {
    required this.currentState,
    required this.nextState,
  });

  factory StatedBlocDetails.fromMap(Map<String, dynamic> map, String value) =>
      StatedBlocDetails(
        value,
        currentState: map['current'],
        nextState: map['next'],
      );

  final String currentState;
  final String nextState;
}
