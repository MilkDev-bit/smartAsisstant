import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartassistant_vendedor/models/compra.dart';
import 'package:smartassistant_vendedor/providers/compra_provider.dart';
import 'package:smartassistant_vendedor/widgets/contact_buttons.dart';

class CompraDetailScreen extends StatefulWidget {
  final Compra compra;
  const CompraDetailScreen({super.key, required this.compra});

  @override
  State<CompraDetailScreen> createState() => _CompraDetailScreenState();
}

class _CompraDetailScreenState extends State<CompraDetailScreen> {
  bool _isProcessing = false;

  void _evaluarFinanciamiento() async {
    final provider = Provider.of<CompraProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Evaluar Financiamiento'),
            content: const Text(
              '¿Estás seguro de que quieres evaluar el financiamiento de esta compra?\n\n'
              'Esta consultara a buró de crédito y evaluación bancaria.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => navigator.pop(false),
              ),
              TextButton(
                child: const Text('Evaluar'),
                onPressed: () => navigator.pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      _isProcessing = true;
    });

    final bool success = await provider.evaluarFinanciamiento(widget.compra.id);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Financiamiento evaluado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      final updatedCompra = await provider.getCompraById(widget.compra.id);
      if (updatedCompra != null && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CompraDetailScreen(compra: updatedCompra),
          ),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (context.mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _aprobarCompra(String status) async {
    final provider = Provider.of<CompraProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('$status Compra'),
            content: Text(
              '¿Estás seguro de que quieres $status esta compra?\n\n'
              'Esta acción notificará al cliente por email.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => navigator.pop(false),
              ),
              TextButton(
                child: Text(status),
                onPressed: () => navigator.pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      _isProcessing = true;
    });

    final dto = AprobarCompraDto(status: status);
    final bool success = await provider.aprobarCompra(widget.compra.id, dto);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compra ${status.toLowerCase()} exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (context.mounted) {
      setState(() {
        _isProcessing = false;
      });
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

  Widget _buildBuroInfo() {
    final buro = widget.compra.resultadoBuro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Score Crediticio', '${buro['score']}'),
        _buildDetailRow('Nivel de Riesgo', buro['nivelRiesgo'] ?? 'N/A'),
        if (buro['detalles'] != null) ...[
          const SizedBox(height: 8),
          const Text(
            'Detalles del Buró:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailRow('Historial de Pagos',
              buro['detalles']['historialPagos']['pagosATiempo'] ?? 'N/A'),
          _buildDetailRow('Cuentas Abiertas',
              '${buro['detalles']['cuentasAbiertas'] ?? 'N/A'}'),
          _buildDetailRow('Deudas Totales',
              '\$${buro['detalles']['deudasTotales']?.toString() ?? 'N/A'}'),
        ],
      ],
    );
  }

  Widget _buildBancoInfo() {
    final banco = widget.compra.resultadoBanco;
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    if (banco == null) {
      return const Text(
        'Financiamiento pendiente de evaluación',
        style: TextStyle(color: Colors.orange),
      );
    }

    if (banco['aprobado'] == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Estado', 'APROBADO', isBold: true),
          _buildDetailRow('Monto Aprobado',
              currencyFormatter.format(banco['montoAprobado'])),
          _buildDetailRow('Tasa de Interés',
              '${((banco['tasaInteres'] ?? 0) * 100).toStringAsFixed(1)}%'),
          _buildDetailRow(
              'Pago Mensual', currencyFormatter.format(banco['pagoMensual'])),
          _buildDetailRow('Plazo Aprobado', '${banco['plazoAprobado']} meses'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Estado', 'RECHAZADO', isBold: true),
          _buildDetailRow(
              'Motivo', banco['motivoRechazo'] ?? 'No especificado'),
          if (banco['sugerencias'] != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Sugerencias:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...(banco['sugerencias'] as List)
                .map((sug) =>
                    Text('• $sug', style: const TextStyle(fontSize: 12)))
                .toList(),
          ],
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');
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
                color: _getStatusColor(widget.compra.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(widget.compra.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.compra.status),
                    color: _getStatusColor(widget.compra.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado: ${widget.compra.status}',
                          style: TextStyle(
                            color: _getStatusColor(widget.compra.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getStatusDescription(widget.compra.status),
                          style: TextStyle(
                            color: _getStatusColor(widget.compra.status),
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
                title: Text(widget.compra.cliente.nombre),
                subtitle: Text(widget.compra.cliente.email),
              ),
              if (widget.compra.cliente.telefono != null &&
                  widget.compra.cliente.telefono!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(widget.compra.cliente.telefono!),
                ),
              const SizedBox(height: 8),
              ContactButtons(
                telefono: widget.compra.cliente.telefono,
                email: widget.compra.cliente.email,
              ),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Vehículo', [
              Text(
                widget.compra.cotizacion.coche.nombreCompleto,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('VIN:', widget.compra.cotizacion.coche.vin),
              _buildDetailRow(
                  'Precio:',
                  currencyFormatter
                      .format(widget.compra.cotizacion.precioCoche)),
              _buildDetailRow('Enganche:',
                  currencyFormatter.format(widget.compra.cotizacion.enganche)),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Información Financiera del Cliente', [
              _buildDetailRow(
                  'Ingreso Mensual',
                  currencyFormatter.format(
                      widget.compra.datosFinancieros['ingresoMensual'])),
              _buildDetailRow(
                  'Otros Ingresos',
                  currencyFormatter
                      .format(widget.compra.datosFinancieros['otrosIngresos'])),
              _buildDetailRow(
                  'Gastos Mensuales',
                  currencyFormatter.format(
                      widget.compra.datosFinancieros['gastosMensuales'])),
              _buildDetailRow(
                  'Deudas Actuales',
                  currencyFormatter.format(
                      widget.compra.datosFinancieros['deudasActuales'])),
              _buildDetailRow(
                  'Capacidad de Pago',
                  currencyFormatter
                      .format(widget.compra.datosFinancieros['capacidadPago'])),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Buró de Crédito', [
              _buildBuroInfo(),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Evaluación Bancaria', [
              _buildBancoInfo(),
            ]),
            const SizedBox(height: 20),
            if (widget.compra.estaEnRevision ||
                (widget.compra.estaAprobada &&
                    widget.compra.financiamientoAprobado)) ...[
              const Text(
                'Acciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.compra.estaEnRevision)
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: _isProcessing ? null : _evaluarFinanciamiento,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Evaluar Financiamiento'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              if (widget.compra.estaAprobada &&
                  widget.compra.financiamientoAprobado)
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () => _aprobarCompra('Completada'),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Marcar como Completada'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () => _aprobarCompra('Rechazada'),
                      child: const Text('Rechazar Compra'),
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
      case 'En revisión':
        return Colors.blue;
      case 'Aprobada':
        return Colors.green;
      case 'Rechazada':
        return Colors.red;
      case 'Completada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.pending_actions;
      case 'En revisión':
        return Icons.assessment;
      case 'Aprobada':
        return Icons.check_circle;
      case 'Rechazada':
        return Icons.cancel;
      case 'Completada':
        return Icons.verified;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Pendiente':
        return 'Esperando revisión inicial';
      case 'En revisión':
        return 'En proceso de evaluación de financiamiento';
      case 'Aprobada':
        return 'Financiamiento aprobado - Lista para completar';
      case 'Rechazada':
        return 'Compra rechazada';
      case 'Completada':
        return 'Compra finalizada exitosamente';
      default:
        return 'Estado desconocido';
    }
  }
}
