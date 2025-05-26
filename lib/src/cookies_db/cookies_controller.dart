import 'package:digitwars_io/src/cookies_db/cookies_web.dart'
    if (dart.library.io) 'package:digitwars_io/src/cookies_db/shared_pref_mobile.dart'
    as cookie_handler;

abstract class CookiesController {
  Future<void> setValue(String key, String value, {int days = 7});
  Future<String?> getValue(String key);
}

class PlatformCookies implements CookiesController {
  String? _value;
  @override
  Future<void> setValue(String key, String value, {int days = 7}) async {
    _value = value;
    await cookie_handler.setValue(key, value, days: days);
  }

  @override
  Future<String?> getValue(String key) async {
    return _value ?? await cookie_handler.getValue(key);
  }
}
