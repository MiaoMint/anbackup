import 'package:dio/dio.dart';

class GSMArena {
  static const String baseUrl = "https://www.gsmarena.com";
  static const String searchPhoneUrl = "$baseUrl/results.php3?sFreeText=";
  static const String searchTabletUrl =
      "$baseUrl/results.php3?mode=tablet&sFreeText=";
  static final _dio = Dio();

  static getImage(String brand, String marketname) async {
    try {
      var url = await _searchImage("$searchPhoneUrl$brand $marketname");
      if (url != null) {
        return url;
      }
      url = await _searchImage("$searchTabletUrl$brand $marketname");
      return url;
    } catch (e) {
      return null;
    }
  }

  static _searchImage(String url) async {
    final res = await _dio.get<String>(url);
    final imageUrl = _regImageUrl(res.data!);
    return imageUrl;
  }

  static String? _regImageUrl(String html) {
    final reg = RegExp(r"https://fdn2.gsmarena.com/vv/bigpic/(.+?).jpg");
    final match = reg.firstMatch(html);
    if (match != null) {
      return match.group(0);
    }
    return null;
  }

  // // 解密函数
  // static Future<String> decryptData({
  //   required String iv,
  //   required String key,
  //   required String data,
  // }) async {
  //   final encrypter = Encrypter(AES(Key.fromBase64(key), mode: AESMode.cbc));
  //   final data = encrypter.decryptBytes(
  //     IV.fromBase64(iv),
  //   );
  //   return Uint8List.fromList(data).toString();
  // }
}
