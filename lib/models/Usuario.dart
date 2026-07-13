class Usuario {
  final String? id;
  final String nombre;
  final String password;
  final String descripcion;
  final int rol;
  final String departamento;
  final String? fcmToken;
  final String? supervisorId;

  Usuario({
    required this.id,
    required this.nombre,
    required this.password,
    required this.descripcion,
    required this.rol,
    required this.departamento,
    this.fcmToken,
    this.supervisorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'password': password,
      'descripcion': descripcion,
      'departamento': departamento,
      'rol': rol,
      'fcmToken':fcmToken,
      'supervisorId':supervisorId,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      password: map['password']?? '',
      descripcion: map['descripcion']?? '',
      rol: map['rol'] ?? -1,
      fcmToken: map['fcmToken'] as String?,
      supervisorId: map['supervisorId'] as String?,
      departamento: map['departamento']?? '' ,

    );
  }
}