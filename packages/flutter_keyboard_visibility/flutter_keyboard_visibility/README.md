# Flutter Keyboard Visibility
[![pub package](https://img.shields.io/pub/v/flutter_keyboard_visibility.svg?label=flutter_keyboard_visibility&color=blue)](https://pub.dev/packages/flutter_keyboard_visibility)
[![codecov](https://codecov.io/gh/MisterJimson/flutter_keyboard_visibility/branch/master/graph/badge.svg)](https://codecov.io/gh/MisterJimson/flutter_keyboard_visibility)

React to keyboard visibility changes.

### Note about Flutter Web support

Web support is an open issue [here](https://github.com/MisterJimson/flutter_keyboard_visibility/issues/10). Currently this library will just return `false` for keyboard visibility on web.

## Install
[Install the package](https://pub.dev/packages/flutter_keyboard_visibility/install)
## Usage: React to Keyboard Visibility Changes
### Option 1: Within your `Widget` tree using a builder
Build your Widget tree based on whether or not the keyboard is visible by using `KeyboardVisibilityBuilder`.
```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

/// In any of your widgets...
@override
Widget build(BuildContext context) {
  return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Text(
          'The keyboard is: ${isKeyboardVisible ? 'VISIBLE' : 'NOT VISIBLE'}',
        );
      }
  );
```
### Option 2: Within your `Widget` tree using a provider
Build your `Widget` tree based on whether or not the keyboard is
visible by including a `KeyboardVisibilityProvider` near the top
of your tree.
```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// Somewhere near the top of your tree...
@override
Widget build(BuildContext context) {
  return KeyboardVisibilityProvider(
    child: MyDemoPage(),
  );
}

// Within MyDemoPage...
@override
Widget build(BuildContext context) {
  final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
  return Text(
    'The keyboard is: ${isKeyboardVisible ? 'VISIBLE' : 'NOT VISIBLE'}',
  );
}
```

### Option 3: Direct query and subscription

Query and/or subscribe to keyboard visibility directly with the
`KeyboardVisibilityController` class.

```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';

late StreamSubscription<bool> keyboardSubscription;

@override
void initState() {
  super.initState();

  var keyboardVisibilityController = KeyboardVisibilityController();
  // Query
  print('Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

  // Subscribe
  keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
    print('Keyboard visibility update. Is visible: $visible');
  });
}

@override
void dispose() {
  keyboardSubscription.cancel();
  super.dispose();
}
```
## Usage: Dismiss keyboard on tap
Place a `KeyboardDismissOnTap` near the top of your `Widget` tree. When a user taps outside of the currently focused `Widget`, the `Widget` will drop focus and the keyboard will be dismissed.
```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// Somewhere near the top of your tree...
@override
Widget build(BuildContext context) {
  return KeyboardDismissOnTap(
    child: MyDemoPage(),
  );
}
```
By default `KeyboardDismissOnTap` will only dismiss taps not captured by other interactive `Widget`s, like buttons. If you would like to dismiss the keyboard for any tap, including taps on interactive `Widget`s, set `dismissOnCapturedTaps` to true.
```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// Somewhere near the top of your tree...
@override
Widget build(BuildContext context) {
  return KeyboardDismissOnTap(
    dismissOnCapturedTaps: true,
    child: MyDemoPage(),
  );
}
```
The `IgnoreKeyboardDismiss` `Widget` can be used to further refine which taps do and do not dismiss the keyboard. Checkout the example app for more detail.
## Testing
### Testing using mocks
`KeyboardVisibilityProvider` and `KeyboardVisibilityBuilder` accept a `controller` parameter that allow you to mock or replace the logic for reporting keyboard visibility updates.
```dart
@GenerateMocks([KeyboardVisibilityController])
void main() {
  testWidgets('It reports true when the keyboard is visible', (WidgetTester tester) async {
    // Pretend that the keyboard is visible.
    var mockController = MockKeyboardVisibilityController();
    when(mockController.onChange)
        .thenAnswer((_) => Stream.fromIterable([true]));
    when(mockController.isVisible).thenAnswer((_) => true);

    // Build a Widget tree and query KeyboardVisibilityProvider
    // for the visibility of the keyboard.
    bool? isKeyboardVisible;

    await tester.pumpWidget(
      KeyboardVisibilityProvider(
        controller: mockController,
        child: Builder(
          builder: (BuildContext context) {
            isKeyboardVisible =
                KeyboardVisibilityProvider.isKeyboardVisible(context);
            return SizedBox();
          },
        ),
      ),
    );

    // Verify that KeyboardVisibilityProvider reported that the
    // keyboard is visible.
    expect(isKeyboardVisible, true);
  });
}
```
### Testing with a global override 
Call `KeyboardVisibilityTesting.setVisibilityForTesting(false);` to set a custom value to use during `flutter test`. This is set globally and will override the standard logic of the native platform.
```dart
void main() {
  testWidgets('My Test', (WidgetTester tester) async {
    KeyboardVisibilityTesting.setVisibilityForTesting(true);
    await tester.pumpWidget(MyApp());
  });
}
```
