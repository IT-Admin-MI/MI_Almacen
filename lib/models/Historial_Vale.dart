class HistorialVale {
  final int? id;
  final int valeId;
  final DateTime fecha;
  final int usuarioId;
  final String accion;
  final String estadoAnterior;
  final String estadoNuevo;
  final String comentario;

  HistorialVale({
    this.id,
    required this.valeId,
    required this.fecha,
    required this.usuarioId,
    required this.accion,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.comentario,
  });
}