// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsStateImpl _$$SettingsStateImplFromJson(Map<String, dynamic> json) =>
    _$SettingsStateImpl(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      defaultScreen:
          $enumDecodeNullable(_$DefaultScreenEnumMap, json['defaultScreen']) ??
              DefaultScreen.home,
      useCustomQuillToolbar: json['useCustomQuillToolbar'] as bool? ?? false,
    );

Map<String, dynamic> _$$SettingsStateImplToJson(_$SettingsStateImpl instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'defaultScreen': _$DefaultScreenEnumMap[instance.defaultScreen]!,
      'useCustomQuillToolbar': instance.useCustomQuillToolbar,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DefaultScreenEnumMap = {
  DefaultScreen.home: 'home',
  DefaultScreen.settings: 'settings',
  DefaultScreen.defaultSample: 'defaultSample',
  DefaultScreen.imagesSample: 'imagesSample',
  DefaultScreen.videosSample: 'videosSample',
  DefaultScreen.textSample: 'textSample',
  DefaultScreen.emptySample: 'emptySample',
};
