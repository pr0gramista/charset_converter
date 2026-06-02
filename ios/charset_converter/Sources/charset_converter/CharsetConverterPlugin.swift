#if canImport(Flutter)
import Flutter
#elseif canImport(FlutterMacOS)
import FlutterMacOS
#endif
import CoreFoundation

public class CharsetConverterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(macOS)
    let messenger = registrar.messenger
    #else
    let messenger = registrar.messenger()
    #endif
    let channel = FlutterMethodChannel(name: "charset_converter", binaryMessenger: messenger)
    let instance = CharsetConverterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "encode") {
        // Those values are guaranteed by the Dart code
        let args = call.arguments as! [String:Any]

        let data = args["data"] as! NSString
        let encodingName = args["charset"] as! NSString

        let encodingCF = CFStringConvertIANACharSetNameToEncoding(encodingName)
        if encodingCF == kCFStringEncodingInvalidId {
            result(FlutterError(code: "missing_charset", message: "Charset could not be found", details: nil))
            return
        }
        let encoding = CFStringConvertEncodingToNSStringEncoding(encodingCF)

        let output = data.data(using: encoding)

        if output == nil {
            result(FlutterError(code: "encoding_failed", message: "Encoding failed, reason unknown", details: nil))
            return
        }

        result(FlutterStandardTypedData.init(bytes: output!))
    } else if (call.method == "decode") {
        // Those values are guaranteed by the Dart code
        let args = call.arguments as! [String:Any]

        let data = args["data"] as! FlutterStandardTypedData
        let encodingName = args["charset"] as! NSString

        let encodingCF = CFStringConvertIANACharSetNameToEncoding(encodingName)
        if encodingCF == kCFStringEncodingInvalidId {
            result(FlutterError(code: "missing_charset", message: "Charset could not be found", details: nil))
            return
        }
        let encoding = CFStringConvertEncodingToNSStringEncoding(encodingCF)

        let output = NSString.init(data: data.data, encoding: encoding)

        result(output)
    } else if (call.method == "check") {
        // Those values are guaranteed by the Dart code
        let args = call.arguments as! [String:Any]

        let encodingName = args["charset"] as! NSString

        let encodingCF = CFStringConvertIANACharSetNameToEncoding(encodingName)
        if encodingCF == kCFStringEncodingInvalidId {
          result(false)
        }
        result(true)
    } else if (call.method == "availableCharsets") {
        var array : Array<String> = []

        var c = CFStringGetListOfAvailableEncodings()
        while c?.pointee != kCFStringEncodingInvalidId {
          let encoding = c?.pointee
          if encoding != nil {
            let charsetName = CFStringConvertEncodingToIANACharSetName(encoding!)

            if charsetName != nil {
              array.append(charsetName! as String)
            }
          } else {
            print("Encoding is null")
          }
          c = c?.successor()
        }
        result(array)
    }
    result(FlutterMethodNotImplemented)
  }
}
