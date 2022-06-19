import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/common_widgets.dart';
import '../../logic/states/bloc_manager_repository/cubit/bloc_manager_repository_cubit.dart';

class RegisteredBlocsCounter extends StatelessWidget {
  const RegisteredBlocsCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BlocManagerRepositoryState>(
      stream: context.read<BlocManagerRepositoryCubit>().stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;
          if (state is BlocManagerRepositoryLoaded) {
            final blocs = state.nodes;
            return Chip(label: Text('${blocs.length}'));
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CenteredCircularProgressIndicator();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
