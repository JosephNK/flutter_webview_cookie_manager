package com.josephnk.flutter_webview_cookie_manager;

import android.net.Uri;
import android.os.Build;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;

import java.net.HttpCookie;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterWebviewCookieManagerPlugin */
public class FlutterWebviewCookieManagerPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_webview_cookie_manager");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "hasCookies":
        hasCookies(result);
        break;
      case "getCookies":
        getCookies(call, result);
        break;
      case "setCookies":
        setCookies(call, result);
        break;
      case "clearCookies":
        clearCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // Method Get CookieManager
  private static CookieManager getCookieManager()  {
    // ref.,
    // https://github.com/facebook/react-native/pull/29089/files/9d0ef921fb36cb3c1b089bad5a132136f050b690#diff-f7ca1976002c4612051e4949395e64511b6f769e347c488e9a0d15cb5331fe76

    CookieManager mCookieManager;

    try {
      mCookieManager = CookieManager.getInstance();
    } catch (IllegalArgumentException ex) {
      // https://bugs.chromium.org/p/chromium/issues/detail?id=559720
      throw new IllegalArgumentException("Invalid argument. getInstance");
    } catch (Exception exception) {
      String message = exception.getMessage();
      // We cannot catch MissingWebViewPackageException as it is in a private / system API
      // class. This validates the exception's message to ensure we are only handling this
      // specific exception.
      // https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/webkit/WebViewFactory.java#348
      if (message != null && message.contains("WebView")) {
        throw new IllegalArgumentException("Invalid value. getInstance is null");
      } else {
        throw exception;
      }
    }

    return mCookieManager;
  }

  // Method Get CookieManager with Result Error
  private static CookieManager getCookieManagerWithResultError(final Result result) {
    CookieManager mCookieManager;

    try {
      mCookieManager = getCookieManager();
    } catch (Exception exception) {
      String message = exception.getMessage();
      result.error("CookieManager.getInstance is exception", message, null);
      return null;
    }

    return mCookieManager;
  }

  // Method hasCookies
  private static void hasCookies(final Result result) {
    CookieManager cookieManager = getCookieManagerWithResultError(result);
    if (cookieManager != null) {
      final boolean hasCookies = cookieManager.hasCookies();
      result.success(hasCookies);
    }
  }

  // Method clearCookies
  private static void clearCookies(final Result result) {
    CookieManager cookieManager = getCookieManagerWithResultError(result);
    if (cookieManager != null) {
      final boolean hasCookies = cookieManager.hasCookies();
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        cookieManager.removeAllCookies(
                new ValueCallback<Boolean>() {
                  @Override
                  public void onReceiveValue(Boolean value) {
                    result.success(hasCookies);
                  }
                });
        cookieManager.flush();
      } else {
        cookieManager.removeAllCookie();
        result.success(hasCookies);
      }
    }
  }

  // Method GetCookies
  private static void getCookies(final MethodCall methodCall, final Result result) {
    if (!(methodCall.arguments() instanceof Map)) {
      result.error(
              "Invalid argument. Expected Map<String,String>, received "
                      + (methodCall.arguments().getClass().getSimpleName()),
              null,
              null);
      return;
    }

    final Map<String, String> arguments = methodCall.arguments();

    CookieManager cookieManager = getCookieManagerWithResultError(result);
    if (cookieManager != null) {
      final String url = arguments.get("url");
      final String allCookiesString = url == null ? null : cookieManager.getCookie(url);
      final ArrayList<String> individualCookieStrings = allCookiesString == null ?
              new ArrayList<String>()
              : new ArrayList<String>(Arrays.asList(allCookiesString.split(";")));

      ArrayList<Map<String, Object>> serializedCookies = new ArrayList<>();
      for (String cookieString : individualCookieStrings) {
        try {
          final HttpCookie cookie = HttpCookie.parse(cookieString).get(0);
          if (cookie.getDomain() == null) {
            cookie.setDomain(Uri.parse(url).getHost());
          }
          if (cookie.getPath() == null) {
            cookie.setPath("/");
          }
          serializedCookies.add(cookieToMap(cookie));
        } catch (IllegalArgumentException e) {
          // Cookie is invalid. Ignoring.
        }
      }

      result.success(serializedCookies);
    }
  }

  // Method SetCookies
  private static void setCookies(final MethodCall methodCall, final Result result) {
    if (!(methodCall.arguments() instanceof List)) {
      result.error(
              "Invalid argument. Expected List<Map<String,String>>, received "
                      + (methodCall.arguments().getClass().getSimpleName()),
              null,
              null);
      return;
    }

    final List<Map<String, Object>> serializedCookies = methodCall.arguments();

    CookieManager cookieManager = getCookieManagerWithResultError(result);
    if (cookieManager != null) {
      for (Map<String, Object> cookieMap : serializedCookies) {
        Object origin = cookieMap.get("origin");
        String domainString = origin instanceof String ? (String)origin : null;
        if (domainString == null) {
          Object domain = cookieMap.get("domain");
          domainString = domain instanceof String ? (String)domain : "";
        }
        final String value = cookieMap.get("asString").toString();
        cookieManager.setCookie(domainString, value);
      }

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        cookieManager.flush();
      }

      result.success(null);
    }
  }

  // Method cookieToMap
  private static Map<String, Object> cookieToMap(HttpCookie cookie) {
    final HashMap<String, Object> resultMap = new HashMap<>();
    resultMap.put("name", cookie.getName());
    resultMap.put("value", cookie.getValue());
    resultMap.put("path", cookie.getPath());
    resultMap.put("domain", cookie.getDomain());
    resultMap.put("secure", cookie.getSecure());

    if (!cookie.hasExpired() && !cookie.getDiscard() && cookie.getMaxAge() > 0) {
      // translate `max-age` to `expires` by computing future expiration date
      long expires = (System.currentTimeMillis() / 1000) + cookie.getMaxAge();
      resultMap.put("expires", expires);
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      resultMap.put("httpOnly", cookie.isHttpOnly());
    }

    return resultMap;
  }
}
