import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant/features/home/app_shell.dart';
import '../../core/api_service.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      authService.initializeAuthStatus(apiService);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authService.isLoggedIn) {
      return const AppShell();
    } else {
      return const LoginScreen();
    }
  }
}
