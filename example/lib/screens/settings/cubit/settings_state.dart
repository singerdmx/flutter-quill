part of 'settings_cubit.dart';

enum DefaultScreen {
  home,
  settings,
  defaultSample,
  imagesSample,
  videosSample,
  textSample,
  emptySample,
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(DefaultScreen.home) DefaultScreen defaultScreen,
    @Default(false) bool useCustomQuillToolbar,
  }) = _SettingsState;
  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}
