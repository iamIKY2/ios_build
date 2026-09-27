import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/finance_repository.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeEvent extends ThemeEvent {
  final ThemeMode mode;
  SetThemeEvent(this.mode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final FinanceRepository repository;

  ThemeBloc({required this.repository})
      : super(_stringToThemeMode(repository.loadThemeMode())) {
    on<ToggleThemeEvent>((event, emit) async {
      final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      emit(newMode);
      await repository.saveThemeMode(newMode == ThemeMode.dark ? 'dark' : 'light');
    });

    on<SetThemeEvent>((event, emit) async {
      emit(event.mode);
      await repository.saveThemeMode(event.mode == ThemeMode.dark ? 'dark' : 'light');
    });
  }

  static ThemeMode _stringToThemeMode(String val) {
    if (val == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }
}
