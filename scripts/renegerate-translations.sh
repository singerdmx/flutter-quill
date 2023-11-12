#!/bin/bash

# Important: make sure to run the script in the root folder of the repo:
# ./scripts/renegerate-translations.sh
# otherwise the script could delete the wrong folder

echo ""

echo "Run flutter pub get.."
flutter pub get
echo ""

echo "Remove the folder: lib/src/gen/flutter_gen"
rm -rf  lib/src/gen/flutter_gen

echo ""
echo "Copy the folder: ./.dart_tool/flutter_gen to lib/src/gen/"
cp -r ./.dart_tool/flutter_gen lib/src/gen/

echo ""
echo "Delete unnecessary file: lib/src/gen/flutter_gen/pubspec.yaml"
rm lib/src/gen/flutter_gen/pubspec.yaml

echo ""
echo "Apply dart fixes to the newly generated files"
dart fix --apply

echo ""
echo "Formate the newly generated dart files"
dart format .