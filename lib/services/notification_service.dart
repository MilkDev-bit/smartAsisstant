import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smartassistant_vendedor/constants.dart';

class NotificationService {
  Future<String?> initOneSignal() async {
    try {
      // Configurar debug
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.Debug.setAlertLevel(OSLogLevel.none);

      // Inicializar
      OneSignal.initialize(ONESIGNAL_APP_ID);

      // Solicitar permisos
      final status = await OneSignal.Notifications.requestPermission(true);
      print('🔔 Permiso de notificación: $status');

      if (status) {
        // Configurar listeners
        OneSignal.Notifications.addClickListener((event) {
          print('🔔 Notificación clickeada: ${event.notification.body}');
          // Manejar navegación cuando se hace clic en la notificación
        });

        OneSignal.Notifications.addPermissionObserver((state) {
          print('🔔 Estado de permisos cambiado: $state');
        });

        OneSignal.Notifications.addForegroundWillDisplayListener((event) {
          print('🔔 Notificación en foreground: ${event.notification.body}');
        });

        // Obtener el playerId después de la inicialización
        await Future.delayed(const Duration(milliseconds: 500));
        final subscriptionState = await OneSignal.User.pushSubscription;
        final playerId = subscriptionState.id;

        print('🔔 Player ID: $playerId');
        return playerId;
      }
      return null;
    } catch (e) {
      print('❌ Error inicializando OneSignal: $e');
      return null;
    }
  }

  Future<void> sendTestNotification() async {
    try {
      final subscriptionState = await OneSignal.User.pushSubscription;
      print('🔔 Estado de suscripción - ID: ${subscriptionState.id}');
    } catch (e) {
      print('❌ Error obteniendo estado de suscripción: $e');
    }
  }

  Future<void> disableNotifications() async {
    try {
      await OneSignal.User.pushSubscription.optOut();
      print('🔔 Notificaciones deshabilitadas');
    } catch (e) {
      print('❌ Error deshabilitando notificaciones: $e');
    }
  }

  Future<void> enableNotifications() async {
    try {
      await OneSignal.User.pushSubscription.optIn();
      print('🔔 Notificaciones habilitadas');
    } catch (e) {
      print('❌ Error habilitando notificaciones: $e');
    }
  }

  // ✅ MÉTODO PARA ENVIAR EMAILS PERSONALIZADOS
  Future<void> enviarEmailPersonalizado(
      String email, String subject, String body) async {
    try {
      // En desarrollo, simulamos el envío de email
      print('📧 === EMAIL SIMULADO ===');
      print('📧 Para: $email');
      print('📧 Asunto: $subject');
      print('📧 Cuerpo:');
      print(body);
      print('📧 === FIN EMAIL ===');

      // En producción, aquí integrarías con tu servicio de email
      // Por ejemplo: SendGrid, Mailgun, o el servicio de email de tu backend
    } catch (e) {
      print('Error enviando email personalizado: $e');
      rethrow;
    }
  }

  Future<void> enviarCodigo2FA(String email, String codigo) async {
    try {
      final subject = 'Tu Código de Verificación 2FA - SmartAssistant CRM';
      final body = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            margin: 0; 
            padding: 0; 
            background-color: #f9fafb;
        }
        .container { 
            max-width: 600px; 
            margin: 0 auto; 
            padding: 20px; 
        }
        .header { 
            background: #2563eb; 
            color: white; 
            padding: 30px 20px; 
            text-align: center; 
            border-radius: 8px 8px 0 0; 
        }
        .content { 
            background: white; 
            padding: 30px; 
            border-radius: 0 0 8px 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .code { 
            font-size: 36px; 
            font-weight: bold; 
            text-align: center; 
            letter-spacing: 8px; 
            margin: 30px 0; 
            color: #2563eb; 
            background: #f0f4ff;
            padding: 20px;
            border-radius: 8px;
            border: 2px dashed #2563eb;
        }
        .footer { 
            margin-top: 30px; 
            padding-top: 20px; 
            border-top: 1px solid #e5e7eb; 
            color: #6b7280; 
            font-size: 14px; 
            text-align: center;
        }
        .warning { 
            background: #fef3c7; 
            border: 1px solid #f59e0b; 
            padding: 15px; 
            border-radius: 6px; 
            margin: 20px 0; 
        }
        .button {
            display: inline-block;
            background: #2563eb;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 SmartAssistant CRM</h1>
            <p>Verificación de Dos Factores</p>
        </div>
        <div class="content">
            <h2>Hola,</h2>
            <p>Se ha solicitado un código de verificación para tu cuenta en SmartAssistant CRM.</p>
            
            <p>Tu código de verificación es:</p>
            <div class="code">$codigo</div>
            
            <div class="warning">
                <strong>⚠️ Importante:</strong>
                <p>• Este código expirará en 10 minutos</p>
                <p>• No lo compartas con nadie</p>
                <p>• Si no solicitaste este código, ignora este email</p>
            </div>
            
            <p>Ingresa este código en la aplicación para completar tu verificación.</p>
        </div>
        <div class="footer">
            <p>Este es un email automático de seguridad - no respondas a este mensaje</p>
            <p>© 2024 SmartAssistant CRM. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
      ''';

      await enviarEmailPersonalizado(email, subject, body);
      print('Código 2FA enviado a: $email');
    } catch (e) {
      print('Error enviando código 2FA: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getNotificationStatus() async {
    try {
      final subscriptionState = await OneSignal.User.pushSubscription;
      final permissionState = await OneSignal.Notifications.permission;

      return {
        'playerId': subscriptionState.id,
        'isSubscribed': subscriptionState.id != null,
        'hasPermission': permissionState,
      };
    } catch (e) {
      print('Error obteniendo estado de notificaciones: $e');
      return {
        'playerId': null,
        'isSubscribed': false,
        'hasPermission': false,
      };
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await getNotificationStatus();
      return status['hasPermission'] == true && status['playerId'] != null;
    } catch (e) {
      print('Error verificando estado de notificaciones: $e');
      return false;
    }
  }
}
