#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint quill_native_bridge_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'quill_native_bridge_macos'
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
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
