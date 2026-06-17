class SesionUsuario {

  final String nombre;
  final int rol;

  SesionUsuario({
    required this.nombre,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'rol': rol,
    };
  }

  factory SesionUsuario.fromMap(
      Map<String, dynamic> map,
      ) {

    return SesionUsuario(
      nombre: map['nombre'],
      rol: int.parse(
        map['rol'].toString(),
      ),
    );
  }
}