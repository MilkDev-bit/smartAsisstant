import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/screens/auth_wrapper.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/providers/cotizacion_provider.dart';
import 'package:smartassistant_vendedor/providers/task_provider.dart';
import 'package:smartassistant_vendedor/providers/product_provider.dart';
import 'package:smartassistant_vendedor/providers/user_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => ProductProvider(
                Provider.of<AuthProvider>(context, listen: false))),
        ChangeNotifierProxyProvider2<AuthProvider, ProductProvider,
            CotizacionProvider>(
          create: (context) => CotizacionProvider(
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<ProductProvider>(context, listen: false),
          ),
          update: (context, auth, product, previous) =>
              CotizacionProvider(auth, product),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) =>
              TaskProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => TaskProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) =>
              UserProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => UserProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartAssistant CRM - Vendedores',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
