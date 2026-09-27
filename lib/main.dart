import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/finance_bloc.dart';
import 'bloc/finance_event.dart';
import 'bloc/theme_bloc.dart';
import 'repositories/finance_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile (Portrait mode)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make system navigation bar & status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repository = await FinanceRepository.create();

  runApp(EnigmaFinanceApp(repository: repository));
}

class EnigmaFinanceApp extends StatelessWidget {
  final FinanceRepository repository;

  const EnigmaFinanceApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FinanceBloc>(
          create: (_) => FinanceBloc(repository: repository)..add(const LoadFinanceData()),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(repository: repository),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Enigma Finance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
