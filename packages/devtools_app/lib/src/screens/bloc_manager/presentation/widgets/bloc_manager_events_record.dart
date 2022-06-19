import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../devtools_app.dart';
import '../../logic/states/bloc_manager_operation/bloc_manager_operation_cubit.dart';
import '../../models/bloc_manager_operation.dart';

/// Widgets that records events and operations from the `BlocManager` package.
class BlocManagerEventsRecord extends StatefulWidget {
  const BlocManagerEventsRecord({super.key});

  @override
  State<BlocManagerEventsRecord> createState() =>
      _BlocManagerEventsRecordState();
}

class _BlocManagerEventsRecordState extends State<BlocManagerEventsRecord> {
  final List<BlocManagerOperation> _operations = [];

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OperationState>(
      stream: context.read<BlocManagerOperationsCubit>().stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          if (state is OperationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OperationLoaded) {
            _operations.add(state.operation);
            return ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, i) {
                final operation = _operations[i];
                _scrollToBottom();
                return ListTile(
                  isThreeLine: true,
                  title: Text('${operation.blocName} :: ${operation.key}'),
                  subtitle: Text(operation.event.name),
                );
              },
              itemCount: _operations.length,
            );
          }
          if (state is OperationLoading) {
            return const CenteredCircularProgressIndicator();
          }

          return const SizedBox.shrink();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredCircularProgressIndicator();
        }
        return const CenteredMessage('Unknown Error');
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
