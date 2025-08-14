import 'package:flutter/material.dart';
import '../controllers/formulario_usuario_solo_normal_controller.dart';
import '../models/cliente.dart';
import '/core/ui/app_chrome.dart';
import '/core/ui/app_fields.dart'; // ✅ campos y back button reutilizables

class FormularioUsuarioSoloNormalScreen extends StatefulWidget {
  const FormularioUsuarioSoloNormalScreen({super.key});

  @override
  State<FormularioUsuarioSoloNormalScreen> createState() =>
      _FormularioUsuarioSoloNormalScreenState();
}

class _FormularioUsuarioSoloNormalScreenState
    extends State<FormularioUsuarioSoloNormalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = FormularioUsuarioSoloNormalController();
  final ScrollController _scrollController = ScrollController();

  final _numeroCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  bool _verPassword = false;

  String _tipoSeleccionado = 'CC';
  Cliente? _clienteSeleccionado;
  List<Cliente> _clientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    _clientes = await _controller.obtenerClientes();
    if (_clientes.isNotEmpty) _clienteSeleccionado = _clientes.first;
    setState(() => _cargando = false);
  }

  void _guardarUsuario() async {
    if (!_formKey.currentState!.validate() || _clienteSeleccionado == null)
      return;

    final error = await _controller.registrarUsuario(
      cliente: _clienteSeleccionado!,
      tipoIdentificacion: _tipoSeleccionado,
      numeroIdentificacion: _numeroCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      cargo: _cargoCtrl.text.trim(),
      empresa: _empresaCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Usuario registrado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (_, cs) {
          final w = cs.maxWidth;
          final h = cs.maxHeight;

          const maxFormWidth = 675.0;
          const horizontalPadding = 80.0;

          final availableWidth = w - 2 * horizontalPadding;
          final formWidth =
              availableWidth >= maxFormWidth ? maxFormWidth : availableWidth;
          final isMobile = availableWidth < maxFormWidth;

          final offsetX = isMobile ? 0.0 : -250.0;
          const offsetY = 10.0;

          return Stack(
            children: [
              // Fondo
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF24293D), Color(0xFF191C25)],
                    transform: GradientRotation(130 * 3.1416 / 180),
                  ),
                ),
                child: SizedBox.expand(),
              ),

              // Imagen decorativa
              ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Transform.translate(
                    offset: Offset(w * (850 / 1920), h * (20 / 1366)),
                    child: Opacity(
                      opacity: 1,
                      child: Image.asset(
                        'assets/Grupo 2.png',
                        width: w * (1147 / 1920),
                        height: h * (1159 / 1366),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Esfera
              Positioned(
                right: 62,
                bottom: 126,
                child: Image.asset(
                  'assets/esfera.png',
                  width: 160,
                  height: 160,
                ),
              ),

              // Contenedores
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 60,
                  ),
                  child: Transform.translate(
                    offset: Offset(offsetX, offsetY),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Rectángulo exterior naranja
                        Positioned(
                          top: -10,
                          bottom: 10,
                          left: isMobile ? 0 : 80,
                          child: Container(
                            width: formWidth + (isMobile ? 0 : 260),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(20, 117, 117, 117),
                              border: Border.all(
                                color: Color(0xFFFF5F00),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(98),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(44, 16, 0, 0.012),
                                  offset: Offset(20, 20),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Formulario negro interior
                        Positioned(
                          top: 40,
                          bottom: 60,
                          left: isMobile ? -80 : 220,
                          child: Container(
                            width:
                                isMobile ? formWidth + 160.1 : formWidth + 70,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1D29),
                              border: Border.all(
                                color: Color(0xFFFF5F00),
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(48),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(44, 16, 0, 0.012),
                                  offset: Offset(20, 20),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child:
                                _cargando
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : RawScrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      interactive: true,
                                      thickness: 6,
                                      radius: const Radius.circular(12),
                                      thumbColor: Colors.white,
                                      trackColor: Colors.white24,
                                      trackBorderColor: Colors.white38,
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'START FOR FREE',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Crear nueva cuenta',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text(
                                                  '¿Ya tienes una cuenta? inicia sesión aquí',
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 12,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 32),

                                              // 🔶 Campos usando AppDropdown / AppTextField
                                              AppDropdown<Cliente>(
                                                label: 'Cliente*',
                                                value: _clienteSeleccionado,
                                                items:
                                                    _clientes
                                                        .map(
                                                          (c) =>
                                                              DropdownMenuItem(
                                                                value: c,
                                                                child: Text(
                                                                  c.nombre,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged:
                                                    (v) => setState(
                                                      () =>
                                                          _clienteSeleccionado =
                                                              v,
                                                    ),
                                              ),
                                              const SizedBox(height: 16),

                                              AppDropdown<String>(
                                                label: 'Tipo de Documento*',
                                                value: _tipoSeleccionado,
                                                items:
                                                    ['CC', 'TE', 'CE', 'PEP']
                                                        .map(
                                                          (t) =>
                                                              DropdownMenuItem(
                                                                value: t,
                                                                child: Text(t),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged:
                                                    (v) => setState(
                                                      () =>
                                                          _tipoSeleccionado =
                                                              v!,
                                                    ),
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label:
                                                    'Número de Identificación*',
                                                controller: _numeroCtrl,
                                                keyboardType:
                                                    TextInputType.number,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Nombre Completo*',
                                                controller: _nombreCtrl,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Cargo*',
                                                controller: _cargoCtrl,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Empresa',
                                                controller: _empresaCtrl,
                                                validator: (_) => null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Correo Electrónico*',
                                                controller: _correoCtrl,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Teléfono*',
                                                controller: _telefonoCtrl,
                                                keyboardType:
                                                    TextInputType.phone,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                              ),
                                              const SizedBox(height: 16),

                                              AppTextField(
                                                label: 'Contraseña*',
                                                controller: _contrasenaCtrl,
                                                obscure: !_verPassword,
                                                validator:
                                                    (v) =>
                                                        (v?.isEmpty == true)
                                                            ? 'Campo obligatorio'
                                                            : null,
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _verPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: const Color(
                                                      0xFFFF5F00,
                                                    ),
                                                  ),
                                                  onPressed:
                                                      () => setState(
                                                        () =>
                                                            _verPassword =
                                                                !_verPassword,
                                                      ),
                                                ),
                                              ),

                                              const SizedBox(height: 28),

                                              // Botón registrar
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  onPressed: _guardarUsuario,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFFF5F00),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            32,
                                                          ),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.arrow_forward,
                                                    color: Colors.white,
                                                  ),
                                                  label: const Text(
                                                    'REGISTRAR USUARIO',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ← Flecha superior izquierda (misma función que el link: pop)
              AppBackButton(onTap: () => Navigator.pop(context)),
            ],
          );
        },
      ),
    );
  }
}
