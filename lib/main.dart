import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/providers/product_provider.dart';
import 'package:smartassistant_vendedor/providers/cotizacion_provider.dart';
import 'package:smartassistant_vendedor/providers/task_provider.dart';
import 'package:smartassistant_vendedor/providers/user_provider.dart';
import 'package:smartassistant_vendedor/providers/compra_provider.dart';
import 'package:smartassistant_vendedor/screens/auth_wrapper.dart';
import 'package:smartassistant_vendedor/providers/chat_provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smartassistant_vendedor/screens/reset_password_screen.dart';
import 'package:smartassistant_vendedor/screens/enter_token_screen.dart';
import 'package:smartassistant_vendedor/services/deep_link_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.initialize('6be7a393-fe66-4d7f-b626-56cf19b60580');

  OneSignal.Notifications.requestPermission(true);
  OneSignal.User.pushSubscription.optIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, ProductProvider,
            CotizacionProvider>(
          create: (context) => CotizacionProvider(
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<ProductProvider>(context, listen: false),
          ),
          update: (context, auth, product, previous) {
            if (previous == null) {
              return CotizacionProvider(auth, product);
            }

            previous.updateDependencies(auth, product);

            if (auth.isAuthenticated) {
              Future.microtask(() => previous.fetchCotizacionesPendientes());
            }

            return previous;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, CotizacionProvider,
            CompraProvider>(
          create: (context) => CompraProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, cotizacion, previous) => CompraProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => TaskProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => UserProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => ChatProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // Inicializar deep links después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.initDeepLinks(navigatorKey.currentContext!);
    });
  }

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
      routes: {
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          final token = args?['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
        '/enter-token': (context) => const EnterTokenScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
