import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/models/cotizacion.dart';
import 'package:smartassistant_vendedor/providers/cotizacion_provider.dart';
import 'package:smartassistant_vendedor/widgets/contact_buttons.dart';

class CotizacionDetailScreen extends StatelessWidget {
  final Cotizacion cotizacion;
  const CotizacionDetailScreen({super.key, required this.cotizacion});

  void _updateStatus(BuildContext context, String status) async {
    final provider = Provider.of<CotizacionProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('$status Cotización'),
            content: Text(
              '¿Estás seguro de que quieres $status esta cotización?\n\n'
              'Esta acción notificará al cliente por email.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => navigator.pop(false),
              ),
              TextButton(
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Aprobar' ? Colors.green : Colors.red,
                  ),
                ),
                onPressed: () => navigator.pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    final bool success =
        await provider.updateCotizacionStatus(cotizacion.id, status);

    if (success && context.mounted) {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cotización ${status.toLowerCase()} exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(cotizacion.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(cotizacion.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(cotizacion.status),
                    color: _getStatusColor(cotizacion.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado: ${cotizacion.status}',
                          style: TextStyle(
                            color: _getStatusColor(cotizacion.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getStatusDescription(cotizacion.status),
                          style: TextStyle(
                            color: _getStatusColor(cotizacion.status),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard('Información del Cliente', [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(cotizacion.cliente.nombre),
                subtitle: Text(cotizacion.cliente.email),
              ),
              if (cotizacion.cliente.telefono != null &&
                  cotizacion.cliente.telefono!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(cotizacion.cliente.telefono!),
                ),
              const SizedBox(height: 8),
              ContactButtons(
                telefono: cotizacion.cliente.telefono,
                email: cotizacion.cliente.email,
              ),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Vehículo', [
              Text(
                cotizacion.coche.nombreCompleto,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('VIN:', cotizacion.coche.vin),
              _buildDetailRow('Marca:', cotizacion.coche.marca),
              _buildDetailRow('Modelo:', cotizacion.coche.modelo),
              _buildDetailRow('Año:', cotizacion.coche.ano.toString()),
              _buildDetailRow('Condición:', cotizacion.coche.condicion),
              _buildDetailRow(
                'Kilometraje:',
                '${numberFormatter.format(cotizacion.coche.kilometraje)} km',
              ),
              _buildDetailRow('Transmisión:', cotizacion.coche.transmision),
              _buildDetailRow('Motor:', cotizacion.coche.motor),
              _buildDetailRow('Color:', cotizacion.coche.color),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Detalles Financieros', [
              _buildDetailRow(
                'Precio del vehículo:',
                currencyFormatter.format(cotizacion.precioCoche),
              ),
              _buildDetailRow(
                'Enganche:',
                currencyFormatter.format(cotizacion.enganche),
              ),
              _buildDetailRow(
                'Monto a financiar:',
                currencyFormatter
                    .format(cotizacion.precioCoche - cotizacion.enganche),
              ),
              const Divider(height: 20),
              _buildDetailRow(
                'Plazo:',
                '${cotizacion.plazoMeses} meses',
              ),
              _buildDetailRow(
                'Tasa de interés anual:',
                '15%',
              ),
              _buildDetailRow(
                'Pago mensual estimado:',
                currencyFormatter.format(cotizacion.pagoMensual),
                isBold: true,
              ),
              const Divider(height: 20),
              _buildDetailRow(
                'Total a pagar:',
                currencyFormatter.format(cotizacion.totalPagado),
                isBold: true,
              ),
            ]),
            const SizedBox(height: 20),
            if (cotizacion.status == 'Pendiente') ...[
              const Text(
                'Acciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      onPressed: () => _updateStatus(context, 'Rechazada'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined),
                          SizedBox(width: 8),
                          Text('Rechazar'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.green.shade300),
                      ),
                      onPressed: () => _updateStatus(context, 'Aprobada'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text('Aprobar'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aprobada':
        return Colors.green;
      case 'Rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.pending_actions;
      case 'Aprobada':
        return Icons.check_circle;
      case 'Rechazada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Pendiente':
        return 'Esperando revisión del vendedor';
      case 'Aprobada':
        return 'Cotización aprobada - Contactar al cliente';
      case 'Rechazada':
        return 'Cotización rechazada';
      default:
        return 'Estado desconocido';
    }
  }
}
