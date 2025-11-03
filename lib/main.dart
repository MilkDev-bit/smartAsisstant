import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/api_service.dart';
import 'features/auth/auth_service.dart';
import 'features/chat/chat_service.dart';
import 'features/clients/client_service.dart';
import 'features/settings/settings_service.dart';
import 'features/dashboard/dashboard_service.dart';
import 'features/store/product_service.dart';
import 'features/cart/cart_service.dart';
import 'features/orders/order_service.dart';
import 'features/admin/admin_service.dart';
import 'features/auth/auth_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _initialUriIsHandled = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, ApiService>(
          create: (context) =>
              ApiService(Provider.of<AuthService>(context, listen: false)),
          update: (_, auth, previousApiService) =>
              previousApiService!..updateAuth(auth),
        ),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProxyProvider<ApiService, DashboardService>(
          create: (context) =>
              DashboardService(Provider.of<ApiService>(context, listen: false)),
          update: (_, api, previous) => previous ?? DashboardService(api),
        ),
        ChangeNotifierProxyProvider2<AuthService, ApiService, SettingsService>(
          create: (context) => SettingsService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (_, auth, api, previous) =>
              previous ?? SettingsService(auth, api),
        ),
        ChangeNotifierProxyProvider<ApiService, ProductService>(
          create: (context) =>
              ProductService(Provider.of<ApiService>(context, listen: false)),
          update: (_, api, previous) => previous ?? ProductService(api),
        ),
        ChangeNotifierProxyProvider<ApiService, AdminService>(
          create: (context) =>
              AdminService(Provider.of<ApiService>(context, listen: false)),
          update: (_, api, previous) => previous ?? AdminService(api),
        ),
        ChangeNotifierProxyProvider2<AuthService, ApiService, ChatService>(
          create: (context) => ChatService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (_, auth, api, previous) =>
              previous ?? ChatService(auth, api),
        ),
        ChangeNotifierProxyProvider2<AuthService, ApiService, ClientService>(
          create: (context) => ClientService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (_, auth, api, previous) =>
              previous ?? ClientService(auth, api),
        ),
        ChangeNotifierProxyProvider2<AuthService, ApiService, OrderService>(
          create: (context) => OrderService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (_, auth, api, previous) =>
              previous ?? OrderService(auth, api),
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final Uri? initialUri = await _appLinks.getInitialLink();
        if (initialUri != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _processUri(initialUri);
          });
        }
      } catch (e) {
        debugPrint('Error obteniendo URI inicial: $e');
      }
    }
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (mounted) _processUri(uri);
    }, onError: (err) {
      if (mounted) debugPrint('Error en stream de links: $err');
    });
  }

  void _processUri(Uri uri) {
    if (uri.scheme == 'smartassistant' && uri.host == 'login-success') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            final authService =
                Provider.of<AuthService>(context, listen: false);
            final apiService = Provider.of<ApiService>(context, listen: false);

            authService.handleTokenFromDeepLink(apiService, token);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SmartAssistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
