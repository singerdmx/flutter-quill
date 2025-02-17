#!/usr/bin/env bash
(cd flutter_keyboard_visibility_platform_interface && flutter pub get)
(cd flutter_keyboard_visibility_web && flutter pub get)
(cd flutter_keyboard_visibility_linux && flutter pub get)
(cd flutter_keyboard_visibility_macos && flutter pub get)
(cd flutter_keyboard_visibility_windows && flutter pub get)
(cd flutter_keyboard_visibility && flutter pub get)
(cd flutter_keyboard_visibility/example && flutter pub get)
