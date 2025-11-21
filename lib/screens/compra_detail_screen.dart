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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Evaluar Financiamiento'),
            content: const Text(
              '¿Estás seguro de que quieres evaluar el financiamiento de esta compra?\n\n'
              'Esta consultara a buró de crédito y evaluación bancaria.',
            ),
            actions: [
              TextButton(
                child:
                    Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
                onPressed: () => navigator.pop(false),
              ),
              TextButton(
                child: const Text('Evaluar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
        SnackBar(
          content: const Text('Financiamiento evaluado exitosamente'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('$status Compra'),
            content: Text(
              '¿Estás seguro de que quieres $status esta compra?\n\n'
              'Esta acción notificará al cliente por email.',
            ),
            actions: [
              TextButton(
                child:
                    Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
                onPressed: () => navigator.pop(false),
              ),
              TextButton(
                child: Text(status,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      navigator.pop();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 16 : 14,
                color: isBold ? const Color(0xFF1A1F2E) : Colors.black87,
              ),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Crediticio',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${buro['score']}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  buro['nivelRiesgo'] ?? 'N/A',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (buro['detalles'] != null) ...[
          const SizedBox(height: 16),
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

    // Si no hay resultados aún
    if (banco == null || banco.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.pending, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Financiamiento pendiente de evaluación',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final aprobado = banco['aprobado'] == true;

    // 📌 Si fue aprobado
    if (aprobado) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  'APROBADO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Monto Aprobado',
            currencyFormatter.format(banco['montoAprobado'] ?? 0),
          ),
          _buildDetailRow(
            'Tasa de Interés',
            '${((banco['tasaInteres'] ?? 0) * 100).toStringAsFixed(1)}%',
          ),
          _buildDetailRow(
            'Pago Mensual',
            currencyFormatter.format(banco['pagoMensual'] ?? 0),
            isBold: true,
          ),
          _buildDetailRow(
            'Plazo Aprobado',
            '${banco['plazoAprobado'] ?? 0} meses',
          ),
        ],
      );
    }

    // ❌ Si fue rechazado
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.red.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'RECHAZADO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Motivo',
          banco['motivoRechazo'] ?? 'No especificado',
        ),
        if (banco['sugerencias'] != null && banco['sugerencias'] is List) ...[
          const SizedBox(height: 12),
          Text(
            'Sugerencias:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...(banco['sugerencias'] as List).map(
            (sug) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.grey[600])),
                  Expanded(
                    child: Text(
                      sug.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1F2E),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Detalle de Compra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(widget.compra.status)
                                    .withOpacity(0.15),
                                _getStatusColor(widget.compra.status)
                                    .withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(widget.compra.status)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getStatusIcon(widget.compra.status),
                                  color: _getStatusColor(widget.compra.status),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.compra.status,
                                      style: TextStyle(
                                        color: _getStatusColor(
                                            widget.compra.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getStatusDescription(
                                          widget.compra.status),
                                      style: TextStyle(
                                        color: _getStatusColor(
                                            widget.compra.status),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoCard('Información del Cliente', [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.compra.cliente.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.compra.cliente.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.compra.cliente.telefono != null &&
                              widget.compra.cliente.telefono!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone,
                                      color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.compra.cliente.telefono!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ContactButtons(
                            telefono: widget.compra.cliente.telefono,
                            email: widget.compra.cliente.email,
                          ),
                        ]),
                        _buildInfoCard('Vehículo', [
                          Text(
                            widget.compra.cotizacion.coche?.nombreCompleto ??
                                'Vehículo Desconocido',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('VIN',
                              widget.compra.cotizacion.coche?.vin ?? 'N/A'),
                          const Divider(height: 24),
                          _buildDetailRow(
                              'Precio',
                              currencyFormatter.format(
                                  widget.compra.cotizacion.precioCoche)),
                          _buildDetailRow(
                              'Enganche',
                              currencyFormatter
                                  .format(widget.compra.cotizacion.enganche)),
                        ]),
                        _buildInfoCard('Información Financiera del Cliente', [
                          _buildDetailRow(
                              'Ingreso Mensual',
                              currencyFormatter.format(widget
                                  .compra.datosFinancieros['ingresoMensual'])),
                          _buildDetailRow(
                              'Otros Ingresos',
                              currencyFormatter.format(widget
                                  .compra.datosFinancieros['otrosIngresos'])),
                          _buildDetailRow(
                              'Gastos Mensuales',
                              currencyFormatter.format(widget
                                  .compra.datosFinancieros['gastosMensuales'])),
                          _buildDetailRow(
                              'Deudas Actuales',
                              currencyFormatter.format(widget
                                  .compra.datosFinancieros['deudasActuales'])),
                          const Divider(height: 24),
                          _buildDetailRow(
                              'Capacidad de Pago',
                              currencyFormatter.format(widget
                                  .compra.datosFinancieros['capacidadPago']),
                              isBold: true),
                        ]),
                        _buildInfoCard('Buró de Crédito', [
                          _buildBuroInfo(),
                        ]),
                        _buildInfoCard('Evaluación Bancaria', [
                          _buildBancoInfo(),
                        ]),
                        if (widget.compra.estaEnRevision ||
                            (widget.compra.estaAprobada &&
                                widget.compra.financiamientoAprobado)) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Acciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.compra.estaEnRevision)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isProcessing
                                    ? null
                                    : _evaluarFinanciamiento,
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Evaluar Financiamiento',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          if (widget.compra.estaAprobada &&
                              widget.compra.financiamientoAprobado) ...[
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isProcessing
                                    ? null
                                    : () => _aprobarCompra('Completada'),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Marcar como Completada',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                side: BorderSide(
                                    color: Colors.red.shade400, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isProcessing
                                  ? null
                                  : () => _aprobarCompra('Rechazada'),
                              child: Text(
                                'Rechazar Compra',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
