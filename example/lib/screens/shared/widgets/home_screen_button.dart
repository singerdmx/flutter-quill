import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/cubit/settings_cubit.dart';

class HomeScreenButton extends StatelessWidget {
  const HomeScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final settingsCubit = context.read<SettingsCubit>();
        settingsCubit.updateSettings(
          settingsCubit.state.copyWith(
            defaultScreen: DefaultScreen.home,
          ),
        );
      },
      icon: const Icon(Icons.home),
      tooltip: 'Set the default to home screen',
    );
  }
}
