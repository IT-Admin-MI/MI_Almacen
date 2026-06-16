class HistorialCompra {
  final int? id;
  final int compraId;
  final DateTime fecha;
  final String estadoAnterior;
  final String estadoNuevo;
  final String comentario;

  HistorialCompra({
    this.id,
    required this.compraId,
    required this.fecha,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.comentario,
  });
}