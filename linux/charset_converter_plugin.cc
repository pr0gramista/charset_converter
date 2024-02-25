#include "include/charset_converter/charset_converter_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define CHARSET_CONVERTER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), charset_converter_plugin_get_type(), \
                              CharsetConverterPlugin))

struct _CharsetConverterPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(CharsetConverterPlugin, charset_converter_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void charset_converter_plugin_handle_method_call(
    CharsetConverterPlugin *self,
    FlMethodCall *method_call)
{
  GError *error = nullptr;
  g_autoptr(FlMethodResponse) response = nullptr;
  FlValue *args = fl_method_call_get_args(method_call);
  const gchar *method = fl_method_call_get_name(method_call);

  if (strcmp(method, "encode") == 0)
  {
    /// encode(String charset, String data) -> Uint8List
    FlValue *charsetName = fl_value_lookup_string(args, "charset");
    FlValue *data = fl_value_lookup_string(args, "data");

    gchar *inputBytes =
        g_strdup_printf("%s", fl_value_get_uint8_list(data));
    gsize strlen = fl_value_get_length(data);
    GString *toUse = g_string_new_len(inputBytes, strlen);

    GIConv transferUnit;
    if ((transferUnit = g_iconv_open(fl_value_to_string(charsetName), "UTF-8")) == (GIConv)-1)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", "Charset not found.", nullptr));
      fl_method_call_respond(method_call, response, &error);
      g_iconv_close(transferUnit);
      return;
    }

    gsize written;
    gchar *toDecode = g_convert_with_iconv(
        toUse->str,
        toUse->len,
        transferUnit,
        NULL,
        &written,
        &error);

    if (toDecode == nullptr)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", error->message, nullptr));
      fl_method_call_respond(method_call, response, &error);
      g_iconv_close(transferUnit);
      return;
    }

    GByteArray *array = g_byte_array_new_take((guint8 *)toDecode, written);
    g_autoptr(FlValue) result = fl_value_new_uint8_list(array->data, array->len - 1);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    g_iconv_close(transferUnit);
  }
  else if (strcmp(method, "decode") == 0)
  {
    /// decode(String charset, Uint8List data) -> String
    FlValue *args = fl_method_call_get_args(method_call);
    FlValue *charsetName = fl_value_lookup_string(args, "charset");
    FlValue *data = fl_value_lookup_string(args, "data");

    gchar *toUse = (gchar *)fl_value_get_uint8_list(data);
    gsize charlen = fl_value_get_length(data);
    // g_string_append(charset, "//TRANSLIT");

    GIConv transferUnit;
    if ((transferUnit = g_iconv_open("UTF-8", fl_value_to_string(charsetName))) == (GIConv)-1)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", "Charset not found.", nullptr));
      fl_method_call_respond(method_call, response, &error);
      g_iconv_close(transferUnit);
      return;
    }

    gchar *toDecode = g_convert_with_iconv(
        toUse,
        charlen,
        transferUnit,
        NULL,
        NULL,
        &error);

    if (toDecode == nullptr)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("error_id", error->message, nullptr));
      fl_method_call_respond(method_call, response, &error);
      g_iconv_close(transferUnit);
      return;
    }

    GString *toReturn = g_string_new((const gchar *)toDecode);

    g_autoptr(FlValue) result = fl_value_new_string(toReturn->str);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    g_iconv_close(transferUnit);
  }
  else if (strcmp(method, "check") == 0)
  {
    FlValue *args = fl_method_call_get_args(method_call);
    FlValue *charsetName = fl_value_lookup_string(args, "charset");

    GIConv iconv_cd;
    if ((iconv_cd = g_iconv_open("UTF-8", fl_value_to_string(charsetName))) == (GIConv)-1)
    {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(false)));
    }
    else
    {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
    }
    g_iconv_close(iconv_cd);
  }
  else if (strcmp(method, "availableCharsets") == 0)
  {
    // Iconv supports a range of charsets, use [iconv --list] for detail.
    // Unfortunately there are too many, so I referred libiconv source code,
    // and copied their "summary".
    //
    // Reference: libiconv/libcharset/include
    const gchar *codelist[] = {
        "ASCII, ANSI_X3.4-1968",
        "ISO-8859-1 ",
        "ISO-8859-2",
        "ISO-8859-3",
        "ISO-8859-4",
        "ISO-8859-5",
        "ISO-8859-6",
        "ISO-8859-7",
        "ISO-8859-8",
        "ISO-8859-9",
        "ISO-8859-13",
        "ISO-8859-14",
        "ISO-8859-15",
        "KOI8-R",
        "KOI8-U",
        "KOI8-T",
        "CP437",
        "CP775",
        "CP850",
        "CP852",
        "CP855",
        "CP856",
        "CP857",
        "CP861",
        "CP862",
        "CP864",
        "CP865",
        "CP866",
        "CP869",
        "CP874",
        "CP922",
        "CP932",
        "CP943",
        "CP949",
        "CP950",
        "CP1046",
        "CP1124",
        "CP1125",
        "CP1129",
        "CP1131",
        "CP1250",
        "CP1251",
        "CP1252",
        "CP1253",
        "CP1254",
        "CP1255",
        "CP1256",
        "CP1257",
        "GB2312",
        "EUC-JP",
        "EUC-KR",
        "EUC-TW",
        "BIG5",
        "BIG5-HKSCS",
        "GBK",
        "GB18030",
        "SHIFT_JIS",
        "JOHAB",
        "TIS-620",
        "VISCII",
        "TCVN5712-1",
        "ARMSCII-8",
        "GEORGIAN-PS",
        "PT154",
        "HP-ROMAN8 ",
        "HP-ARABIC8",
        "HP-GREEK8 ",
        "HP-HEBREW8",
        "HP-TURKISH8",
        "HP-KANA8  ",
        "DEC-KANJI",
        "DEC-HANYU",
        "UTF-8"};

    FlValue *list = fl_value_new_list();

    for (int i = 0; i < sizeof(codelist) / sizeof(const gchar *); ++i)
    {
      fl_value_append(list, fl_value_new_string(codelist[i]));
    }

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(list));
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void charset_converter_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(charset_converter_plugin_parent_class)->dispose(object);
}

static void charset_converter_plugin_class_init(CharsetConverterPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = charset_converter_plugin_dispose;
}

static void charset_converter_plugin_init(CharsetConverterPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  CharsetConverterPlugin *plugin = CHARSET_CONVERTER_PLUGIN(user_data);
  charset_converter_plugin_handle_method_call(plugin, method_call);
}

void charset_converter_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  CharsetConverterPlugin *plugin = CHARSET_CONVERTER_PLUGIN(
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