import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/dialog_action.dart';
import '../../shared/widgets/home_screen_button.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final isDark = materialTheme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: const [
          HomeScreenButton(),
        ],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              CheckboxListTile.adaptive(
                value: isDark,
                onChanged: (value) {
                  final isNewValueDark = value ?? false;
                  context.read<SettingsCubit>().updateSettings(
                        state.copyWith(
                          themeMode:
                              isNewValueDark ? ThemeMode.dark : ThemeMode.light,
                        ),
                      );
                },
                title: const Text('Dark Theme'),
                subtitle: const Text(
                  'By default we will use your system theme, but you can set if you want dark or light theme',
                ),
                secondary: Icon(isDark ? Icons.nightlight : Icons.sunny),
              ),
              ListTile(
                title: const Text('Default screen'),
                subtitle: const Text(
                  'Which screen should be used when the flutter app starts?',
                ),
                leading: const Icon(Icons.home),
                onTap: () async {
                  final settingsBloc = context.read<SettingsCubit>();
                  final newDefaultScreen =
                      await showAdaptiveDialog<DefaultScreen>(
                    context: context,
                    builder: (context) {
                      return AlertDialog.adaptive(
                        title: const Text('Select default screen'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...DefaultScreen.values.map(
                              (e) => Material(
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).pop(e);
                                  },
                                  title: Text(e.name),
                                  leading: CircleAvatar(
                                    child: Text((e.index + 1).toString()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          AppDialogAction(
                            onPressed: () => Navigator.of(context).pop(null),
                            options: const DialogActionOptions(
                              cupertinoDialogActionOptions:
                                  CupertinoDialogActionOptions(
                                isDefaultAction: true,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                  if (newDefaultScreen != null) {
                    settingsBloc.updateSettings(
                      settingsBloc.state
                          .copyWith(defaultScreen: newDefaultScreen),
                    );
                  }
                },
              ),
              CheckboxListTile.adaptive(
                value: state.useCustomQuillToolbar,
                onChanged: (value) {
                  final useCustomToolbarNewValue = value ?? false;
                  context.read<SettingsCubit>().updateSettings(
                        state.copyWith(
                          useCustomQuillToolbar: useCustomToolbarNewValue,
                        ),
                      );
                },
                title: const Text('Use custom Quill toolbar'),
                subtitle: const Text(
                  'By default we will default QuillToolbar, but you can decide if you the built-in or the custom one',
                ),
                secondary: const Icon(Icons.dashboard_customize),
              ),
            ],
          );
        },
      ),
    );
  }
}
