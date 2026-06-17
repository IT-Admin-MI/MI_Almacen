import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_almacen/repositories/proyecto_repository_impl.dart';
import 'package:mi_almacen/services/auth_service_impl.dart';
import 'package:mi_almacen/services/fiebae_service_impl.dart';
import 'package:mi_almacen/view/home/home_page.dart';
import 'package:mi_almacen/view/login/login_page.dart';
import 'package:mi_almacen/view/session_gate.dart';
import 'package:mi_almacen/viewmodels/login_viewmodel.dart';

import 'firebase_options.dart';

import 'database/database_helper.dart';

import 'repositories/usuario_repository_impl.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

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

    final databaseHelper =
        DatabaseHelper.instance;

    final firebaseService =
    FirebaseServiceImpl();

    final usuarioRepository =
    UsuarioRepositoryImpl(
      databaseHelper: databaseHelper,
    );

    final proyectoRepository =
    ProyectoRepositoryImpl(
      databaseHelper:
      databaseHelper,
      firebaseService:
      firebaseService,
    );

    final authService =
    AuthServiceImpl(
      firebaseService: firebaseService,
      usuarioRepository: usuarioRepository,
    );

    final loginViewModel =
    LoginViewModel(
      authService: authService,
    );

    return MaterialApp(
      title: 'MI Almacén',

      debugShowCheckedModeBanner: false,

      home: SessionGate(
        authService: authService,
        loginViewModel: loginViewModel,
        proyectoRepository: proyectoRepository,
      ),

      routes: {

        '/login': (context) =>
            LoginPage(
              viewModel: loginViewModel,
            ),

        '/home': (context) =>
            HomePage(
              authService: authService,
              proyectoRepository: proyectoRepository,
            ),
      },
    );
  }
}