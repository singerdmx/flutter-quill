## [6.0.0] - December 19, 2023
* 5.4.3 republished as a new major version. The Android Gradle changes were breaking for some users so 5.4.3 was unpublished. Using this version may require you to update your Android Gradle version.

## [5.4.3] - May 20, 2023
Thanks to fabricio-godoi for reporting this issue.

* Fixed compatibility with Gradle 7 Android projects (support for Gradle 8 remains in place)

## [5.4.2] - May 11, 2023
Thanks to davidmartos96 for help with this release

* Add compatibility with AGP 8 (Android Gradle Plugin).
* Removed implicit-casts lint warning as it's no longer supported

## [5.4.1] - March 26, 2023

* Fixed `NSLocationWhenInUseUsageDescription` warning on iOS

## [5.4.0] - October 4, 2022
Thanks to cbenhagen for this feature

* Add endorsed stubs for Linux, macOS, and Windows.

## [5.3.0] - June 13, 2022

* Updated testing docs and made minor changes to allow to easier testing. See readme for details.

## [5.2.0] - February 15, 2022
Thanks to Andrflor for help with this feature release

* Added `dismissOnCapturedTaps` option to KeyboardDismissOnTap
* Added `IgnoreKeyboardDismiss` Widget

## [5.1.1] - January 13, 2022
Thanks to jpeiffer for this fix

* Updated Android tooling versions
* Replaced jcenter with mavenCentral

## [5.1.0] - October 15, 2021

* Removed Android v1 Embedding Support. If you created your Android project before Flutter 1.12 you
may need to recreate or migrate. https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration

## [5.0.3] - July 20, 2021

* Updated documentation
* Reverted the change made in 4.0.4 that changed how keyboard visibility is done on Android

## [5.0.2] - April 16, 2021

* Updated documentation

## [5.0.1] - April 16, 2021

* Updated Android target/compile SDK versions to 30
* Updated Android gradle build tools to 3.6.4
* Updated AndroidX Core to 1.5.0-rc01

## [5.0.0] - March 4, 2021

* Updated dependencies & release stable null safe version 

## [5.0.0-nullsafety.3] - February 26, 2021

* Fixed onChange notifying the same value multiple times on Android
* Fixed bug introduced in 4.0.5 that would cause keyboard changes not to be notified

## [5.0.0-nullsafety.2] - February 18, 2021

* Improve Android implementation with WindowInsetsCompat

## [5.0.0-nullsafety.1] - November 30, 2020

* Remove Android X import and annotations in Android code to reduce possibility of build errors

## [5.0.0-nullsafety.0] - November 30, 2020

* Migrated to null safety
* Removed deprecated KeyboardVisibility static access APIs

## [4.0.6] - February 26, 2021

* Fixed bug introduced in 4.0.5 that would cause keyboard changes not to be notified

## [4.0.5] - February 26, 2021

* Fixed onChange notifying the same value multiple times on Android 

## [4.0.4] - February 18, 2021

* Improve Android implementation with WindowInsetsCompat

## [4.0.3] - February 1, 2021

* Remove Android X import and annotations in Android code to reduce possibility of build errors

## [4.0.2] - November 24, 2020

* Update documentation

## [4.0.1] - November 23, 2020

* Update documentation

## [4.0.0] - November 23, 2020

* Federated the plugin to better support more platforms going forward
* Refactored internal implementation
* Deprecated KeyboardVisibility static access, will be removed in a future release
* Added KeyboardVisibilityController as a new way to access keyboard visibility
* KeyboardVisibilityBuilder & KeyboardVisibilityProvider now have `controller` parameters that allow
you to pass a mock implementation of KeyboardVisibilityController for testing.

## [3.3.0] - November 6, 2020

Thanks to lukepighetti for this feature

* Added `KeyboardVisibilityBuilder` to access keyboard visibility with the builder pattern

## [3.2.2] - August 26, 2020

* MissingPluginException if no longer thrown during `flutter test` if you first call `KeyboardVisibility.setVisibilityForTesting(value)` in your test

## [3.2.1] - June 22, 2020

Thanks to ram231 for this fix

* Fixed KeyboardDismissOnTap sometimes reopening the keyboard

## [3.2.0] - June 16, 2020

Thanks to matthew-carroll for this feature

* KeyboardDismissOnTap to allow for tapping outside of the focused field to dismiss the keyboard

## [3.1.0] - June 16, 2020

Thanks to matthew-carroll for these features and helping fix the bug

* KeyboardVisibilityProvider for InheritedWidget style access to keyboard visibility within the Widget tree
* Added setVisibilityForTesting to assist for testing with fake values
* Fixed visibility not being reporting on Android for apps with pre Flutter 1.12 Android projects

## [3.0.0] - June 2, 2020

* Migrated to new Android plugin APIs

## [2.0.0] - April 7, 2020

* Redesigned public API to be stream based.

## [0.8.0] - April 7, 2020

* Fixed visibility value not changing in Kotlin based Flutter apps

## [0.7.0] - September 19, 2019

* Forked the project as original repo stopped being updated
* Fix: ViewTreeObserver is unregister when start second Activity because onStop call delay
* Fix: Activity() returns null when using backgrounding flutter plugins
* AndroidX migration
* Remove reachability dependency

### The below changelog is from the original package 
## [0.5.6] - 13-05-2019

* added null check in Android layout callback
* changed behavior on dispose
* catching exceptions if callbacks are not unsubscribed properly

## [0.5.5] - 11-05-2019

* Changed README.md and formatted Dart code

## [0.5.4] - 11-05-2019

* Fixed plugin registration bug

## [0.5.3] - 09-05-2019

* Fixed exception call bug on dispose
* Change behavior of plugin registration

## [0.5.2] - 12-03-2019

* Fixed possible bug on dispose
* On iOS the keyboard pop up message is already being sent when keyboard starts popping up

## [0.5.1] - 06-01-2019

* Fixed bug when using multiple listeners on same page

## [0.5.0] - 06-12-2018

* Initial release, working on Android and iOS
