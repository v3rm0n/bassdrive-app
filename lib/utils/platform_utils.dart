import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// Forces the desktop or mobile layout, for tests and screenshots.
  @visibleForTesting
  static bool? debugIsDesktopOverride;

  static bool get isDesktop {
    final override = debugIsDesktopOverride;
    if (override != null) return override;
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }
}
