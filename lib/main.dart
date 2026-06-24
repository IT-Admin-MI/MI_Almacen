import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_almacen/services/vale_service_impl.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';

import 'firebase_options.dart';

import 'database/database_helper.dart';

import 'repositories/material_repository_impl.dart';
import 'repositories/proyecto_repository_impl.dart';
import 'repositories/usuario_repository_impl.dart';
import 'repositories/vale_repository_impl.dart';
import 'repositories/historial_vale_repository_impl.dart';

import 'services/auth_service_impl.dart';
import 'services/excel_service_impl.dart';
import 'services/firebase_service_impl.dart';
import 'services/vale_sync_service_impl.dart';

import 'view/home/home_page.dart';
import 'view/login/login_page.dart';
import 'view/session_gate.dart';

import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/vale_viewmodel.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS)) {

    sqfliteFfiInit();

    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(),
  );
}
class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });



  @override
  Widget build(BuildContext context) {

    final databaseHelper = DatabaseHelper.instance;
    final firebaseService = FirebaseServiceImpl();

    // ==========================
    // CORE
    // ==========================

    final usuarioRepository = UsuarioRepositoryImpl(
      databaseHelper: databaseHelper,
    );

    final proyectoRepository = ProyectoRepositoryImpl(
      databaseHelper: databaseHelper,
      firebaseService: firebaseService,
    );

    final excelService = ExcelServiceImpl();

    final materialRepository = MaterialRepositoryImpl(
      databaseHelper: databaseHelper,
      excelService: excelService,
    );

    final valeRepository = ValeRepositoryImpl(
      databaseHelper: databaseHelper,
    );



    final historialValeRepository = HistorialValeRepositoryImpl(
      databaseHelper: databaseHelper,
    );

    final valeService = ValeServiceImpl(
      valeRepository: valeRepository,
      databaseHelper: databaseHelper,
      firebaseService: firebaseService,
    );


    // ==========================
    // SERVICES
    // ==========================

    final authService =
    AuthServiceImpl(
      firebaseService: firebaseService,
      usuarioRepository: usuarioRepository,
    );

    final valeSyncService =
    ValeSyncServiceImpl(
      firebaseService: firebaseService,
      valeRepository: valeRepository,
    );

    // ==========================
    // VIEWMODELS
    // ==========================


    final aprobacionValesViewModel =
    AprobacionValesViewModel(
      firebaseService: firebaseService,
      valeService: valeService,
      authService: authService,
      proyectoRepository: proyectoRepository,
    );

    final loginViewModel =
    LoginViewModel(
      authService: authService,
    );

    final valeViewModel =
    ValeViewModel(
      materialRepository:
      materialRepository,

      proyectoRepository:
      proyectoRepository,

      valeRepository:
      valeRepository,

      historialValeRepository:
      historialValeRepository,

      valeSyncService:
      valeSyncService,

      authService:
      authService,
    );

    // ==========================
    // APP
    // ==========================

    return MaterialApp(

      title: 'MI Almacén',

      debugShowCheckedModeBanner: false,

      home: SessionGate(
        authService: authService,
        loginViewModel: loginViewModel,
        proyectoRepository: proyectoRepository,
        valeViewModel: valeViewModel,
        aprobacionValesViewModel: aprobacionValesViewModel,
      ),

      routes: {

        '/login': (context) =>
            LoginPage(
              viewModel:
              loginViewModel,
            ),

        '/home': (context) =>
            HomePage(
              authService: authService,
              proyectoRepository: proyectoRepository,
              valeViewModel: valeViewModel,
              aprobacionValesViewModel: aprobacionValesViewModel,
            ),
      },
    );
  }
}