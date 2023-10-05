import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_webview_cookie_manager_method_channel.dart';

abstract class FlutterWebviewCookieManagerPlatform extends PlatformInterface {
  /// Constructs a FlutterWebviewCookieManagerPlatform.
  FlutterWebviewCookieManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWebviewCookieManagerPlatform _instance =
      MethodChannelFlutterWebviewCookieManager();

  /// The default instance of [FlutterWebviewCookieManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWebviewCookieManager].
  static FlutterWebviewCookieManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWebviewCookieManagerPlatform] when
  /// they register themselves.
  static set instance(FlutterWebviewCookieManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> hasCookies() {
    throw UnimplementedError('hasCookies() has not been implemented.');
  }

  Future<List<Cookie>> getCookies(String? url) {
    throw UnimplementedError('getCookies() has not been implemented.');
  }

  Future<void> setCookies(List<Cookie> cookies, {String? origin}) {
    throw UnimplementedError('setCookies() has not been implemented.');
  }

  Future<void> clearCookies() async {
    throw UnimplementedError('clearCookies() has not been implemented.');
  }
}
