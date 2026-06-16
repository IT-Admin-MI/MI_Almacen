class CompraItem {
  final int? id;
  final int compraId;
  final String materialClave;
  final String proyectoClave;
  final double cantidad;
  final String unidad;

  CompraItem({
    this.id,
    required this.compraId,
    required this.materialClave,
    required this.proyectoClave,
    required this.cantidad,
    required this.unidad,
  });
}