import 'dart:io';

import 'flutter_webview_cookie_manager_platform_interface.dart';

class FlutterWebviewCookieManager {
  Future<String?> getPlatformVersion() {
    return FlutterWebviewCookieManagerPlatform.instance.getPlatformVersion();
  }

  Future<bool> hasCookies() {
    return FlutterWebviewCookieManagerPlatform.instance.hasCookies();
  }

  Future<List<Cookie>> getCookies(String? url) {
    return FlutterWebviewCookieManagerPlatform.instance.getCookies(url);
  }

  Future<void> setCookies(List<Cookie> cookies, {String? origin}) {
    return FlutterWebviewCookieManagerPlatform.instance
        .setCookies(cookies, origin: origin);
  }

  Future<void> clearCookies() {
    return FlutterWebviewCookieManagerPlatform.instance.clearCookies();
  }
}
