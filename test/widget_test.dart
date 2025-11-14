import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/main.dart';
import 'package:smartassistant_vendedor/providers/auth_provider.dart';
import 'package:smartassistant_vendedor/providers/cotizacion_provider.dart';
import 'package:smartassistant_vendedor/providers/product_provider.dart';
import 'package:smartassistant_vendedor/providers/task_provider.dart';
import 'package:smartassistant_vendedor/screens/login_screen.dart';

void main() {
  testWidgets('Smoke test: La app debe arrancar y mostrar la LoginScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProxyProvider<AuthProvider, CotizacionProvider>(
            create: (context) => CotizacionProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, previous) => CotizacionProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
            create: (context) => TaskProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, previous) => TaskProvider(auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
            create: (context) => ProductProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, previous) => ProductProvider(auth),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    expect(find.text('Cotizaciones Pendientes'), findsNothing);
  });
}
