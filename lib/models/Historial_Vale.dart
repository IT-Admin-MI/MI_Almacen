class HistorialVale {

  final int? id;

  final String valeId;

  final DateTime fecha;

  final String usuarioNombre;

  final String accion;

  final String estadoAnterior;

  final String estadoNuevo;

  final String comentario;

  HistorialVale({
    this.id,
    required this.valeId,
    required this.fecha,
    required this.usuarioNombre,
    required this.accion,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.comentario,
  });

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'vale_id': valeId,
      'fecha': fecha.toIso8601String(),
      'usuario_nombre': usuarioNombre,
      'accion': accion,
      'estado_anterior': estadoAnterior,
      'estado_nuevo': estadoNuevo,
      'comentario': comentario,
    };
  }

  factory HistorialVale.fromMap(
      Map<String, dynamic> map,
      ) {

    return HistorialVale(
      id: map['id'],
      valeId: map['vale_id'],
      fecha: DateTime.parse(
        map['fecha'],
      ),
      usuarioNombre:
      map['usuario_nombre'],
      accion: map['accion'],
      estadoAnterior:
      map['estado_anterior'] ?? '',
      estadoNuevo:
      map['estado_nuevo'] ?? '',
      comentario:
      map['comentario'] ?? '',
    );
  }
}