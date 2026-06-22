class Material {
  final String codigo;

  final String descripcion;

  final double existencia;

  final String tipo;

  final DateTime? updatedAt;

  final int? syncStatus;

  Material({
    required this.codigo,
    required this.descripcion,
    required this.tipo,
    required this.existencia,
    required this.updatedAt,
    required this.syncStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descripcion': descripcion,
      'tipo': tipo,
      'existencia': existencia,
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      codigo: map['codigo'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      existencia: (map['existencia'] as num).toDouble(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      syncStatus: map['sync_status'] ?? 0,
    );
  }
}