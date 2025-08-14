import 'package:flutter/material.dart';
import '../models/rol.dart';
import '../models/cliente_usuario.dart';
import '../controllers/formulario_usuario_admin_controller.dart';
import '../core/utils/navigation_helper.dart';
import '/core/ui/app_fields.dart'; // ✅ inputs naranjas reutilizables
import '/core/ui/app_chrome.dart'; // ✅ flecha y panel naranja

class FormularioUsuarioAdminScreen extends StatefulWidget {
  final ClienteUsuario clienteUsuario;

  const FormularioUsuarioAdminScreen({super.key, required this.clienteUsuario});

  @override
  State<FormularioUsuarioAdminScreen> createState() =>
      _FormularioUsuarioAdminScreenState();
}

class _FormularioUsuarioAdminScreenState
    extends State<FormularioUsuarioAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _numeroCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  String _tipoSeleccionado = 'CC';
  Rol _rolSeleccionado = Rol.normal;

  final _controller = FormularioUsuarioAdminController();

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final mensaje = await _controller.registrarUsuario(
      // 👇 MUY IMPORTANTE: usamos SIEMPRE el cliente del admin en sesión
      cliente: widget.clienteUsuario.cliente,
      tipoIdentificacion: _tipoSeleccionado,
      numeroIdentificacion: _numeroCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      cargo: _cargoCtrl.text.trim(),
      empresa: _empresaCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text.trim(),
      rol: _rolSeleccionado,
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
    );

    if (!mounted) return;

    if (mensaje != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Usuario registrado exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logos
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final mobile = constraints.maxWidth < 700;
                      return mobile
                          ? Column(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 12),
                              Image.asset(
                                'assets/cliente.png',
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('assets/logo.png', height: 100),
                              Image.asset('assets/cliente.png', height: 100),
                            ],
                          );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Panel con borde naranja (mismo look que login)
                  AppOrangePanel(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Crear Nuevo Usuario',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 22 : 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tipo de Identificación
                          AppDropdown<String>(
                            label: 'Tipo de Identificación',
                            value: _tipoSeleccionado,
                            items:
                                ['CC', 'TE', 'CE', 'PEP']
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _tipoSeleccionado = v!),
                          ),
                          const SizedBox(height: 16),

                          // Número de Identificación
                          AppTextField(
                            label: 'Número de Identificación',
                            controller: _numeroCtrl,
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Nombre
                          AppTextField(
                            label: 'Nombre Completo',
                            controller: _nombreCtrl,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Cargo
                          AppTextField(
                            label: 'Cargo',
                            controller: _cargoCtrl,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Empresa
                          AppTextField(
                            label: 'Empresa',
                            controller: _empresaCtrl,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Correo
                          AppTextField(
                            label: 'Correo Electrónico',
                            controller: _correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Teléfono
                          AppTextField(
                            label: 'Teléfono',
                            controller: _telefonoCtrl,
                            keyboardType: TextInputType.phone,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          AppTextField(
                            label: 'Contraseña',
                            controller: _contrasenaCtrl,
                            obscure: true,
                            validator:
                                (v) =>
                                    (v?.isEmpty == true)
                                        ? 'Campo obligatorio'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Rol
                          AppDropdown<Rol>(
                            label: 'Rol del Usuario',
                            value: _rolSeleccionado,
                            items:
                                Rol.values
                                    .map(
                                      (rol) => DropdownMenuItem(
                                        value: rol,
                                        child: Text(rol.name.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _rolSeleccionado = v!),
                          ),

                          const SizedBox(height: 24),

                          // Guardar
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Guardar Usuario',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5F00),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _guardarUsuario,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Cancelar
                          TextButton(
                            onPressed:
                                () => NavigationHelper.volverAlMenu(
                                  context,
                                  widget.clienteUsuario,
                                ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF5F00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ← Flecha superior izquierda (misma acción que "Cancelar")
          AppBackButton(
            onTap:
                () => NavigationHelper.volverAlMenu(
                  context,
                  widget.clienteUsuario,
                ),
          ),
        ],
      ),
    );
  }
}
