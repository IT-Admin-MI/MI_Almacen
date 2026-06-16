import 'package:sqflite/sqflite.dart';

class Migrations {

  static Future<void> migrate(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    if (oldVersion < 2) {

      // futuras migraciones

    }
  }
}