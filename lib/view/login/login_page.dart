import 'package:flutter/material.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _verPassword = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_viewModelListener);
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _viewModelListener() => setState(() {});

  Future<void> _login() async {
    final ok = await widget.viewModel.login(
      _usuarioController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    if (ok) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Inicia Sesión",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 32),

                    TextField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_verPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _verPassword = !_verPassword);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (widget.viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Botón — siempre la misma altura, sin importar el estado
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.viewModel.loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: widget.viewModel.loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                            : const Text(
                          'Ingresar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // Mensaje de sincronización, fuera del botón
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: widget.viewModel.sincronizando
                          ? const Padding(
                        key: ValueKey('sync-msg'),
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Sincronizando...',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      )
                          : const SizedBox(
                        key: ValueKey('sync-msg-empty'),
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}