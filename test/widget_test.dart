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
            update: (context, auth, product, previous) =>
                CotizacionProvider(auth, product),
          ),
          ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
            create: (context) => TaskProvider(
              Provider.of<AuthProvider>(context, listen: false),
            ),
            update: (context, auth, previous) => TaskProvider(auth),
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
