#!/usr/bin/env bash
flutter pub get
(cd packages/dart_quill_delta && flutter pub get)
(cd packages/flutter_quill_extensions && flutter pub get)
(cd packages/flutter_quill_test && flutter pub get)
(cd packages/quill_html_converter && flutter pub get)
(cd packages/quill_pdf_converter && flutter pub get)
