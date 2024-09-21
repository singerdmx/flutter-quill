#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint quill_native_bridge.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'quill_native_bridge'
  s.version          = '0.0.1'
  s.summary          = 'A plugin for flutter_quill'
  s.description      = <<-DESC
An internal plugin for flutter_quill package to access platform-specific APIs.
                       DESC
  s.homepage         = 'https://github.com/singerdmx/flutter-quill'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Quill' => 'https://github.com/singerdmx/flutter-quill' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'quill_native_bridge_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
