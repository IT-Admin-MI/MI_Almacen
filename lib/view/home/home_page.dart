import 'package:flutter/material.dart';
import 'package:mi_almacen/services/firebase_service_impl.dart';
import 'package:mi_almacen/view/vales/vales_page.dart';
import 'package:mi_almacen/viewmodels/aprobacion_vales_viewmodel.dart';
import 'package:mi_almacen/viewmodels/vale_viewmodel.dart';

import '../../models/Proyecto.dart';
import '../../models/Usuario.dart';
import '../vales/vales_aprobacion_page.dart';
import '../../repositories/proyecto_repository.dart';

import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {

  final AuthService authService;

  final ProyectoRepository proyectoRepository;

  final ValeViewModel valeViewModel;

  final AprobacionValesViewModel aprobacionValesViewModel;


  const HomePage({
    super.key,
    required this.authService,
    required this.proyectoRepository,
    required this.valeViewModel,
    required  this.aprobacionValesViewModel,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}
class _HomePageState
    extends State<HomePage> {

  bool get esAdmin =>
      usuario?.rol == 0;

  bool get esSupervisor =>
      usuario?.rol == 1;

  bool get esComprador =>
      usuario?.rol == 2;

  bool get esAlmacenista =>
      usuario?.rol == 3;

  bool get esEmpleado =>
      usuario?.rol == 4;

  Usuario? usuario;

  List<Proyecto> proyectos = [];

  bool cargandoProyectos = true;

  @override
  void initState() {
    super.initState();

    cargarUsuario();
    cargarProyectos();
  }

  Future<void> cargarUsuario() async {

    final resultado =
    await widget.authService
        .usuarioActual();

    print(
      'HOME USER => '
          'nombre=${resultado?.nombre} '
          'rol=${resultado?.rol} '
          'departamento=${resultado?.departamento}',
    );

    if (!mounted) return;

    setState(() {
      usuario = resultado;
    });
  }

  Future<void> cargarProyectos() async {

    print('CARGAR PROYECTOS');

    var resultado =
    await widget.proyectoRepository.getAll();

    print(
      'PROYECTOS EN SQLITE: ${resultado.length}',
    );

    if (resultado.isEmpty) {

      print(
        'SQLITE VACIO, SINCRONIZANDO...',
      );

      await widget.proyectoRepository
          .sincronizarFirebase();

      resultado =
      await widget.proyectoRepository
          .getAll();

      print(
        'PROYECTOS DESPUES DE SINCRONIZAR: ${resultado.length}',
      );
    }

    if (!mounted) return;

    setState(() {

      proyectos = resultado;

      cargandoProyectos = false;
    });
  }
  Future<void> cerrarSesion() async {

    await widget.authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  String formatearFecha(
      DateTime fecha,
      ) {

    return
      '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
  }

  Widget buildProyectoCard(
      Proyecto proyecto,
      ) {

    return Card(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      elevation: 3,

      child: Padding(

        padding: const EdgeInsets.all(
          16,
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(
              proyecto.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  proyecto.clave,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                Text(
                  proyecto.fechaEntrega != null
                      ? formatearFecha(
                    proyecto.fechaEntrega!,
                  )
                      : 'Sin fecha',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        centerTitle: true,

        title: Image.asset(
          'assets/images/logo_ext.png',
          height: 30,
          fit: BoxFit.contain,
        ),
      ),

      drawer: Drawer(

        child: Column(

          children: [

            DrawerHeader(

              child: Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                crossAxisAlignment:
                CrossAxisAlignment.center,

                children: [

                  ClipRRect(

                    borderRadius:
                    BorderRadius.zero,

                    child: Image.asset(
                      'assets/images/logo_bn.png',
                      width: 56,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    usuario?.nombre ?? '',
                    textAlign:
                    TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    usuario?.descripcion ?? '',
                    textAlign:
                    TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(

              child: ListView(

                padding:
                EdgeInsets.zero,

                children: [

                  ListTile(
                    leading: const Icon(Icons.task),
                    title: const Text('Proyectos'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Crear Vale'),
                    onTap: () {

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ValesPage(
                            viewModel: widget.valeViewModel,
                          ),
                        ),
                      );
                    },
                  ),

                  if (usuario != null &&
                      (usuario!.rol == 0 ||
                          usuario!.rol == 1))

                    ListTile(
                      leading: const Icon(
                        Icons.fact_check,
                      ),

                      title: const Text(
                        'Aprobación de Vales',
                      ),

                      onTap: () {

                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AprobacionValesPage(
                              viewModel: widget.aprobacionValesViewModel,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const Divider(),

            ListTile(

              leading: const Icon(
                Icons.logout,
              ),

              title: const Text(
                'Cerrar sesión',
              ),

              onTap: cerrarSesion,
            ),

            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),

      body: Column(

        children: [

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Proyectos activos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          Expanded(

            child: cargandoProyectos

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : projetosVacios(),
          ),
        ],
      ),
    );
  }

  Widget projetosVacios() {

    if (proyectos.isEmpty) {

      return const Center(
        child: Text(
          'No hay proyectos disponibles',
        ),
      );
    }

    return ListView.builder(

      itemCount: proyectos.length,

      itemBuilder:
          (context, index) {

        return buildProyectoCard(
          proyectos[index],
        );
      },
    );
  }
}