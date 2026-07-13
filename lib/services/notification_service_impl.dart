// lib/services/notification_service_impl.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'vales_channel',
    'Notificaciones de Vales',
    description: 'Avisos de vales pendientes de aprobar o liberar',
    importance: Importance.high,
  );

  @override
  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const windowsInit = WindowsInitializationSettings(
      appName: 'MetIntApp',
      appUserModelId: 'com.metalurgiaintegral.metintapp',
      guid: '12345678-1234-1234-1234-123456789012',
    );
    const initSettings = InitializationSettings(android: androidInit, windows: windowsInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // NUEVO: sin esto, los mensajes con la app en primer plano nunca se muestran
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // NUEVO (opcional pero recomendado): cuando el usuario toca la notificación
    // y la app estaba en segundo plano (no cerrada), maneja la navegación aquí
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['valeId'],
    );
  }

  void _onNotificationTap(NotificationResponse response) {}
  void _handleMessageOpenedApp(RemoteMessage message) {}

  @override
  Future<String?> getToken() => _fcm.getToken();

  @override
  Future<void> saveTokenForUser(String userId) async {
    final token = await getToken();

    print("========== FCM ==========");
    print("USER ID: $userId");
    print("TOKEN: $token");
    print("=========================");

    if (token == null) return;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .update({'fcmToken': token});
    // Ya NO registramos onTokenRefresh aquí — se hace una sola vez en main.dart
  }

  bool _listenerRegistrado = false;

  @override
  void escucharRefrescoDeToken(Future<String?> Function() obtenerUsuarioIdActual) {
    if (_listenerRegistrado) return; // evita registrar el listener más de una vez
    _listenerRegistrado = true;

    _fcm.onTokenRefresh.listen((nuevoToken) async {
      try {
        final userId = await obtenerUsuarioIdActual();
        if (userId == null || userId.isEmpty) {
          print('Token FCM cambió pero no hay sesión activa, no se guarda');
          return;
        }
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .update({'fcmToken': nuevoToken});
        print('TOKEN FCM ACTUALIZADO TRAS REFRESH: $nuevoToken');
      } catch (e) {
        print('ERROR ACTUALIZANDO TOKEN FCM EN REFRESH: $e');
      }
    });
  }
}