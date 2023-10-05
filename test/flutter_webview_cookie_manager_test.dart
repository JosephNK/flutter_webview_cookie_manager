import 'dart:_http';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webview_cookie_manager/flutter_webview_cookie_manager_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWebviewCookieManagerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWebviewCookieManagerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future<String>.value('0');

  @override
  Future<void> clearCookies() => Future<void>.value();

  @override
  Future<List<Cookie>> getCookies(String? url) =>
      Future<List<Cookie>>.value([]);

  @override
  Future<bool> hasCookies() => Future<bool>.value(true);

  @override
  Future<void> setCookies(List<Cookie> cookies, {String? origin}) =>
      Future<void>.value();
}

void main() {
  // final FlutterWebviewCookieManagerPlatform initialPlatform =
  //     FlutterWebviewCookieManagerPlatform.instance;
  //
  // test('$MethodChannelFlutterWebviewCookieManager is the default instance', () {
  //   expect(initialPlatform,
  //       isInstanceOf<MethodChannelFlutterWebviewCookieManager>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   FlutterWebviewCookieManager flutterWebviewCookieManagerPlugin =
  //       FlutterWebviewCookieManager();
  //   MockFlutterWebviewCookieManagerPlatform fakePlatform =
  //       MockFlutterWebviewCookieManagerPlatform();
  //   FlutterWebviewCookieManagerPlatform.instance = fakePlatform;
  //
  //   expect(await flutterWebviewCookieManagerPlugin.getPlatformVersion(), '42');
  // });
}
