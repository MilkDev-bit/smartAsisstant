import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant_vendedor/models/product.dart';
import 'package:smartassistant_vendedor/screens/crear_cotizacion_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product coche;
  const ProductDetailScreen({super.key, required this.coche});

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                fontSize: isImportant ? 16 : 14,
                color: isImportant ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final numberFormatter = NumberFormat.decimalPattern('es_MX');

    return Scaffold(
      appBar: AppBar(
        title: Text(coche.nombreCompleto),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coche.imageUrl != null && coche.imageUrl!.isNotEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(coche.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.car_rental,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildDetailSection('Información General', [
                    _buildDetailItem('VIN', coche.vin),
                    _buildDetailItem('Marca', coche.marca),
                    _buildDetailItem('Modelo', coche.modelo),
                    _buildDetailItem('Año', coche.ano.toString()),
                    _buildDetailItem('Condición', coche.condicion),
                    _buildDetailItem('Tipo', coche.tipo),
                  ]),
                  _buildDetailSection('Especificaciones Técnicas', [
                    _buildDetailItem('Motor', coche.motor),
                    _buildDetailItem('Transmisión', coche.transmision),
                    _buildDetailItem('Color', coche.color),
                    _buildDetailItem(
                        'Número de Puertas', coche.numPuertas.toString()),
                    _buildDetailItem('Kilometraje',
                        '${numberFormatter.format(coche.kilometraje)} km'),
                  ]),
                  if (coche.descripcion.isNotEmpty)
                    _buildDetailSection('Descripción', [
                      Text(
                        coche.descripcion,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ]),
                  _buildDetailSection('Precio', [
                    _buildDetailItem(
                      'Precio Base',
                      currencyFormatter.format(coche.precioBase),
                      isImportant: true,
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CrearCotizacionScreen(coche: coche),
                  ),
                );
              },
              child: const Text(
                'Generar Cotización para este Vehículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
