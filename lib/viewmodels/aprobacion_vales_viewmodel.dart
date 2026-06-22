import 'package:flutter/material.dart';

import '../models/Vale.dart';
import '../services/firebase_service.dart';

class AprobacionValesViewModel
    extends ChangeNotifier {

  final FirebaseService firebaseService;

  AprobacionValesViewModel({
    required this.firebaseService,
  });

  bool _cargando = false;

  List<Vale> _vales = [];

  bool get cargando =>
      _cargando;

  List<Vale> get vales =>
      List.unmodifiable(
        _vales,
      );

  Future<void> cargarVales() async {

    _cargando = true;

    notifyListeners();

    try {

      _vales =
      await firebaseService
          .obtenerValesPendientes();

    } finally {

      _cargando = false;

      notifyListeners();
    }
  }
}