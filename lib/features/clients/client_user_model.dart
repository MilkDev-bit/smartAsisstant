class ValidatedUser {
  final String id;
  final String email;
  final String rol;
  final String nombre;
  final bool twoFactorEnabled;

  ValidatedUser({
    required this.id,
    required this.email,
    required this.rol,
    required this.nombre,
    required this.twoFactorEnabled,
  });

  factory ValidatedUser.fromJson(Map<String, dynamic> json) {
    return ValidatedUser(
      id: json['_id'],
      email: json['email'],
      rol: json['rol'],
      nombre: json['nombre'],
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    );
  }
}
