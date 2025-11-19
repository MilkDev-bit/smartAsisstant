class ValidatedUser {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final bool twoFactorEnabled;
  final String? fotoPerfil;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaNacimiento;
  final bool activo;

  ValidatedUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.twoFactorEnabled,
    this.fotoPerfil,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.activo = true,
  });

  factory ValidatedUser.fromJson(Map<String, dynamic> json) {
    return ValidatedUser(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      nombre: json['nombre'],
      rol: json['rol'],
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      fotoPerfil: json['fotoPerfil'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'twoFactorEnabled': twoFactorEnabled,
      'fotoPerfil': fotoPerfil,
      'telefono': telefono,
      'direccion': direccion,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'activo': activo,
    };
  }
}
