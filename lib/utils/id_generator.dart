class IdGenerator {

  static String generarValeId({
    required String nombre,
    required String departamento,
  }) {
    final now = DateTime.now();

    final fecha =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final hora =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '${now.millisecond.toString().padLeft(3, '0')}';

    return 'VALE_${fecha}_${hora}_${departamento.replaceAll(' ', '_')}_${nombre.replaceAll(' ', '_')}';
  }

  static String generarSolicitudCompraId({
    required String nombre,
  }) {
    final now = DateTime.now();

    final fecha =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final hora =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '${now.millisecond.toString().padLeft(3, '0')}';

    return 'SOLICITUD_${fecha}_${hora}_${nombre.replaceAll(' ', '_')}';
  }

  static String generarCompraItemId() {
    final now = DateTime.now();

    final fecha =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final hora =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '${now.millisecond.toString().padLeft(3, '0')}'
        '${now.microsecond.toString().padLeft(3, '0')}'; // evita colisión en agregados rápidos

    return 'ITEM_${fecha}_${hora}';
  }
}