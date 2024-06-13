import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:flutter_quill/flutter_quill.dart' show Document;
import 'package:flutter_quill/translations.dart' show FlutterQuillLocalizations;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart'
    show HydratedBloc, HydratedStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'screens/home/widgets/home_screen.dart';
import 'screens/quill/quill_screen.dart';
import 'screens/quill/samples/quill_default_sample.dart';
import 'screens/quill/samples/quill_images_sample.dart';
import 'screens/quill/samples/quill_text_sample.dart';
import 'screens/quill/samples/quill_videos_sample.dart';
import 'screens/settings/cubit/settings_cubit.dart';
import 'screens/settings/widgets/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  FlutterQuillExtensions.useSuperClipboardPlugin();
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
            theme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light,
                seedColor: Colors.red,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Colors.red,
              ),
            ),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              // Uncomment this line to use provide flutter quill localizations
              // in your widgets app, otherwise the quill widgets will provide it
              // internally:
              // FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: FlutterQuillLocalizations.supportedLocales,
            routes: {
              SettingsScreen.routeName: (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              final name = settings.name;
              if (name == HomeScreen.routeName) {
                return MaterialPageRoute(
                  builder: (context) {
                    return const HomeScreen();
                  },
                );
              }
              if (name == QuillScreen.routeName) {
                return MaterialPageRoute(
                  builder: (context) {
                    final args = settings.arguments as QuillScreenArgs;
                    return QuillScreen(
                      args: args,
                    );
                  },
                );
              }
              return null;
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Not found'),
                  ),
                  body: const Text('404'),
                ),
              );
            },
            home: Builder(
              builder: (context) {
                final screen = switch (state.defaultScreen) {
                  DefaultScreen.home => const HomeScreen(),
                  DefaultScreen.settings => const SettingsScreen(),
                  DefaultScreen.imagesSample => QuillScreen(
                      args: QuillScreenArgs(
                        document: Document.fromJson(quillImagesSample),
                      ),
                    ),
                  DefaultScreen.videosSample => QuillScreen(
                      args: QuillScreenArgs(
                        document: Document.fromJson(quillVideosSample),
                      ),
                    ),
                  DefaultScreen.textSample => QuillScreen(
                      args: QuillScreenArgs(
                        document: Document.fromJson(quillTextSample),
                      ),
                    ),
                  DefaultScreen.emptySample => QuillScreen(
                      args: QuillScreenArgs(
                        document: Document(),
                      ),
                    ),
                  DefaultScreen.defaultSample => QuillScreen(
                      args: QuillScreenArgs(
                        document: Document.fromJson(quillDefaultSample),
                      ),
                    ),
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
