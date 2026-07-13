// lib/services/notification_service.dart
abstract class NotificationService {
  Future<void> init();
  Future<String?> getToken();
  Future<void> saveTokenForUser(String userId);
  void escucharRefrescoDeToken(Future<String?> Function() obtenerUsuarioIdActual); // NUEVO
}