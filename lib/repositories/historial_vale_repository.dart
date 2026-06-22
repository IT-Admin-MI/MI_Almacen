import '../models/Historial_Vale.dart';

abstract class HistorialValeRepository {

  Future<void> insert(
      HistorialVale historial,
      );

  Future<List<HistorialVale>>
  getPorVale(
      String valeId,
      );

}