#!/bin/bash

# Important: make sure to run the script in the root folder of the repo:
# ./scripts/renegerate-translations.sh
# otherwise the script could delete the wrong folder

echo ""

echo "Delete the current generated localizations..."
rm -rf lib/src/l10n/generated
echo ""

echo "Run flutter pub get.."
flutter pub get
echo ""

echo "Run flutter gen-l10n"
flutter gen-l10n
echo ""

echo ""
echo "Apply dart fixes to the newly generated files"
dart fix --apply

echo ""
echo "Formate the newly generated dart files"
dart format .