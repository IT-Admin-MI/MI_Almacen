class EstadoHerramienta {
  static const int prestado = 0;
  static const int devuelto = 1;

  static String nombre(int estado) {
    switch (estado) {
      case devuelto:
        return 'DEVUELTO';
      default:
        return 'PRESTADO';
    }
  }
}

class HerramientaPrestamo {
  final String id;
  final String nombre;
  final String? codigo;
  final String? comentario;

  final String? imagenPath; // ruta local (offline / preview inmediato)
  final String? imagenUrl;  // URL en Firebase Storage (una vez sincronizada)

  final String usuarioId;      // a quién fue prestada
  final String usuarioNombre;

  final String entregadoPorId;   // almacenista que la prestó
  final String entregadoPorNombre;

  final String? recibidoPorId;   // almacenista que la recibió de vuelta
  final String? recibidoPorNombre;

  final int estado; // EstadoHerramienta.prestado / devuelto

  final DateTime fechaPrestamo;
  final DateTime? fechaDevolucion;

  final int syncStatus; // 0 = pendiente de subir, 1 = sincronizado

  HerramientaPrestamo({
    required this.id,
    required this.nombre,
    this.comentario,
    this.imagenPath,
    this.imagenUrl,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.entregadoPorId,
    required this.entregadoPorNombre,
    this.recibidoPorId,
    this.recibidoPorNombre,
    required this.estado,
    required this.fechaPrestamo,
    this.fechaDevolucion,
    this.syncStatus = 0,
    this.codigo,
  });

  HerramientaPrestamo copyWith({
    String? id,
    String? nombre,
    String? codigo,
    String? comentario,
    String? imagenPath,
    String? imagenUrl,
    String? usuarioId,
    String? usuarioNombre,
    String? entregadoPorId,
    String? entregadoPorNombre,
    String? recibidoPorId,
    String? recibidoPorNombre,
    int? estado,
    DateTime? fechaPrestamo,
    DateTime? fechaDevolucion,
    int? syncStatus,
  }) {
    return HerramientaPrestamo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      comentario: comentario ?? this.comentario,
      imagenPath: imagenPath ?? this.imagenPath,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      entregadoPorId: entregadoPorId ?? this.entregadoPorId,
      entregadoPorNombre: entregadoPorNombre ?? this.entregadoPorNombre,
      recibidoPorId: recibidoPorId ?? this.recibidoPorId,
      recibidoPorNombre: recibidoPorNombre ?? this.recibidoPorNombre,
      estado: estado ?? this.estado,
      fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      syncStatus: syncStatus ?? this.syncStatus,
      codigo: codigo ?? this.codigo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'comentario': comentario,
      'imagen_path': imagenPath,
      'imagen_url': imagenUrl,
      'usuario_id': usuarioId,
      'usuario_nombre': usuarioNombre,
      'entregado_por_id': entregadoPorId,
      'entregado_por_nombre': entregadoPorNombre,
      'recibido_por_id': recibidoPorId,
      'recibido_por_nombre': recibidoPorNombre,
      'estado': estado,
      'fecha_prestamo': fechaPrestamo.toIso8601String(),
      'fecha_devolucion': fechaDevolucion?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory HerramientaPrestamo.fromMap(Map<String, dynamic> map) {
    return HerramientaPrestamo(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      comentario: map['comentario'] as String?,
      imagenPath: map['imagen_path'] as String?,
      imagenUrl: map['imagen_url'] as String?,
      usuarioId: map['usuario_id'] as String,
      usuarioNombre: map['usuario_nombre'] as String,
      entregadoPorId: map['entregado_por_id'] as String,
      entregadoPorNombre: map['entregado_por_nombre'] as String,
      recibidoPorId: map['recibido_por_id'] as String?,
      recibidoPorNombre: map['recibido_por_nombre'] as String?,
      estado: map['estado'] as int,
      fechaPrestamo: DateTime.parse(map['fecha_prestamo'] as String),
      fechaDevolucion: map['fecha_devolucion'] != null
          ? DateTime.parse(map['fecha_devolucion'] as String)
          : null,
      syncStatus: map['sync_status'] as int? ?? 0,
      codigo: map['codigo'] as String,
    );
  }

  factory HerramientaPrestamo.fromFirebase(Map<String, dynamic> data) {
    return HerramientaPrestamo(
      id: data['id'] ?? '',
      nombre: data['nombre'] ?? '',
      comentario: data['comentario'],
      imagenPath: null, // nunca viene de Firebase, es local del dispositivo
      imagenUrl: data['imagen_url'],
      usuarioId: data['usuario_id'] ?? '',
      usuarioNombre: data['usuario_nombre'] ?? '',
      entregadoPorId: data['entregado_por_id'] ?? '',
      entregadoPorNombre: data['entregado_por_nombre'] ?? '',
      recibidoPorId: data['recibido_por_id'],
      recibidoPorNombre: data['recibido_por_nombre'],
      estado: data['estado'] ?? EstadoHerramienta.prestado,
      fechaPrestamo: DateTime.parse(data['fecha_prestamo']),
      fechaDevolucion: data['fecha_devolucion'] != null
          ? DateTime.parse(data['fecha_devolucion'])
          : null,
      syncStatus: 1,
      codigo: data['codigo'] ?? '',
    );
  }
}