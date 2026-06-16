class ValeItem {
  final int? id;
  final int valeId;
  final String materialClave;
  final int proyectoId;
  final double cantidad;
  final String unidad;
  final String comentario;

  ValeItem({
    this.id,
    required this.valeId,
    required this.materialClave,
    required this.proyectoId,
    required this.cantidad,
    required this.unidad,
    required this.comentario,
  });
}