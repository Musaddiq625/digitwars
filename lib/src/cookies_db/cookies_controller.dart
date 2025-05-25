import 'dart:html';

class CookiesController {
  static void setCookie(String key, String value, {int days = 7}) {
    final expires = DateTime.now().add(Duration(days: days));
    // Format the date according to cookie date format specification
    final formattedDate = expires.toUtc().toString().replaceAll(' ', 'T');
    document.cookie = '$key=$value; expires=$formattedDate; path=/';
  }

  static String? getCookie(String key) {
    if (document.cookie == null || document.cookie!.isEmpty) {
      return null;
    }
    
    final cookies = document.cookie!.split(';');
    for (var cookie in cookies) {
      cookie = cookie.trim();
      final parts = cookie.split('=');
      if (parts.length == 2 && parts[0] == key) {
        return Uri.decodeComponent(parts[1]);
      }
    }
    return null;
  }
}