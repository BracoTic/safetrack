import 'package:flutter/material.dart';
import '../models/cliente_usuario.dart';
import '../controllers/modificar_usuario_controller.dart';
import '/core/ui/app_fields.dart'; // estilos de inputs reutilizables
import '/core/ui/app_chrome.dart'; // 👈 flecha reutilizable
import 'menu_normal_screen.dart';

class ModificarUsuarioScreen extends StatefulWidget {
  const ModificarUsuarioScreen({super.key, required this.clienteUsuario});

  final ClienteUsuario clienteUsuario;

  @override
  State<ModificarUsuarioScreen> createState() => _ModificarUsuarioScreenState();
}

class _ModificarUsuarioScreenState extends State<ModificarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _cargoCtrl;
  late TextEditingController _empresaCtrl;
  late TextEditingController _contrasenaCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _telefonoCtrl;

  late ModificarUsuarioController _controller;
  bool _verPassword = false;

  @override
  void initState() {
    super.initState();
    _controller = ModificarUsuarioController(widget.clienteUsuario);
    _nombreCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.nombre,
    );
    _cargoCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.cargo,
    );
    _empresaCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.empresa,
    );
    _contrasenaCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.contrasena,
    );
    _correoCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.correo,
    );
    _telefonoCtrl = TextEditingController(
      text: widget.clienteUsuario.usuario.telefono,
    );
  }

  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    _controller.actualizarDatos(
      nombre: _nombreCtrl.text.trim(),
      cargo: _cargoCtrl.text.trim(),
      empresa: _empresaCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
    );
    await _controller.guardar();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Datos actualizados correctamente')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MenuNormalScreen(clienteUsuario: widget.clienteUsuario),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cargoCtrl.dispose();
    _empresaCtrl.dispose();
    _contrasenaCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Modificar Mis Datos',
                      textAlign: TextAlign.center, // centrado
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // No editables
                    _campoTextoNoEditable(
                      'Tipo de Documento',
                      widget.clienteUsuario.usuario.tipoIdentificacion,
                    ),
                    const SizedBox(height: 16),
                    _campoTextoNoEditable(
                      'Número de Documento',
                      widget.clienteUsuario.usuario.numeroIdentificacion,
                    ),
                    const SizedBox(height: 20),

                    // Editables
                    AppTextField(
                      label: 'Nombre',
                      controller: _nombreCtrl,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Cargo',
                      controller: _cargoCtrl,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Empresa',
                      controller: _empresaCtrl,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Correo',
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Teléfono',
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Contraseña',
                      controller: _contrasenaCtrl,
                      obscure: !_verPassword,
                      validator:
                          (v) =>
                              (v?.isEmpty == true) ? 'Campo obligatorio' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFFF5F00),
                        ),
                        onPressed:
                            () => setState(() => _verPassword = !_verPassword),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Guardar
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(47),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _guardarCambios,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancelar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Flecha superior izquierda (usa el componente de la UI y hace pop)
          AppBackButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  /// Campo deshabilitado con look naranja
  Widget _campoTextoNoEditable(String label, String valor) {
    return TextFormField(
      initialValue: valor,
      enabled: false,
      style: const TextStyle(color: Colors.white70),
      decoration: appInputDecoration(label).copyWith(
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(47),
          borderSide: const BorderSide(color: Color(0xFFFF5F00)),
        ),
      ),
    );
  }
}
