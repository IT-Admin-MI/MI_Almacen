import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_almacen/repositories/admin_repository.dart';
import 'package:mi_almacen/repositories/compra_repository_impl.dart';
import 'package:mi_almacen/services/compra_service_impl.dart';
import 'package:mi_almacen/services/compra_sync_Service_impl.dart';
import 'package:mi_almacen/services/drive_service_impl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mi_almacen/services/notification_service_impl.dart';
import 'package:mi_almacen/services/sync_service_impl.dart';
import 'package:mi_almacen/services/vale_service_impl.dart';
import 'package:mi_almacen/viewmodels/LiberacionValesViewModel.dart';
import 'package:mi_almacen/viewmodels/admin_db_viewmodel.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/compra_viewmodel.dart';
import 'package:mi_almacen/viewmodels/historial_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/home_viewmodel.dart';

import 'firebase_options.dart';
import 'database/database_helper.dart';

import 'repositories/material_repository_impl.dart';
import 'repositories/proyecto_repository_impl.dart';
import 'repositories/usuario_repository_impl.dart';
import 'repositories/vale_repository_impl.dart';
import 'repositories/historial_vale_repository_impl.dart';

import 'services/auth_service.dart';
import 'services/auth_service_impl.dart';
import 'services/excel_service_impl.dart';
import 'services/firebase_service_impl.dart';
import 'services/vale_sync_service_impl.dart';
import 'services/sync_service.dart';

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
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationServiceImpl();
  await notificationService.init();

  // ==========================
  // CORE (una sola vez, antes de runApp)
  // ==========================

  final databaseHelper = DatabaseHelper.instance;
  final firebaseService = FirebaseServiceImpl();

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

  final compraRepository = CompraRepositoryImpl(
    databaseHelper: databaseHelper,
  );

  final historialValeRepository = HistorialValeRepositoryImpl(
    databaseHelper: databaseHelper,
  );

  final adminRepository = AdminRepository(databaseHelper: databaseHelper);

  final authService = AuthServiceImpl(
    firebaseService: firebaseService,
    usuarioRepository: usuarioRepository,
  );

// NUEVO — justo aquí:
  notificationService.escucharRefrescoDeToken(() async {
    final usuario = await authService.usuarioActual();
    return usuario?.id;
  });


  final valeService = ValeServiceImpl(
    valeRepository: valeRepository,
    databaseHelper: databaseHelper,
    firebaseService: firebaseService,
    authService: authService,
  );

  final valeSyncService = ValeSyncServiceImpl(
    firebaseService: firebaseService,
    valeRepository: valeRepository,
  );

  final compraSyncService = CompraSyncServiceImpl(
    firebaseService: firebaseService,
    compraRepository: compraRepository,
  );

  final syncService = SyncServiceImpl(
    proyectoRepository: proyectoRepository,
    materialRepository: materialRepository,
    driveService: DriveServiceImpl(),
    valeSyncService: valeSyncService,
    compraSyncService: compraSyncService,
  );


  // ==========================
  // VIEWMODELS
  // ==========================

  final historialValeViewModel = HistorialValesViewModel(
    valeService: valeService,
    syncService: syncService,
  );

  final liberacionValeViewModel = LiberacionValesViewModel(
    valeRepository: valeRepository,
    proyectoRepository: proyectoRepository,
    firebaseService: firebaseService,
  );

  final aprobacionValesViewModel = AprobacionValesViewModel(
    firebaseService: firebaseService,
    valeService: valeService,
    authService: authService,
    proyectoRepository: proyectoRepository,
    syncService: syncService,
  );

  final homeViewModel = HomeViewModel(proyectoRepository: proyectoRepository);

  final loginViewModel = LoginViewModel(
      authService: authService,
      syncService: syncService,
      notificationService: notificationService);

  final valeViewModel = ValeViewModel(
    materialRepository: materialRepository,
    proyectoRepository: proyectoRepository,
    valeRepository: valeRepository,
    historialValeRepository: historialValeRepository,
    valeSyncService: valeSyncService,
    authService: authService,
  );

  final adminDbViewModel = AdminDbViewModel(
    adminRepository: adminRepository,
    valeRepository: valeRepository,
    proyectoRepository: proyectoRepository,
    valeSyncService: valeSyncService,
    materialRepository: materialRepository,
  );

  final compraService = CompraServiceImpl(
      compraRepository: compraRepository,
      compraSyncService: compraSyncService);

  final compraViewModel = CompraViewModel(
    compraService: compraService,
    materialRepository: materialRepository,
    proyectoRepository: proyectoRepository,
  );

  // ==========================
  // APP
  // ==========================
  await dotenv.load(fileName: ".env");
  runApp(
    MyApp(
      authService: authService,
      proyectoRepository: proyectoRepository,
      valeViewModel: valeViewModel,
      aprobacionValesViewModel: aprobacionValesViewModel,
      homeViewModel: homeViewModel,
      historialValesViewModel: historialValeViewModel,
      liberacionValesViewModel: liberacionValeViewModel,
      adminDbViewModel: adminDbViewModel,
      compraViewModel: compraViewModel,
      loginViewModel: loginViewModel,
      syncService: syncService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ProyectoRepositoryImpl proyectoRepository;
  final ValeViewModel valeViewModel;
  final AprobacionValesViewModel aprobacionValesViewModel;
  final HomeViewModel homeViewModel;
  final HistorialValesViewModel historialValesViewModel;
  final LiberacionValesViewModel liberacionValesViewModel;
  final AdminDbViewModel adminDbViewModel;
  final CompraViewModel compraViewModel;
  final LoginViewModel loginViewModel;
  final SyncService syncService;

  const MyApp({
    super.key,
    required this.authService,
    required this.proyectoRepository,
    required this.valeViewModel,
    required this.aprobacionValesViewModel,
    required this.homeViewModel,
    required this.historialValesViewModel,
    required this.liberacionValesViewModel,
    required this.adminDbViewModel,
    required this.compraViewModel,
    required this.loginViewModel,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MI Almacén',
      debugShowCheckedModeBanner: false,

      home: SessionGate(
        authService: authService,
        loginViewModel: loginViewModel,
        proyectoRepository: proyectoRepository,
        valeViewModel: valeViewModel,
        aprobacionValesViewModel: aprobacionValesViewModel,
        homeViewModel: homeViewModel,
        historialValesViewModel: historialValesViewModel,
        liberacionValesViewModel: liberacionValesViewModel,
        adminDbViewModel: adminDbViewModel,
        compraViewModel: compraViewModel,
      ),

      routes: {
        '/login': (context) => LoginPage(viewModel: loginViewModel),
        '/home': (context) => HomePage(
          authService: authService,
          proyectoRepository: proyectoRepository,
          valeViewModel: valeViewModel,
          aprobacionValesViewModel: aprobacionValesViewModel,
          homeViewModel: homeViewModel,
          historialValesViewModel: historialValesViewModel,
          liberacionValesViewModel: liberacionValesViewModel,
          adminDbViewModel: adminDbViewModel,
          compraViewModel: compraViewModel,
        ),
      },
    );
  }
}