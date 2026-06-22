import 'package:flutter/material.dart';

import '../../viewmodels/aprobacion_vales_viewmodel.dart';

class AprobacionValesPage
    extends StatefulWidget {

  final AprobacionValesViewModel
  viewModel;

  const AprobacionValesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<AprobacionValesPage>
  createState() =>
      _AprobacionValesPageState();
}

class _AprobacionValesPageState
    extends State<AprobacionValesPage> {

  @override
  void initState() {
    super.initState();

    widget.viewModel
        .cargarVales();
  }

  @override
  Widget build(
      BuildContext context) {

    return AnimatedBuilder(

      animation:
      widget.viewModel,

      builder:
          (context, child) {

        return Scaffold(

          appBar: AppBar(
            title: const Text(
              'Vales Pendientes',
            ),
          ),

          body:
          widget.viewModel
              .cargando

              ? const Center(
            child:
            CircularProgressIndicator(),
          )

              : ListView.builder(

            itemCount:
            widget
                .viewModel
                .vales
                .length,

            itemBuilder:
                (
                context,
                index,
                ) {

              final vale =
              widget
                  .viewModel
                  .vales[index];

              return Card(

                margin:
                const EdgeInsets.all(
                  8,
                ),

                child: ListTile(

                  title: Text(
                    vale.id,
                  ),

                  subtitle:
                  Text(
                    vale.usuarioNombre,
                  ),

                  trailing:
                  const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {

                    // detalle
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}