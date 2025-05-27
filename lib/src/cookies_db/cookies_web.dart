// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

Future<void> setValue(String key, String value, {int days = 7}) async {
  final expires = DateTime.now().add(Duration(days: days));
  // Format the date according to cookie date format specification
  final formattedDate = expires.toUtc().toString().replaceAll(' ', 'T');
  document.cookie = '$key=$value; expires=$formattedDate; path=/';
}

Future<String?> getValue(String key) async {
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
