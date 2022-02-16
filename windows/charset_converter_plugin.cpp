#include "include/charset_converter/charset_converter_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <winnls.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <iostream>
#include <algorithm>

using namespace std;

// These are derrived from https://docs.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
// We'll provide usable .NET labels for most charsets
const std::map<std::string, unsigned int> labels{
    {"ibm037", 037},
    {"ibm437", 437},
    {"ibm500", 500},
    {"asmo-708", 708},
    {"arabic-asmo-449", 709},
    {"transparent-arabic", 710},
    {"dos-720", 720},
    {"ibm737", 737},
    {"ibm775", 775},
    {"ibm850", 850},
    {"ibm852", 852},
    {"ibm855", 855},
    {"ibm857", 857},
    {"ibm00858", 858},
    {"ibm860", 860},
    {"ibm861", 861},
    {"dos-862", 862},
    {"ibm863", 863},
    {"ibm864", 864},
    {"ibm865", 865},
    {"cp866", 866},
    {"ibm869", 869},
    {"ibm870", 870},
    {"windows-874", 874},
    {"cp875", 875},
    {"shift_jis", 932},
    {"gb2312", 936},
    {"ks_c_5601-1987", 949},
    {"big5", 950},
    {"ibm1026", 1026},
    {"ibm01047", 1047},
    {"ibm01140", 1140},
    {"ibm01141", 1141},
    {"ibm01142", 1142},
    {"ibm01143", 1143},
    {"ibm01144", 1144},
    {"ibm01145", 1145},
    {"ibm01146", 1146},
    {"ibm01147", 1147},
    {"ibm01148", 1148},
    {"ibm01149", 1149},
    {"utf-16", 1200},
    {"unicodefffe", 1201},
    {"windows-1250", 1250},
    {"windows-1251", 1251},
    {"windows-1252", 1252},
    {"windows-1253", 1253},
    {"windows-1254", 1254},
    {"windows-1255", 1255},
    {"windows-1256", 1256},
    {"windows-1257", 1257},
    {"windows-1258", 1258},
    {"johab", 1361},
    {"macintosh", 10000},
    {"x-mac-japanese", 10001},
    {"x-mac-chinesetrad", 10002},
    {"x-mac-korean", 10003},
    {"x-mac-arabic", 10004},
    {"x-mac-hebrew", 10005},
    {"x-mac-greek", 10006},
    {"x-mac-cyrillic", 10007},
    {"x-mac-chinesesimp", 10008},
    {"x-mac-romanian", 10010},
    {"x-mac-ukrainian", 10017},
    {"x-mac-thai", 10021},
    {"x-mac-ce", 10029},
    {"x-mac-icelandic", 10079},
    {"x-mac-turkish", 10081},
    {"x-mac-croatian", 10082},
    {"utf-32", 12000},
    {"utf-32be", 12001},
    {"x-chinese_cns", 20000},
    {"x-cp20001", 20001},
    {"x_chinese-eten", 20002},
    {"x-cp20003", 20003},
    {"x-cp20004", 20004},
    {"x-cp20005", 20005},
    {"x-ia5", 20105},
    {"x-ia5-german", 20106},
    {"x-ia5-swedish", 20107},
    {"x-ia5-norwegian", 20108},
    {"us-ascii", 20127},
    {"x-cp20261", 20261},
    {"x-cp20269", 20269},
    {"ibm273", 20273},
    {"ibm277", 20277},
    {"ibm278", 20278},
    {"ibm280", 20280},
    {"ibm284", 20284},
    {"ibm285", 20285},
    {"ibm290", 20290},
    {"ibm297", 20297},
    {"ibm420", 20420},
    {"ibm423", 20423},
    {"ibm424", 20424},
    {"x-ebcdic-koreanextended", 20833},
    {"ibm-thai", 20838},
    {"koi8-r", 20866},
    {"ibm871", 20871},
    {"ibm880", 20880},
    {"ibm905", 20905},
    {"ibm00924", 20924},
    {"euc-jp", 20932},
    {"x-cp20936", 20936},
    {"x-cp20949", 20949},
    {"cp1025", 21025},
    {"koi8-u", 21866},
    {"iso-8859-1", 28591},
    {"iso-8859-2", 28592},
    {"iso-8859-3", 28593},
    {"iso-8859-4", 28594},
    {"iso-8859-5", 28595},
    {"iso-8859-6", 28596},
    {"iso-8859-7", 28597},
    {"iso-8859-8", 28598},
    {"iso-8859-9", 28599},
    {"iso-8859-13", 28603},
    {"iso-8859-15", 28605},
    {"x-europa", 29001},
    {"iso-8859-8-i", 38598},
    {"iso-2022-jp", 50220},
    {"csiso2022jp", 50221},
    {"iso-2022-jp", 50222},
    {"iso-2022-kr", 50225},
    {"x-cp50227", 50227},
    {"iso-2022-traditional-chinese", 50229},
    {"ebcdic-japanese-extended", 50930},
    {"ebcdic-us-canada-and-japanese", 50931},
    {"ebcdic-korean-extended-and-korean", 50933},
    {"ebcdic-simplified-chinese extended-and-simplified-chinese", 50935},
    {"ebcdic-simplified-chinese", 50936},
    {"ebcdic-us-canada-and-traditional-chinese", 50937},
    {"ebcdic-japanese-extended-and-japanese", 50939},
    {"euc-jp", 51932},
    {"euc-cn", 51936},
    {"euc-kr", 51949},
    {"euc traditional chinese", 51950},
    {"hz-gb-2312", 52936},
    {"gb18030", 54936},
    {"x-iscii-de", 57002},
    {"x-iscii-be", 57003},
    {"x-iscii-ta", 57004},
    {"x-iscii-te", 57005},
    {"x-iscii-as", 57006},
    {"x-iscii-or", 57007},
    {"x-iscii-ka", 57008},
    {"x-iscii-ma", 57009},
    {"x-iscii-gu", 57010},
    {"x-iscii-pa", 57011},
    {"utf-7", 65000},
    {"utf-8", 65001},
    // Aliases
    {"tis620", 874},
    {"iso-8859-11", 874},
    {"windows1250", 1250},
    {"windows1251", 1251},
    {"windows1252", 1252},
    {"windows1253", 1253},
    {"windows1254", 1254},
    {"windows1255", 1255},
    {"windows1256", 1256},
    {"windows1257", 1257},
    {"windows1258", 1258},
};

namespace
{
  struct CodePage
  {
    std::string name;
    unsigned int id;
  };

  class CharsetConverterPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    CharsetConverterPlugin();

    virtual ~CharsetConverterPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void CharsetConverterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "charset_converter",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<CharsetConverterPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  CharsetConverterPlugin::CharsetConverterPlugin() {}

  CharsetConverterPlugin::~CharsetConverterPlugin() {}

  string convertToMultiByte(const wstring &input, const int &codePage)
  {
    int input_size = (int)input.size();
    int size_needed = WideCharToMultiByte(codePage, 0, input.data(), input_size, NULL, 0, NULL, NULL);
    string final_string(size_needed, 0);
    int success = WideCharToMultiByte(codePage, 0, input.data(), input_size, &final_string[0], size_needed, NULL, NULL);

    if (success <= 0)
    {
      throw runtime_error("Could not convert to multi byte (ERROR CODE: " + std::to_string(GetLastError()) + ")");
    }

    return final_string;
  }

  wstring convertFromMultiByte(const string &input, const int &codePage)
  {
    int input_size = (int)input.size();
    int size_needed = MultiByteToWideChar(codePage, 0, input.data(), input_size, NULL, 0);
    wstring final_string(size_needed, 0);
    int success = MultiByteToWideChar(codePage, 0, input.data(), input_size, &final_string[0], size_needed);

    if (success <= 0)
    {
      throw runtime_error("Could not convert to wide char string (ERROR CODE: " + std::to_string(GetLastError()) + ")");
    }

    return final_string;
  }

  string toUtf8(const wstring &input)
  {
    return convertToMultiByte(input, CP_UTF8);
  }

  wstring fromUtf8(const string &input)
  {
    return convertFromMultiByte(input, CP_UTF8);
  }

  optional<CodePage> getCodePageForId(const unsigned int &id)
  {
    CPINFOEXW cpInfo;
    const int success = GetCPInfoExW(
        id,
        0,
        &cpInfo);

    if (success == 0)
    {
      return optional<CodePage>();
    }

    string label;
    for (const auto &pair : labels)
    {
      if (pair.second == id)
      {
        label = pair.first;
      }
    }

    if (label.empty())
    {
      // Use Windows label when there isn't one in labels
      label = toUtf8(cpInfo.CodePageName);
    }

    const struct CodePage cp = {label, cpInfo.CodePage};
    return optional<CodePage>(cp);
  }
}

// Returns ID of code page by parsing the name and performing lookup
// The code page with returned ID might not exist.
optional<unsigned int> getCodePageIdForName(const std::string &name)
{
  try
  {
    return std::stoul(name);
  }
  catch (const std::invalid_argument)
  {
    string lowerCaseName = name;
    for (char &ch : lowerCaseName)
    {
      ch = (char)std::tolower(ch);
    }

    // First lookup the labels
    for (const auto &pair : labels)
    {
      if (pair.first == lowerCaseName)
      {
        return optional<unsigned int>(pair.second);
      }
    }

    for (unsigned int i = 0; i < 65555; i++)
    {
      const auto codePage = getCodePageForId(i);

      if (codePage.has_value() && codePage.value().name == name)
      {
        return optional<unsigned int>(codePage.value().id);
      }
    }
  }
  return optional<unsigned int>();
}

void CharsetConverterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
  std::string method_name = method_call.method_name();

  if (method_name.compare("encode") == 0)
  {
    const auto &map = std::get<flutter::EncodableMap>(*method_call.arguments());
    const auto &charsetName = std::get<std::string>(map.at(flutter::EncodableValue("charset")));
    const auto &data = std::get<std::string>(map.at(flutter::EncodableValue("data")));

    const auto codePageId = getCodePageIdForName(charsetName);
    if (!codePageId.has_value())
    {
      result->Error("charset_name_unrecognized");
      return;
    }

    const auto codePage = getCodePageForId(codePageId.value());
    if (!codePage.has_value())
    {
      result->Error("charset_not_found");
      return;
    }

    try
    {
      const auto inputUtf8 = fromUtf8(data);

      const auto outputString = convertToMultiByte(inputUtf8, codePageId.value());

      std::vector<uint8_t> output;
      for (auto c : outputString)
      {
        output.push_back((uint8_t)c);
      }

      result->Success(flutter::EncodableValue(output));
    }
    catch (std::runtime_error e)
    {
      result->Error("convertion_failed", string(e.what()));
      return;
    }
  }
  else if (method_name.compare("decode") == 0)
  {
    const auto &map = std::get<flutter::EncodableMap>(*method_call.arguments());
    const auto &charsetName = std::get<std::string>(map.at(flutter::EncodableValue("charset")));
    const auto &data = std::get<std::vector<uint8_t>>(map.at(flutter::EncodableValue("data")));

    const auto codePageId = getCodePageIdForName(charsetName);
    if (!codePageId.has_value())
    {
      result->Error("charset_name_unrecognized");
      return;
    }

    const auto codePage = getCodePageForId(codePageId.value());
    if (!codePage.has_value())
    {
      result->Error("charset_not_found");
      return;
    }

    std::string input;
    for (const auto i : data)
    {
      input.push_back((char)i);
    }

    try
    {
      const auto outputString = convertFromMultiByte(input, codePageId.value());

      const auto outputUtf8 = toUtf8(outputString);

      result->Success(flutter::EncodableValue(outputUtf8));
    }
    catch (std::runtime_error e)
    {
      result->Error("convertion_failed", string(e.what()));
      return;
    }
  }
  else if (method_name.compare("availableCharsets") == 0)
  {
    flutter::EncodableList list;
    for (unsigned int i = 0; i < 65555; i++)
    {
      const auto codePage = getCodePageForId(i);

      if (codePage.has_value())
      {
        list.push_back(flutter::EncodableValue(codePage.value().name));
      }
    }
    result->Success(list);
  }
  else if (method_name.compare("check") == 0)
  {
    const auto &map = std::get<flutter::EncodableMap>(*method_call.arguments());
    const auto &charsetName = std::get<std::string>(map.at(flutter::EncodableValue("charset")));

    const auto codePageId = getCodePageIdForName(charsetName);
    if (!codePageId.has_value())
    {
      result->Success(flutter::EncodableValue(false));
      return;
    }

    const auto codePage = getCodePageForId(codePageId.value());
    if (!codePage.has_value())
    {
      result->Success(flutter::EncodableValue(false));
      return;
    }
    result->Success(flutter::EncodableValue(true));
  }
  else
  {
    result->NotImplemented();
  }
} // namespace

void CharsetConverterPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  CharsetConverterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
