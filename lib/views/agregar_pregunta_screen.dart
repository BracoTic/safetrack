import 'dart:io'; // OK: solo se usa en no-web para preview
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/cliente_usuario.dart';
import '../models/tipo_pregunta.dart';
import '../controllers/agregar_pregunta_controller.dart';
import '../core/utils/navigation_helper.dart';

// 🔶 UI reutilizable
import '/core/ui/app_chrome.dart'; // AppBackButton
import '/core/ui/app_fields.dart'; // AppTextField / AppDropdown

class AgregarPreguntaScreen extends StatefulWidget {
  final ClienteUsuario clienteUsuario;

  const AgregarPreguntaScreen({Key? key, required this.clienteUsuario})
    : super(key: key);

  @override
  State<AgregarPreguntaScreen> createState() => _AgregarPreguntaScreenState();
}

class _AgregarPreguntaScreenState extends State<AgregarPreguntaScreen> {
  final _ctrl = AgregarPreguntaController();

  String _tipo = 'Abierta';

  // Imagen (dual)
  String? _imagenPath; // móvil/desktop
  Uint8List? _imagenBytes; // web
  String? _imagenMime;
  String? _imagenNombre;

  final _textoCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _ordenCtrl = TextEditingController();
  bool _obligatoria = true;
  int? _temaId;

  // Opciones múltiples (controladores estables)
  final List<TextEditingController> _opcionesCtrls = [];

  @override
  void initState() {
    super.initState();
    final temas = _ctrl.getTemas();
    _temaId = temas.isNotEmpty ? temas.first.key as int : null;

    // dos campos por defecto para selección múltiple
    _opcionesCtrls.addAll([TextEditingController(), TextEditingController()]);
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    _refCtrl.dispose();
    _ordenCtrl.dispose();
    for (final c in _opcionesCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;

    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      setState(() {
        _imagenBytes = bytes;
        _imagenMime = x.mimeType; // puede venir null; opcional
        _imagenNombre = x.name; // nombre original (web)
        _imagenPath = null; // limpiar ruta cuando usamos bytes
      });
    } else {
      setState(() {
        _imagenPath = x.path; // ruta local
        _imagenBytes = null; // limpiar bytes cuando usamos ruta
        _imagenMime = null;
        _imagenNombre = x.name; // en móvil puede venir vacío; no es crítico
      });
    }
  }

  Future<void> _guardar() async {
    if (_textoCtrl.text.trim().isEmpty ||
        _refCtrl.text.trim().isEmpty ||
        _temaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los datos son requeridos')),
      );
      return;
    }

    final tipoEnum =
        _tipo == 'Abierta' ? TipoPregunta.string : TipoPregunta.multiple;
    final orden = int.tryParse(_ordenCtrl.text.trim()) ?? 0;

    // opciones (solo si es múltiple)
    final opcionesFiltradas =
        tipoEnum == TipoPregunta.multiple
            ? _opcionesCtrls
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList()
            : null;

    final temaSeleccionado = _ctrl.getTemas().firstWhere(
      (t) => t.key == _temaId,
    );

    await _ctrl.agregarPregunta(
      texto: _textoCtrl.text.trim(),
      referencia: _refCtrl.text.trim(),
      tipo: tipoEnum,
      obligatoria: _obligatoria,
      tema: temaSeleccionado,
      // Soporte dual de imagen
      imagenPath: _imagenPath,
      imagenBytes: _imagenBytes,
      imagenMime: _imagenMime,
      imagenNombre: _imagenNombre,
      ordenDeseado: orden,
      opciones: opcionesFiltradas,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Pregunta agregada')));

    // Volver al listado (EditarVariables)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => NavigationHelper.buildEditarVariables(widget.clienteUsuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temas = _ctrl.getTemas();

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Logos
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      return isMobile
                          ? Column(
                            children: [
                              Image.asset('assets/logo.png', height: 80),
                              const SizedBox(height: 12),
                              Image.asset('assets/cliente.png', height: 80),
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
                  const SizedBox(height: 16),

                  const Text(
                    'Agregar Pregunta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tipo
                  AppDropdown<String>(
                    label: 'Tipo de pregunta',
                    value: _tipo,
                    items:
                        ['Abierta', 'Selección Múltiple']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _tipo = v ?? 'Abierta'),
                  ),
                  const SizedBox(height: 16),

                  // Campos
                  AppTextField(label: 'Referencia', controller: _refCtrl),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Texto de la pregunta',
                    controller: _textoCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Orden',
                    controller: _ordenCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Tema
                  AppDropdown<int>(
                    label: 'Tema',
                    value: _temaId,
                    items:
                        temas
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.key as int,
                                child: Text(t.nombre),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _temaId = v),
                  ),
                  const SizedBox(height: 8),

                  CheckboxListTile(
                    value: _obligatoria,
                    onChanged: (v) => setState(() => _obligatoria = v ?? true),
                    title: const Text(
                      'Obligatoria',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: const Color(0xFFFF5F00),
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 8),

                  // Imagen
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      'Seleccionar imagen de apoyo',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5F00),
                      elevation: 0,
                    ),
                  ),

                  // Preview dual
                  if (_imagenBytes != null || _imagenPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child:
                          kIsWeb
                              ? Image.memory(
                                _imagenBytes!,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                              : Image.file(
                                File(_imagenPath!),
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                    ),

                  // Opciones (si es múltiple)
                  if (_tipo == 'Selección Múltiple') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Opciones:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._opcionesCtrls.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: AppTextField(
                                label: 'Opción',
                                controller: e.value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white70,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _opcionesCtrls.removeAt(e.key),
                                  ),
                              tooltip: 'Eliminar opción',
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar opción',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed:
                          () => setState(
                            () => _opcionesCtrls.add(TextEditingController()),
                          ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Guardar
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5F00),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guardar Pregunta',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ← Flecha naranja (vuelve al listado de variables)
          AppBackButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => NavigationHelper.buildEditarVariables(
                        widget.clienteUsuario,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
