import 'package:flutter/material.dart';
import '/controllers/login_controller.dart';
import '/models/cliente.dart';
import '/models/cliente_usuario.dart';
import '/core/ui/app_fields.dart';
import '/core/ui/app_chrome.dart';
import '/core/utils/navigation_helper.dart';
import 'formulario_usuario_solo_normal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = LoginController();
  final _numeroCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _verPassword = false;
  String _tipoSeleccionado = 'CC';
  int? _clienteSeleccionado;

  Future<void> _login() async {
    // Validación básica
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona el cliente')));
      return;
    }

    // Cargamos clientes y ubicamos el seleccionado de forma segura
    final clientes = await _controller.cargarClientes();
    if (!mounted) return;

    final idx = clientes.indexWhere((c) => c.key == _clienteSeleccionado);
    if (idx == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente no encontrado. Intenta recargar los datos.'),
        ),
      );
      return;
    }
    final cliente = clientes[idx];

    final response = await _controller.login(
      cliente: cliente,
      tipoIdentificacion: _tipoSeleccionado,
      numeroIdentificacion: _numeroCtrl.text.trim(),
      contrasena: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (response['success'] != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ ${response['message']}')));
      return;
    }

    final ClienteUsuario clienteUsuario = response['clienteUsuario'];
    _controller.irAlMenuDespuesDeLogin(context, clienteUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, cs) {
          final w = cs.maxWidth;
          final h = cs.maxHeight;

          final bW = w * (1714 / 1920);
          final bH = h * (1732 / 1366);
          final dx = w * (724 / 1920);
          final dy = h * (-234.99 / 1366);

          final rectL = w * (102 / 1920);
          final rectT = h * (117 / 1366);
          final rectW = w * (1716 / 1920);
          final rectH = h * (1132 / 1366);

          return Stack(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF22273A), Color(0xFF191C25)],
                    transform: GradientRotation(130 * 3.1416 / 180),
                  ),
                ),
                child: SizedBox.expand(),
              ),
              ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        'assets/Grupo 2.png',
                        width: bW,
                        height: bH,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: rectL,
                top: rectT,
                width: rectW,
                height: rectH,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(20, 117, 117, 117),
                    borderRadius: BorderRadius.circular(90),
                    border: Border.all(
                      color: const Color(0xFFFF5F00),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(44, 16, 0, 0.012),
                        offset: Offset(20, 20),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: AppOrangePanel(
                    child: LayoutBuilder(
                      builder: (_, cs2) {
                        final innerMobile = cs2.maxWidth < 900;
                        return innerMobile
                            ? Column(
                              children: [
                                _buildLeftSide(),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _buildForm(context),
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Expanded(child: _buildLeftSide()),
                                const SizedBox(width: 40),
                                Expanded(child: _buildForm(context)),
                              ],
                            );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: rectL - 80,
                top: rectT - 60,
                child: Image.asset(
                  'assets/esfera.png',
                  width: 320,
                  fit: BoxFit.contain,
                ),
              ),
              AppBackButton(onTap: () => NavigationHelper.irAInicio(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftSide() => Container(
    decoration: BoxDecoration(
      image: const DecorationImage(
        image: AssetImage('assets/fondo-esfera.png'),
        fit: BoxFit.cover,
      ),
      border: Border.all(color: const Color(0xFFFF5F00), width: 3),
      borderRadius: BorderRadius.circular(86),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    alignment: Alignment.bottomRight,
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: -2.11,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -2.11,
          ),
        ),
      ],
    ),
  );

  Widget _buildForm(BuildContext ctx) => FutureBuilder<List<Cliente>>(
    future: _controller.cargarClientes(),
    builder: (c, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error cargando clientes: ${snap.error}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        );
      }

      final clientes = snap.data ?? const <Cliente>[];

      // Si no hay clientes, mostramos estado vacío y evitamos .first
      if (clientes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No hay clientes en la base local.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Carga los datos por defecto o crea un cliente antes de iniciar sesión.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed:
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Agrega clientes (seed) y vuelve a intentar.',
                        ),
                      ),
                    ),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }

      // Iniciamos el valor seleccionado si aún no existe
      _clienteSeleccionado ??=
          (clientes.first.key is int) ? clientes.first.key as int : null;

      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),

            // Cliente
            AppDropdown<int>(
              label: 'Cliente',
              value: _clienteSeleccionado,
              items:
                  clientes
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.key as int,
                          child: Text(c.nombre),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _clienteSeleccionado = v),
            ),

            const SizedBox(height: 16),

            // Tipo de Documento
            AppDropdown<String>(
              label: 'Tipo de Documento',
              value: _tipoSeleccionado,
              items:
                  ['CC', 'TE', 'CE', 'PEP']
                      .map(
                        (t) =>
                            DropdownMenuItem<String>(value: t, child: Text(t)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _tipoSeleccionado = v!),
            ),

            const SizedBox(height: 16),

            // Número de Documento
            AppTextField(
              label: 'Número de Documento',
              controller: _numeroCtrl,
              validator:
                  (v) =>
                      (v?.trim().isEmpty == true) ? 'Campo obligatorio' : null,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Contraseña
            AppTextField(
              label: 'Contraseña',
              controller: _passwordCtrl,
              obscure: !_verPassword,
              validator:
                  (v) =>
                      (v?.trim().isEmpty == true) ? 'Campo obligatorio' : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _verPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFFF5F00),
                ),
                onPressed: () => setState(() => _verPassword = !_verPassword),
              ),
            ),

            const SizedBox(height: 28),

            // Botón Iniciar Sesión
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5F00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(47),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Acciones secundarias
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const FormularioUsuarioSoloNormalScreen(),
                        ),
                      ),
                  child: const Text(
                    '¿NO TIENES CUENTA?',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.58,
                      color: Color(0xFF7D86A7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿OLVIDASTE TU CONTRASEÑA?',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.58,
                      color: Color(0xFF7D86A7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
