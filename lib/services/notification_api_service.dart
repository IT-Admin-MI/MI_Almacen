import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationApiService {

  static String get url => dotenv.env['API_URL']!;
  static String get apiKey => dotenv.env['API_KEY']!;

  static Future<void> notificarVale({
    required String valeId,
    required String tipo,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": apiKey,
        },
        body: jsonEncode({
          "valeId": valeId,
          "tipo": tipo,
        }),
      )
          .timeout(const Duration(seconds: 10)); // NUEVO

      print("RESPUESTA NOTIFICACION: ${response.body}");
    } catch (e) {
      print("ERROR NOTIFICACION: $e");
    }
  }
}