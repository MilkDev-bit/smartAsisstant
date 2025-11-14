import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/models/product.dart';
import 'package:smartassistant_vendedor/providers/product_provider.dart';
import 'package:smartassistant_vendedor/screens/product_detail_screen.dart';
import 'package:smartassistant_vendedor/screens/scanner_screen.dart';

class VinScannerButton extends StatefulWidget {
  const VinScannerButton({super.key});

  @override
  State<VinScannerButton> createState() => _VinScannerButtonState();
}

class _VinScannerButtonState extends State<VinScannerButton> {
  bool _isLoading = false;

  Future<void> _scanVIN(BuildContext context) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final String? scanResult = await navigator.push<String>(
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    );

    if (!mounted || scanResult == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Product coche = await productProvider.findByVin(scanResult);

      if (mounted) {
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(coche: coche),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showScannerHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 8),
            Text('Escáner VIN'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El escáner busca vehículos por su código VIN (Vehicle Identification Number).',
            ),
            SizedBox(height: 12),
            Text(
              '📍 Ubicación del VIN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Parabrisas inferior (lado del conductor)'),
            Text('• Puerta del conductor (marco de la puerta)'),
            Text('• Documentos del vehículo'),
            SizedBox(height: 12),
            Text(
              'El VIN es un código de 17 caracteres que identifica únicamente cada vehículo.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : PopupMenuButton<String>(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear VIN',
            onSelected: (value) {
              if (value == 'scan') {
                _scanVIN(context);
              } else if (value == 'help') {
                _showScannerHelp(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'scan',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner, size: 20),
                    SizedBox(width: 8),
                    Text('Escanear VIN'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Ayuda del Escáner'),
                  ],
                ),
              ),
            ],
          );
  }
}
