import 'package:flutter/foundation.dart';

import 'platform_info.dart';

class PlatformUtils {
  /// Forces the desktop or mobile layout, for tests and screenshots.
  @visibleForTesting
  static bool? debugIsDesktopOverride;

  static bool get isWeb => kIsWeb;

  static bool get isDesktop {
    final override = debugIsDesktopOverride;
    if (override != null) return override;
    if (kIsWeb) return false;
    return platformIsMacOS || platformIsWindows || platformIsLinux;
  }

  static bool get isMobile {
    if (kIsWeb) return false;
    return platformIsIOS || platformIsAndroid;
  }

  static bool get isMacOS => !kIsWeb && platformIsMacOS;

  static bool get isWindows => !kIsWeb && platformIsWindows;

  static bool get isLinux => !kIsWeb && platformIsLinux;

  static bool get isIOS => !kIsWeb && platformIsIOS;

  static bool get isAndroid => !kIsWeb && platformIsAndroid;
}
