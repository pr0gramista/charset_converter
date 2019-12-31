#import "CharsetConverterPlugin.h"
#if __has_include(<charset_converter/charset_converter-Swift.h>)
#import <charset_converter/charset_converter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "charset_converter-Swift.h"
#endif

@implementation CharsetConverterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCharsetConverterPlugin registerWithRegistrar:registrar];
}
@end
