class Compra {
  final int? id;
  final int proyectoClave;
  final String nombre;
  final String descripcion;
  final String ordenCompra;
  final DateTime fechaSolicitud;
  final DateTime? fechaEntrega;
  final String estado;

  Compra({
    this.id,
    required this.proyectoClave,
    required this.nombre,
    required this.descripcion,
    required this.ordenCompra,
    required this.fechaSolicitud,
    this.fechaEntrega,
    required this.estado,
  });
}