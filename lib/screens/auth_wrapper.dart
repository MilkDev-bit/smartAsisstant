import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/screens/home_screen.dart';
import 'package:smartassistant_vendedor/screens/login_screen.dart';
import 'package:smartassistant_vendedor/screens/two_factor_screen.dart';
import 'package:smartassistant_vendedor/screens/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.authStatus) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.twoFactorRequired:
        return TwoFactorScreen(userId: authProvider.userIdFor2FA!);
      case AuthStatus.authenticating:
        return const SplashScreen(message: 'Iniciando sesión...');
      case AuthStatus.uninitialized:
      default:
        return const SplashScreen(message: 'Cargando...');
    }
  }
}
