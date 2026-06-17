import 'package:flutter/material.dart';

import '../../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final _usuarioController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.viewModel.addListener(
      _viewModelListener,
    );
  }

  @override
  void dispose() {

    widget.viewModel.removeListener(
      _viewModelListener,
    );

    _usuarioController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _viewModelListener() {
    setState(() {});
  }

  Future<void> _login() async {

    final ok =
    await widget.viewModel.login(
      _usuarioController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (ok) {

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MI Almacén',
        ),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller:
              _usuarioController,
              decoration:
              const InputDecoration(
                labelText: 'Usuario',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
              _passwordController,
              obscureText: true,
              decoration:
              const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),

            const SizedBox(height: 20),

            if (widget.viewModel.error != null)
              Text(
                widget.viewModel.error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                widget.viewModel.loading
                    ? null
                    : _login,
                child:
                widget.viewModel.loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(),
                )
                    : const Text(
                  'Ingresar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}