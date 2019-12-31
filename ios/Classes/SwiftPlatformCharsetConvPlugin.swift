import Flutter
import UIKit

public class SwiftPlatformCharsetConvPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "platform_charset_conv", binaryMessenger: registrar.messenger())
    let instance = SwiftPlatformCharsetConvPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
