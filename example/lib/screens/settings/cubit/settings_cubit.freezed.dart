// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) {
  return _SettingsState.fromJson(json);
}

/// @nodoc
mixin _$SettingsState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  DefaultScreen get defaultScreen => throw _privateConstructorUsedError;
  bool get useCustomQuillToolbar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      DefaultScreen defaultScreen,
      bool useCustomQuillToolbar});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? defaultScreen = null,
    Object? useCustomQuillToolbar = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      defaultScreen: null == defaultScreen
          ? _value.defaultScreen
          : defaultScreen // ignore: cast_nullable_to_non_nullable
              as DefaultScreen,
      useCustomQuillToolbar: null == useCustomQuillToolbar
          ? _value.useCustomQuillToolbar
          : useCustomQuillToolbar // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      DefaultScreen defaultScreen,
      bool useCustomQuillToolbar});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? defaultScreen = null,
    Object? useCustomQuillToolbar = null,
  }) {
    return _then(_$SettingsStateImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      defaultScreen: null == defaultScreen
          ? _value.defaultScreen
          : defaultScreen // ignore: cast_nullable_to_non_nullable
              as DefaultScreen,
      useCustomQuillToolbar: null == useCustomQuillToolbar
          ? _value.useCustomQuillToolbar
          : useCustomQuillToolbar // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {this.themeMode = ThemeMode.system,
      this.defaultScreen = DefaultScreen.home,
      this.useCustomQuillToolbar = false});

  factory _$SettingsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsStateImplFromJson(json);

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final DefaultScreen defaultScreen;
  @override
  @JsonKey()
  final bool useCustomQuillToolbar;

  @override
  String toString() {
    return 'SettingsState(themeMode: $themeMode, defaultScreen: $defaultScreen, useCustomQuillToolbar: $useCustomQuillToolbar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.defaultScreen, defaultScreen) ||
                other.defaultScreen == defaultScreen) &&
            (identical(other.useCustomQuillToolbar, useCustomQuillToolbar) ||
                other.useCustomQuillToolbar == useCustomQuillToolbar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, themeMode, defaultScreen, useCustomQuillToolbar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsStateImplToJson(
      this,
    );
  }
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {final ThemeMode themeMode,
      final DefaultScreen defaultScreen,
      final bool useCustomQuillToolbar}) = _$SettingsStateImpl;

  factory _SettingsState.fromJson(Map<String, dynamic> json) =
      _$SettingsStateImpl.fromJson;

  @override
  ThemeMode get themeMode;
  @override
  DefaultScreen get defaultScreen;
  @override
  bool get useCustomQuillToolbar;
  @override
  @JsonKey(ignore: true)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
