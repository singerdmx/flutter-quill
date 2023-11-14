part of 'settings_cubit.dart';

enum DefaultScreen {
  home,
  settings,
  images,
  videos,
  text,
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(DefaultScreen.home) DefaultScreen defaultScreen,
  }) = _SettingsState;
  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}
