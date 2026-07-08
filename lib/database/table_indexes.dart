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

const String createComprasFechaSolicitudIndex = '''
CREATE INDEX idx_compras_fecha_solicitud
ON compras(fecha_solicitud);
''';

const String createComprasEstadoIndex = '''
CREATE INDEX idx_compras_estado
ON compras(estado);
''';

const String createCompraItemsCompraIdIndex = '''
CREATE INDEX idx_compra_items_compra_id
ON compra_items(compra_id);
''';
