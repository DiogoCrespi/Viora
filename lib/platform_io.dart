import 'dart:io' as io;

// This file is used when running on desktop platforms
class Platform {
  static bool get isDesktop =>
      io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS;
}
