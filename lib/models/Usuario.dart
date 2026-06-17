class Usuario {
  final int? id;
  final String nombre;
  final String password;
  final String descripcion;
  final int rol;

  Usuario({
    this.id,
    required this.nombre,
    required this.password,
    required this.descripcion,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'password': password,
      'descripcion': descripcion,
      'rol': rol,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      password: map['password'],
      descripcion: map['descripcion'],
      rol: map['rol'],
    );
  }
}