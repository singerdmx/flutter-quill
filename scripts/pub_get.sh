#!/usr/bin/env bash

# TODO: Refactor this to a dart script to allow developers who use Windows to use it

flutter pub get
(cd dart_quill_delta && flutter pub get)
(cd flutter_quill_extensions && flutter pub get)
(cd flutter_quill_test && flutter pub get)
