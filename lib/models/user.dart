class ValidatedUser {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final bool twoFactorEnabled;

  ValidatedUser({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.twoFactorEnabled,
  });

  factory ValidatedUser.fromJson(Map<String, dynamic> json) {
    return ValidatedUser(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      nombre: json['nombre'],
      rol: json['rol'],
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'twoFactorEnabled': twoFactorEnabled,
    };
  }
}
