const createMaterialesDescripcionIndex = '''
CREATE INDEX idx_materiales_descripcion
ON materiales(descripcion)
''';

const createProyectosNombreIndex = '''
CREATE INDEX idx_proyectos_nombre
ON proyectos(nombre)
''';

const createValesFechaIndex = '''
CREATE INDEX idx_vales_fecha
ON vales(fecha_creacion)
''';

const createValesEstatusIndex = '''
CREATE INDEX idx_vales_estado
ON vales(estado)
''';

const createHistorialValeFechaIndex = '''
CREATE INDEX idx_historial_vale_fecha
ON historial_vales(fecha)
''';

const String createSolicitudesFechaIndex = '''
CREATE INDEX idx_solicitudes_fecha
ON solicitudes_compra(fecha_solicitud);
''';

const String createSolicitudesEstadoIndex = '''
CREATE INDEX idx_solicitudes_estado
ON solicitudes_compra(estado);
''';

const String createSolicitudesSolicitanteIndex = '''
CREATE INDEX idx_solicitudes_solicitante
ON solicitudes_compra(solicitante_id);
''';

const String createSolicitudesCompraIdIndex = '''
CREATE INDEX idx_solicitudes_compra
ON solicitudes_compra(compra_id);
''';

const String createComprasFechaSolicitudIndex = '''
CREATE INDEX idx_compras_fecha_solicitud
ON compras(fecha_solicitud);
''';

const String createComprasEstadoIndex = '''
CREATE INDEX idx_compras_estado
ON compras(estado);
''';

const String createComprasSolicitudIdIndex = '''
CREATE INDEX idx_compras_solicitud
ON compras(solicitud_id);
''';

const String createCompraItemsCompraIdIndex = '''
CREATE INDEX idx_compra_items_compra_id
ON compra_items(compra_id);
''';

const createMaterialSyncIndex = '''
CREATE INDEX idx_material_sync
ON materiales(sync_status)
''';

const createProyectoSyncIndex = '''
CREATE INDEX idx_proyecto_sync
ON proyectos(sync_status)
''';

const createValeSyncIndex = '''
CREATE INDEX idx_vale_sync
ON vales(sync_status)
''';

const String createHerramientasEstadoIndex = '''
CREATE INDEX idx_herramientas_estado
ON herramientas_prestamo(estado);
''';

const String createHerramientasUsuarioIndex = '''
CREATE INDEX idx_herramientas_usuario
ON herramientas_prestamo(usuario_id);
''';

const String createHerramientasSyncIndex = '''
CREATE INDEX idx_herramientas_sync
ON herramientas_prestamo(sync_status);
''';