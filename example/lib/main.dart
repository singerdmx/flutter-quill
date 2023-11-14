import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:flutter_quill/translations.dart' show FlutterQuillLocalizations;
import 'package:hydrated_bloc/hydrated_bloc.dart'
    show HydratedBloc, HydratedStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'presentation/home/widgets/home_screen.dart';
import 'presentation/quill/quill_images_screen.dart';
import 'presentation/settings/cubit/settings_cubit.dart';
import 'presentation/settings/widgets/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingsCubit(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flutter Quill Demo',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: FlutterQuillLocalizations.supportedLocales,
            routes: {
              SettingsScreen.routeName: (context) => const SettingsScreen(),
              QuillImagesScreen.routeName: (context) =>
                  const QuillImagesScreen(),
            },
            home: Builder(
              builder: (context) {
                final screen = switch (state.defaultScreen) {
                  DefaultScreen.home => const HomePage(),
                  DefaultScreen.settings => const SettingsScreen(),
                  DefaultScreen.images => const QuillImagesScreen(),
                  DefaultScreen.videos => null,
                  DefaultScreen.text => null,
                };
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 330),
                  transitionBuilder: (child, animation) {
                    // This animation is from flutter.dev example
                    const begin = Offset(0, 1);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(
                      CurveTween(curve: curve),
                    );

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  child: screen,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
