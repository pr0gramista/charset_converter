#include "include/charset_converter/charset_converter_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <map>
#include <vector>
#include <string>
#include <iconv.h>

using namespace std;

#define CHARSET_CONVERTER_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), charset_converter_plugin_get_type(), \
                              CharsetConverterPlugin))

struct _CharsetConverterPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(CharsetConverterPlugin, charset_converter_plugin, g_object_get_type())

bool convert(char *buf,char *outbuf, size_t len, const char *from, const char *to)
{
  iconv_t iconv_cd;
  if ((iconv_cd = iconv_open(to, from)) == (iconv_t) -1) {
    printf("Cannot open iconv from %s to %s\n", from, to);
    return false;
  }

  char *inbuf = buf;
  size_t inlen = len;
  size_t outlen = len;
  size_t res = 0;

  while (inlen > 0 && outlen > 0) {
      res = iconv(iconv_cd, &inbuf, &inlen, &outbuf, &outlen);
      if (res == 0)
          break;

      if (res == (size_t) (-1)) {
        if (errno != EILSEQ && errno != EINVAL) {
            iconv_close(iconv_cd);
            *outbuf = '\0';

            return true;
        } else if (inbuf < outbuf) {
            iconv_close(iconv_cd);
            *outbuf = '\0';

            return true;
        }
    }
    
    if (inlen > 0 && outlen > 0) {
        *outbuf++ = *inbuf++;
        inlen--;
        outlen--;
    }
  }

  iconv_close(iconv_cd);
  *outbuf = '\0';
  return true;
}

// Called when a method call is received from Flutter.
static void charset_converter_plugin_handle_method_call(
    CharsetConverterPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  // Create error, in this case null
  g_autoptr(GError) error = nullptr;

  if (strcmp(method, "encode") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue *charsetName = fl_value_lookup_string(args, "charset");
    FlValue *data = fl_value_lookup_string(args, "data");

    gchar* from = (gchar*) malloc(strlen(from)+1);
    gchar* to = (gchar*) malloc(strlen(from)+1);
    strcpy(from, fl_value_to_string(data));
    auto res = convert(from, to, strlen(from)+1, "UTF-8", fl_value_to_string(charsetName));
    if(!res)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", "charset_name_unrecognized", nullptr));
      fl_method_call_respond(method_call, response, &error);
      return;
    }

    std::vector<uint8_t> output;
    for (int i=0; i<strlen(to); i++)
    {
      output.push_back((uint8_t)to[i]);
    }

    g_autoptr(FlValue) result = fl_value_new_uint8_list(&output[0], output.size());
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "decode") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue *charsetName = fl_value_lookup_string(args, "charset");
    FlValue *data = fl_value_lookup_string(args, "data");

    auto inputBytes = (gchar*)fl_value_get_uint8_list(data);
    std::string input;
    for (int i = 0; i < strlen(inputBytes); i++)
    {
      input.push_back((char)inputBytes[i]);
    }

    gchar* from = (gchar*) malloc(strlen(from)+1);
    gchar* to = (gchar*) malloc(strlen(from)+1);
    strcpy(from, input.c_str());
    auto res = convert(from, to, strlen(from) + 1, fl_value_to_string(charsetName), "UTF-8");
    if(!res)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", "charset_name_unrecognized", nullptr));
      fl_method_call_respond(method_call, response, &error);
      return;
    }

    std::string ready(to);
    g_autoptr(FlValue) result = fl_value_new_string(ready.c_str());
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "availableCharsets") == 0) {
    auto list = fl_value_new_list();
    fl_value_append(list, fl_value_new_string("Not available for Linux."));

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(list));
  } else if (strcmp(method, "check") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue *charsetName = fl_value_lookup_string(args, "charset");

    iconv_t iconv_cd;
    if ((iconv_cd = iconv_open("UTF-8", fl_value_to_string(charsetName))) == (iconv_t) -1) {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(false)));
      fl_method_call_respond(method_call, response, &error);
      return;
    }

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, &error);
}

static void charset_converter_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(charset_converter_plugin_parent_class)->dispose(object);
}

static void charset_converter_plugin_class_init(CharsetConverterPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = charset_converter_plugin_dispose;
}

static void charset_converter_plugin_init(CharsetConverterPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  CharsetConverterPlugin* plugin = CHARSET_CONVERTER_PLUGIN(user_data);
  charset_converter_plugin_handle_method_call(plugin, method_call);
}

void charset_converter_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  CharsetConverterPlugin* plugin = CHARSET_CONVERTER_PLUGIN(
      g_object_new(charset_converter_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "charset_converter",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
