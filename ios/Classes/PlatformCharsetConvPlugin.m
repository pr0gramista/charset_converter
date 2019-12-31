#import "PlatformCharsetConvPlugin.h"
#if __has_include(<platform_charset_conv/platform_charset_conv-Swift.h>)
#import <platform_charset_conv/platform_charset_conv-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "platform_charset_conv-Swift.h"
#endif

@implementation PlatformCharsetConvPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPlatformCharsetConvPlugin registerWithRegistrar:registrar];
}
@end
