#!/bin/bash

# Please make sure to run this script in the root directory of the repository and not inside sub-folders

echo ""

echo "Disable local development for flutter_quill..."
rm pubspec_overrides.yaml

echo ""

echo "Enable local development for flutter_quill_extensions..."
rm flutter_quill_extensions/pubspec_overrides.yaml

echo ""

echo "Enable local development for flutter_quill_test..."
rm flutter_quill_test/pubspec_overrides.yaml

echo ""

echo "Disable local development for all the other packages..."
rm packages/quill_html_converter/pubspec_overrides.yaml

echo ""

echo "Local development for all libraries has been disabled, please 'flutter pub get' for each one of them"