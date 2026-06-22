class IdGenerator {

  static String generarValeId() {

    final now =
    DateTime.now();

    return
      'VALE_'
          '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}'
          '_'
          '${now.microsecondsSinceEpoch}';
  }
}