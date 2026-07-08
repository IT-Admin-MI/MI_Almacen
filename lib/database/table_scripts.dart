const String createUsuariosTable = '''
CREATE TABLE usuarios(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  password TEXT NOT NULL,
  departamento TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  rol INTEGER NOT NULL
)
''';

const String createProyectosTable = '''
CREATE TABLE proyectos(
  clave TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  orden INTEGER NOT NULL,
  status BOLEAN NOT NULL,
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
    liberado INTEGER NOT NULL
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
    descripcion TEXT,
    orden_compra TEXT NOT NULL,
    fecha_solicitud TEXT NOT NULL,
    fecha_entrega TEXT,
    estado INTEGER NOT NULL,
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
    unidad TEXT NOT NULL
);
''';

const String createHistorialComprasTable = '''
CREATE TABLE historial_compras(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    compra_id TEXT NOT NULL,
    fecha TEXT NOT NULL,
    usuario_nombre TEXT NOT NULL,
    accion TEXT NOT NULL,
    estado_anterior INTEGER,
    estado_nuevo INTEGER,
    comentario TEXT
);
''';