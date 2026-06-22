class ValeEstado {

  static const pendiente = 0;

  static const aprobado = 1;

  static const rechazado = 2;

  static String nombre(
      int estado,
      ) {

    switch (estado) {

      case aprobado:
        return 'APROBADO';

      case rechazado:
        return 'RECHAZADO';

      default:
        return 'PENDIENTE';
    }
  }
}