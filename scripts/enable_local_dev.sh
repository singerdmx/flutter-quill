#!/bin/bash

# Please make sure to run this script in the root directory of the repository and not inside sub-folders

echo ""

echo "Enable local development for flutter_quill..."
cp pubspec_overrides.yaml.g pubspec_overrides.yaml

echo ""

echo "Enable local development for flutter_quill_extensions..."
cp flutter_quill_extensions/pubspec_overrides.yaml.g flutter_quill_extensions/pubspec_overrides.yaml

echo ""

echo "Enable local development for flutter_quill_test..."
cp flutter_quill_test/pubspec_overrides.yaml.g flutter_quill_test/pubspec_overrides.yaml

echo ""

echo "Enable local development for all the other packages..."
cp packages/flutter_quill_html/pubspec_overrides.yaml.g packages/flutter_quill_html/pubspec_overrides.yaml

echo ""

echo "Local development for all libraries has been enabled, please 'flutter pub get' for each one of them"