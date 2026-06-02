#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint charset_converter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'charset_converter'
  s.version          = '2.4.0'
  s.summary          = 'Charset/encoding converter that uses underlying platform'
  s.description      = <<-DESC
Encode and decode charsets using platform built-in converter. This saves app package size as you don't need any external charset maps or whole libraries like iconv. This package doesn't even contain any Dart dependencies. However this comes with the dependency on the platform.
                       DESC
  s.homepage         = 'http://github.com/pr0gramista/charset_converter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bartosz Wiśniewski' => 'kontakt@pr0gramista.pl' }
  s.source           = { :path => '.' }
  # FFI-only plugin: Dart calls CoreFoundation directly via dart:ffi.
  # A dummy source file is required so CocoaPods produces a valid pod target.
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.frameworks = 'CoreFoundation'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
