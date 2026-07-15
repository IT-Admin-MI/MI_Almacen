const String createUsuariosTable = '''
CREATE TABLE usuarios(
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  password TEXT NOT NULL,
  departamento TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  rol INTEGER NOT NULL,
  fcmToken TEXT NOT NULL,
  supervisorId TEXT NOT NULL
)
''';

const String createProyectosTable = '''
CREATE TABLE proyectos(
  clave TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  orden INTEGER NOT NULL,
  status BOLEAN NOT NULL,
  tipo INTEGER,
  fechaEntrega TEXT
)
''';

const String createMaterialesTable = '''
CREATE TABLE materiales(
  codigo TEXT PRIMARY KEY,
  descripcion TEXT NOT NULL,
  existencia REAL NOT NULL,
  tipo TEXT NOT NULL,
  updated_at TEXT,
  sync_status INTEGER DEFAULT 0
)
''';

const String createValesTable = '''
CREATE TABLE vales(
    id TEXT PRIMARY KEY,
    fecha_creacion TEXT NOT NULL,
    usuario_nombre TEXT NOT NULL,
    usuario_rol INTEGER NOT NULL,
    estado INTEGER NOT NULL,
    departamento TEXT NOT NULL,
    fecha_validacion TEXT,
    validado_por TEXT,
    comentario_validacion TEXT,
    sync_status INTEGER NOT NULL,
    liberado INTEGER NOT NULL,
    fecha_liberacion TEXT
);
''';

const String createValeItemsTable = '''
CREATE TABLE vale_items(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vale_id TEXT NOT NULL,
    material_codigo TEXT NOT NULL,
    material_descripcion TEXT NOT NULL,
    proyecto_clave TEXT,
    proyecto_nombre TEXT,
    cantidad REAL NOT NULL,
    unidad TEXT NOT NULL,
    comentario_vale TEXT
);
''';

const String createHistorialValesTable = '''
CREATE TABLE historial_vales(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vale_id TEXT NOT NULL,
    fecha TEXT NOT NULL,
    usuario_nombre TEXT NOT NULL,
    accion TEXT NOT NULL,
    estado_anterior TEXT,
    estado_nuevo TEXT,
    comentario TEXT
);
''';

const createAppConfigTable = '''
CREATE TABLE app_config(
    codigo TEXT PRIMARY KEY,
    valor TEXT
)
''';

const String createComprasTable = '''
CREATE TABLE compras(
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    comentario TEXT,
    solicitud_id TEXT NOT NULL,
    orden_compra TEXT NOT NULL,
    tipo_compra INTEGER NOT NULL,
    comprador_id TEXT NOT NULL,
    fecha_solicitud TEXT NOT NULL,
    fecha_entrega TEXT,
    estado INTEGER NOT NULL,
    requiere_revision_solicitante INTEGER NOT NULL,
    revision_solicitante_realizada INTEGER NOT NULL,
    fecha_revision_solicitante TEXT,
    usuario_revision_id TEXT,
    liberada INTEGER NOT NULL,
    fecha_liberacion TEXT,
    almacenista_id TEXT,
    estatus INTEGER NOT NULL,
    sync_status INTEGER NOT NULL
);
''';

const String createCompraItemsTable = '''
CREATE TABLE compra_items(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    compra_id TEXT NOT NULL,
    material_clave TEXT,
    nombre TEXT NOT NULL,
    proyecto_clave TEXT,
    cantidad REAL NOT NULL,
    unidad TEXT NOT NULL,
    observaciones TEXT,
    numero_parte TEXT
);
''';

const String createSolicitudesCompraTable = '''
CREATE TABLE solicitudes_compra(
    id TEXT PRIMARY KEY,
    solicitante_id TEXT NOT NULL,
    fecha_solicitud TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    requiere_revision_solicitante INTEGER NOT NULL,
    estado INTEGER NOT NULL,
    motivo_rechazo TEXT,
    comprador_id TEXT,
    compra_id TEXT,
    sync_status INTEGER
);
''';

const String createHistorialComprasTable = '''
CREATE TABLE historial_compras(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    compra_id TEXT NOT NULL,
    fecha TEXT NOT NULL,
    usuario_id TEXT,
    usuario_nombre TEXT NOT NULL,
    accion TEXT NOT NULL,
    estado_anterior INTEGER,
    estado_nuevo INTEGER,
    comentario TEXT
);
''';

const String createHerramientasPrestamoTable = '''
CREATE TABLE herramientas_prestamo(
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    codigo TEXT,
    comentario TEXT,
    imagen_path TEXT,
    imagen_url TEXT,
    usuario_id TEXT NOT NULL,
    usuario_nombre TEXT NOT NULL,
    entregado_por_id TEXT NOT NULL,
    entregado_por_nombre TEXT NOT NULL,
    recibido_por_id TEXT,
    recibido_por_nombre TEXT,
    estado INTEGER NOT NULL,
    fecha_prestamo TEXT NOT NULL,
    fecha_devolucion TEXT,
    sync_status INTEGER NOT NULL
);
''';