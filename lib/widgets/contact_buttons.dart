import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButtons extends StatelessWidget {
  final String? telefono;
  final String email;

  const ContactButtons({
    super.key,
    this.telefono,
    required this.email,
  });

  Future<void> _launchUrl(Uri url, BuildContext context) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showError(context, 'No se pudo abrir: $url');
      }
    } catch (e) {
      _showError(context, 'Error: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _makePhoneCall(BuildContext context) {
    if (telefono == null || telefono!.isEmpty) {
      _showError(context, 'No hay número de teléfono disponible');
      return;
    }

    final cleanPhone = telefono!.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('tel:$cleanPhone');
    _launchUrl(url, context);
  }

  void _sendWhatsApp(BuildContext context) {
    if (telefono == null || telefono!.isEmpty) {
      _showError(context, 'No hay número de teléfono disponible para WhatsApp');
      return;
    }

    final cleanPhone = telefono!.replaceAll(RegExp(r'[^0-9]'), '');
    final message =
        'Hola, te contacto sobre tu cotización en SmartAssistant CRM.';
    final url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );
    _launchUrl(url, context);
  }

  void _sendEmail(BuildContext context) {
    final subject = 'Cotización de Vehículo - SmartAssistant CRM';
    final body = 'Hola, me comunico contigo respecto a tu cotización reciente.';

    final url = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    _launchUrl(url, context);
  }

  @override
  Widget build(BuildContext context) {
    final canCall = telefono != null && telefono!.isNotEmpty;
    final canWhatsApp = telefono != null && telefono!.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.phone,
                color: canCall ? Theme.of(context).primaryColor : Colors.grey,
                size: 28,
              ),
              tooltip: 'Llamar',
              onPressed: canCall ? () => _makePhoneCall(context) : null,
            ),
            Text(
              'Llamar',
              style: TextStyle(
                color: canCall ? Theme.of(context).primaryColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.message,
                color: canWhatsApp ? Colors.green : Colors.grey,
                size: 28,
              ),
              tooltip: 'WhatsApp',
              onPressed: canWhatsApp ? () => _sendWhatsApp(context) : null,
            ),
            Text(
              'WhatsApp',
              style: TextStyle(
                color: canWhatsApp ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: const Icon(
                Icons.email_outlined,
                color: Colors.orange,
                size: 28,
              ),
              tooltip: 'Email',
              onPressed: () => _sendEmail(context),
            ),
            const Text(
              'Email',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
