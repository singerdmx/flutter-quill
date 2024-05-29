#!/bin/bash

# The script must be run from the root project folder and not inside the scripts

# TODO: Refactor this to a dart script to allow developers who use Windows to use it

# Run Flutter analyze
echo "Running 'flutter analyze'..."
flutter analyze

# Run Flutter test
echo "Running 'flutter test'..."
flutter test

# Check if package is ready for publishing
echo "Running 'flutter pub publish --dry-run'..."
flutter pub publish --dry-run

# Apply Dart fixes
echo "Running 'dart fix --apply'..."
dart fix --apply

# Format Dart code
echo "Running 'dart format .'"
dart format .

# Check dart code formatting
echo "Running 'dart format --set-exit-if-changed .'"
dart format --set-exit-if-changed .

# Check flutter web example
echo "Running flutter build web --release --dart-define=CI=true."
(cd example && flutter build web --release --dart-define=CI=true)

echo ""

# Check the translations
echo "Running dart ./scripts/ensure_translations_correct.dart"
(dart ./scripts/ensure_translations_correct.dart)

echo ""

echo "Script completed."
