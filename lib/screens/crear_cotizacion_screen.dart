import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:smartassistant_vendedor/models/cotizacion.dart';
import 'package:smartassistant_vendedor/models/product.dart';
import 'package:smartassistant_vendedor/providers/cotizacion_provider.dart';
import 'package:smartassistant_vendedor/screens/client_search_screen.dart';

class CrearCotizacionScreen extends StatefulWidget {
  final Product coche;
  const CrearCotizacionScreen({super.key, required this.coche});

  @override
  State<CrearCotizacionScreen> createState() => _CrearCotizacionScreenState();
}

class _CrearCotizacionScreenState extends State<CrearCotizacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _engancheController = TextEditingController();
  final _plazoController = TextEditingController(text: '48');
  ClienteSimple? _selectedCliente;
  bool _isCalculating = false;
  double? _pagoMensualCalculado;
  double? _totalPagadoCalculado;

  @override
  void initState() {
    super.initState();
    _engancheController.addListener(_calcularFinanciamiento);
    _plazoController.addListener(_calcularFinanciamiento);
  }

  void _calcularFinanciamiento() {
    final enganche = double.tryParse(_engancheController.text);
    final plazo = int.tryParse(_plazoController.text);

    if (enganche != null &&
        plazo != null &&
        plazo >= 12 &&
        plazo <= 72 &&
        enganche < widget.coche.precioBase) {
      setState(() => _isCalculating = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        final montoAFinanciar = widget.coche.precioBase - enganche;
        const tasaInteresAnual = 0.15;
        final tasaInteresMensual = tasaInteresAnual / 12;

        final i = tasaInteresMensual;
        final n = plazo.toDouble();

        final factor = pow(1 + i, n);
        final pagoMensual = (montoAFinanciar * i * factor) / (factor - 1);

        final totalPagado = (pagoMensual * plazo) + enganche;

        if (mounted) {
          setState(() {
            _pagoMensualCalculado = pagoMensual;
            _totalPagadoCalculado = totalPagado;
            _isCalculating = false;
          });
        }
      });
    } else {
      setState(() {
        _pagoMensualCalculado = null;
        _totalPagadoCalculado = null;
      });
    }
  }

  void _selectClient() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClientSearchScreen(),
      ),
    );

    if (result != null && result is ClienteSimple) {
      setState(() => _selectedCliente = result);
    }
  }

  void _submitCotizacion() async {
    if (_selectedCliente == null) {
      _showError('Por favor, selecciona un cliente.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<CotizacionProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final success = await provider.vendedorCreateCotizacion(
      cocheId: widget.coche.id,
      clienteId: _selectedCliente!.id,
      enganche: double.parse(_engancheController.text),
      plazoMeses: int.parse(_plazoController.text),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cotización generada y enviada al cliente!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } else if (mounted) {
      _showError(provider.error ?? 'Error desconocido al crear la cotización');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildCalculoFinanciamiento() {
    if (_isCalculating) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Calculando financiamiento...'),
            ],
          ),
        ),
      );
    }

    if (_pagoMensualCalculado == null || _totalPagadoCalculado == null) {
      return const SizedBox();
    }

    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Financiamiento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildCalculoRow('Pago mensual estimado:',
                currencyFormatter.format(_pagoMensualCalculado!)),
            _buildCalculoRow('Total a pagar:',
                currencyFormatter.format(_totalPagadoCalculado!)),
            _buildCalculoRow('Plazo:', '${_plazoController.text} meses'),
            const SizedBox(height: 8),
            Text(
              '* Cálculo estimado. Los montos pueden variar ligeramente.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final provider = Provider.of<CotizacionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Cotización')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehículo Seleccionado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.coche.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VIN: ${widget.coche.vin}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Precio: ${currencyFormatter.format(widget.coche.precioBase)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cliente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _selectedCliente == null
                          ? OutlinedButton(
                              onPressed: _selectClient,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 8),
                                  Text('Buscar y Seleccionar Cliente'),
                                ],
                              ),
                            )
                          : ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  _selectedCliente!.nombre
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                _selectedCliente!.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedCliente!.email),
                                  if (_selectedCliente!.telefono != null)
                                    Text(_selectedCliente!.telefono!),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _selectClient,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Términos de Financiamiento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _engancheController,
                        decoration: const InputDecoration(
                          labelText: 'Enganche (\$)',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 50000',
                          suffixText: 'MXN',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el monto del enganche';
                          }
                          final enganche = double.tryParse(value);
                          if (enganche == null) {
                            return 'Ingresa un número válido';
                          }
                          if (enganche >= widget.coche.precioBase) {
                            return 'El enganche debe ser menor al precio del coche';
                          }
                          if (enganche <= 0) {
                            return 'El enganche debe ser mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _plazoController,
                        decoration: const InputDecoration(
                          labelText: 'Plazo (meses)',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 48',
                          suffixText: 'meses',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el plazo en meses';
                          }
                          final plazo = int.tryParse(value);
                          if (plazo == null) {
                            return 'Ingresa un número válido';
                          }
                          if (plazo < 12 || plazo > 72) {
                            return 'El plazo debe ser entre 12 y 72 meses';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCalculoFinanciamiento(),
              const SizedBox(height: 20),
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: _selectedCliente != null &&
                                _pagoMensualCalculado != null
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      onPressed: _selectedCliente != null &&
                              _pagoMensualCalculado != null &&
                              !provider.isLoading
                          ? _submitCotizacion
                          : null,
                      child: const Text(
                        'Generar y Enviar Cotización',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              if (_selectedCliente == null)
                Text(
                  'Debes seleccionar un cliente para continuar',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _engancheController.dispose();
    _plazoController.dispose();
    super.dispose();
  }
}
