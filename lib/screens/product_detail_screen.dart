import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant_vendedor/models/product.dart';
import 'package:smartassistant_vendedor/screens/crear_cotizacion_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product coche;
  const ProductDetailScreen({super.key, required this.coche});

  Widget _buildDetailSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {bool isImportant = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
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
                fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
                fontSize: isImportant ? 16 : 14,
                color: valueColor ??
                    (isImportant ? Colors.green.shade700 : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!coche.activo) {
      statusColor = Colors.red;
      statusText = 'Producto Inactivo';
      statusIcon = Icons.block;
    } else if (coche.stock <= 0) {
      statusColor = Colors.red;
      statusText = 'Sin Stock';
      statusIcon = Icons.error_outline;
    } else if (coche.stock <= 2) {
      statusColor = Colors.orange;
      statusText = 'Stock Bajo';
      statusIcon = Icons.warning_amber;
    } else {
      statusColor = Colors.green;
      statusText = 'Disponible';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${coche.stock} ${coche.stock == 1 ? "unidad disponible" : "unidades disponibles"}',
                  style: TextStyle(
                    color: statusColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalle del Vehículo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Información completa',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStockStatus(),
                              const SizedBox(height: 20),
                              if (coche.imageUrl != null &&
                                  coche.imageUrl!.isNotEmpty)
                                Container(
                                  height: 220,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(coche.imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 80,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.local_offer,
                                          color: Colors.green.shade700,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Precio Base',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currencyFormatter
                                          .format(coche.precioBase),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildDetailSection(
                                'Información General',
                                Icons.info_outline,
                                Colors.blue,
                                [
                                  _buildDetailItem('VIN', coche.vin),
                                  _buildDetailItem('Marca', coche.marca),
                                  _buildDetailItem('Modelo', coche.modelo),
                                  _buildDetailItem('Año', coche.ano.toString()),
                                  _buildDetailItem(
                                      'Condición', coche.condicion),
                                  _buildDetailItem('Tipo', coche.tipo),
                                  _buildDetailItem(
                                      'Stock', '${coche.stock} unidades'),
                                  _buildDetailItem('Estado',
                                      coche.activo ? 'Activo' : 'Inactivo',
                                      valueColor: coche.activo
                                          ? Colors.green
                                          : Colors.red),
                                ],
                              ),
                              _buildDetailSection(
                                'Especificaciones Técnicas',
                                Icons.settings,
                                Colors.orange,
                                [
                                  _buildDetailItem('Motor', coche.motor),
                                  _buildDetailItem(
                                      'Transmisión', coche.transmision),
                                  _buildDetailItem('Color', coche.color),
                                  _buildDetailItem('Número de Puertas',
                                      coche.numPuertas.toString()),
                                  _buildDetailItem('Kilometraje',
                                      '${numberFormatter.format(coche.kilometraje)} km'),
                                ],
                              ),
                              if (coche.costoCompra > 0)
                                _buildDetailSection(
                                  'Información Financiera',
                                  Icons.attach_money,
                                  Colors.teal,
                                  [
                                    _buildDetailItem(
                                      'Precio Base',
                                      currencyFormatter
                                          .format(coche.precioBase),
                                      isImportant: true,
                                    ),
                                    _buildDetailItem(
                                      'Costo de Compra',
                                      currencyFormatter
                                          .format(coche.costoCompra),
                                    ),
                                    if (coche.precioBase > coche.costoCompra)
                                      _buildDetailItem(
                                        'Margen',
                                        currencyFormatter.format(
                                            coche.precioBase -
                                                coche.costoCompra),
                                        valueColor: Colors.green.shade700,
                                      ),
                                  ],
                                ),
                              if (coche.vecesVendido > 0)
                                _buildDetailSection(
                                  'Historial de Ventas',
                                  Icons.history,
                                  Colors.indigo,
                                  [
                                    _buildDetailItem('Veces Vendido',
                                        coche.vecesVendido.toString()),
                                    if (coche.fechaCompra != null)
                                      _buildDetailItem(
                                          'Fecha de Compra',
                                          DateFormat('dd/MM/yyyy')
                                              .format(coche.fechaCompra!)),
                                  ],
                                ),
                              if (coche.descripcion.isNotEmpty)
                                _buildDetailSection(
                                  'Descripción',
                                  Icons.description,
                                  Colors.purple,
                                  [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        coche.descripcion,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.6,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: coche.estaDisponible
                                  ? [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context)
                                          .primaryColor
                                          .withBlue(255),
                                    ]
                                  : [
                                      Colors.grey.shade400,
                                      Colors.grey.shade500,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (coche.estaDisponible
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey)
                                    .withOpacity(0.3),
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
                            onPressed: coche.estaDisponible
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CrearCotizacionScreen(coche: coche),
                                      ),
                                    );
                                  }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  coche.estaDisponible
                                      ? Icons.request_quote
                                      : Icons.block,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  coche.estaDisponible
                                      ? 'Generar Cotización'
                                      : 'Producto No Disponible',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
