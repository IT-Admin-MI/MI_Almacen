import 'package:mi_almacen/models/Compra.dart';

const Map<EstadoCompra, String> estadoCompraLabels = {
  EstadoCompra.solicitado: 'Solicitado',
  EstadoCompra.cotizacion: 'Cotización',
  EstadoCompra.ocSolicitada: 'OC Solicitada',
  EstadoCompra.ocRealizada: 'OC Realizada',
  EstadoCompra.ocVerificada: 'OC Verificada',
  EstadoCompra.ocAutorizada: 'OC Autorizada',
  EstadoCompra.ocPagada: 'OC Pagada',
  EstadoCompra.productoEnviado: 'Producto Enviado',
  EstadoCompra.productoRecibido: 'Producto Recibido',
  EstadoCompra.factura: 'Factura',
  EstadoCompra.agregadoSistema: 'Agregado al Sistema',
  EstadoCompra.revisionSolicitante: 'Revisión Solicitante',
  EstadoCompra.liberada: 'Liberada',
};