import 'package:flutter/foundation.dart';

class PlatformService {

  static bool get esWeb =>
      kIsWeb;

  static bool get usaSQLite =>
      !kIsWeb;

}
