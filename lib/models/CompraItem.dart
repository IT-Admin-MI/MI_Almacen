class CompraItem {
  final String? id;
  final String compraId;
  final String? materialClave;
  final String nombre;
  final String? proyectoClave;
  final double cantidad;
  final String unidad;

  CompraItem({
    this.id,
    required this.compraId,
    required this.materialClave,
    required this.nombre,
    required this.proyectoClave,
    required this.cantidad,
    required this.unidad,
  });

  CompraItem copyWith({
    String? id,
    String? compraId,
    String? materialClave,
    String? nombre,
    String? proyectoClave,
    double? cantidad,
    String? unidad,
  }) {
    return CompraItem(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      materialClave: materialClave ?? this.materialClave,
      nombre: nombre ?? this.nombre,
      proyectoClave: proyectoClave ?? this.proyectoClave,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'compra_id': compraId,
      'material_clave': materialClave,
      'nombre': nombre,
      'proyecto_clave': proyectoClave,
      'cantidad': cantidad,
      'unidad': unidad,
    };
  }

  factory CompraItem.fromMap(Map<String, dynamic> map) {
    print(map);

    map.forEach((key, value) {
      print('$key -> ${value.runtimeType} -> $value');
    });
    return CompraItem(
      id: map['id']?.toString(),
      compraId: map['compra_id'],
      materialClave: map['material_clave'],
      nombre: map['nombre'],
      proyectoClave: map['proyecto_clave'],
      cantidad: (map['cantidad'] as num).toDouble(),
      unidad: map['unidad'],
    );
  }
}