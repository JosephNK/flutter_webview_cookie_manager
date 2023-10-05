import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_webview_cookie_manager_platform_interface.dart';

/// An implementation of [FlutterWebviewCookieManagerPlatform] that uses method channels.
class MethodChannelFlutterWebviewCookieManager
    extends FlutterWebviewCookieManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_webview_cookie_manager');

  /// Gets whether there are stored cookies
  @override
  Future<bool> hasCookies() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('hasCookies');
      return result ?? false;
    } on PlatformException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Read out all cookies, or all cookies for a [url] when provided
  @override
  Future<List<Cookie>> getCookies(String? url) async {
    try {
      final results =
          await methodChannel.invokeListMethod<Map>('getCookies', {'url': url});
      if (results == null) {
        return <Cookie>[];
      }
      return results
          .map((Map result) {
            Cookie? c;
            try {
              final name = result['name'] ?? '';
              final value = _removeInvalidCharacter(result['value'] ?? '');
              c = Cookie(name, value)
                // following values optionally work on iOS only
                ..path = result['path']
                ..domain = result['domain']
                ..secure = result['secure'] ?? false
                ..httpOnly = result['httpOnly'] ?? true;

              if (result['expires'] != null) {
                c.expires = DateTime.fromMillisecondsSinceEpoch(
                    (result['expires'] * 1000).toInt());
              }
            } on FormatException catch (_) {
              c = null;
            }
            return c;
          })
          .whereType<Cookie>()
          .toList();
    } on PlatformException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Set [cookies] into the web view
  @override
  Future<void> setCookies(List<Cookie> cookies, {String? origin}) async {
    try {
      final transferCookies = cookies.map((Cookie c) {
        final output = <String, dynamic>{
          if (origin != null) 'origin': origin,
          'name': c.name,
          'value': c.value,
          'path': c.path,
          'domain': c.domain,
          'secure': c.secure,
          'httpOnly': c.httpOnly,
          'asString': c.toString(),
        };

        if (c.expires != null) {
          output['expires'] = c.expires!.millisecondsSinceEpoch ~/ 1000;
        }

        return output;
      }).toList();

      return methodChannel.invokeMethod<void>('setCookies', transferCookies);
    } on PlatformException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove all cookies
  @override
  Future<void> clearCookies() {
    try {
      return methodChannel.invokeMethod<void>('clearCookies');
    } on PlatformException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove cookies with [currentUrl] for IOS and Android
  Future<void> removeCookie(String currentUrl) async {
    final listCookies = await getCookies(currentUrl);
    final serializedCookies = listCookies
        .where((element) => element.domain != null
            ? currentUrl.contains(element.domain!)
            : false)
        .toList();
    for (var c in serializedCookies) {
      c.expires = DateTime.fromMicrosecondsSinceEpoch(0);
    }
    await setCookies(serializedCookies);
  }

  String _removeInvalidCharacter(String value) {
    // Remove Invalid Character
    var valueModified = value.replaceAll('\\"', "'").replaceAll("\\", "");
    valueModified = valueModified.replaceAll(String.fromCharCode(32), "");
    return valueModified;
  }
}
