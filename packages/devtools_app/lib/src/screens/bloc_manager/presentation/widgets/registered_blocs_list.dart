import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../devtools_app.dart';
import '../../logic/states/bloc_manager_repository/cubit/bloc_manager_repository_cubit.dart';

class RegisteredBlocsList extends StatelessWidget {
  const RegisteredBlocsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BlocManagerRepositoryState>(
      stream: context.read<BlocManagerRepositoryCubit>().stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!;
          if (state is BlocManagerRepositoryLoaded) {
            final nodes = state.nodes;
            return ListView.separated(
              itemBuilder: (context, i) {
                final node = nodes[i];
                return ListTile(
                  title: Text(node.blocName),
                  subtitle: Text(
                    node.fileUri,
                    style: Theme.of(context).textTheme.caption,
                  ),
                );
              },
              itemCount: nodes.length,
              separatorBuilder: (context, _) => const Divider(),
            );
          }
          if (state is BlocManagerRepositoryLoading) {
            return const CenteredCircularProgressIndicator();
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredCircularProgressIndicator();
        }

        return const CenteredMessage('Unknown Error');
      },
    );
  }
}
