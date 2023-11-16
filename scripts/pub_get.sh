#!/usr/bin/env bash
flutter pub get
(cd flutter_quill_extensions && flutter pub get)
(cd flutter_quill_test && flutter pub get)
(cd packages/quill_html_converter && flutter pub get)
