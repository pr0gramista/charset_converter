package pl.pr0gramista.charset_converter

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.ByteBuffer
import java.nio.charset.Charset

/** CharsetConverterPlugin */
class CharsetConverterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "charset_converter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "encode") {
      val buffer = Charset.forName(call.argument("charset")).encode(call.argument<String>("data"))
      val output = ByteArray(buffer.remaining());
      buffer.get(output)
      result.success(output)
    } else if (call.method == "decode") {
      result.success(Charset.forName(call.argument("charset")).decode(ByteBuffer.wrap(call.argument("data"))).toString())
    } else if (call.method == "availableCharsets") {
      result.success(Charset.availableCharsets().keys.filterNotNull().toList())
    } else if (call.method == "check") {
      try {
        val charset = Charset.forName(call.argument("charset"))

        result.success(charset != null)
      }
      catch (e: Exception) {
        result.success(false)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
