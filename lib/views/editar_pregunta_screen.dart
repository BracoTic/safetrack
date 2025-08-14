import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pregunta.dart';
import '../models/cliente_usuario.dart';
import '../controllers/editar_pregunta_controller.dart';
import '../core/utils/navigation_helper.dart';
import '../models/tipo_pregunta.dart';

// ✅ UI reutilizable
import '/core/ui/app_chrome.dart'; // AppBackButton
import '/core/ui/app_fields.dart'; // AppTextField / AppDropdown

class EditarPreguntaScreen extends StatefulWidget {
  final Pregunta pregunta;
  final ClienteUsuario clienteUsuario;

  const EditarPreguntaScreen({
    Key? key,
    required this.pregunta,
    required this.clienteUsuario,
  }) : super(key: key);

  @override
  State<EditarPreguntaScreen> createState() => _EditarPreguntaScreenState();
}

class _EditarPreguntaScreenState extends State<EditarPreguntaScreen> {
  late final EditarPreguntaController ctrl;
  late final TextEditingController _textoCtrl;
  late final TextEditingController _referenciaCtrl;
  late final TextEditingController _ordenCtrl;
  late bool _obligatoria, _activa;
  late List<TextEditingController> _opCtrls;

  // Imagen (dual)
  String? _imgPath; // móvil/desktop
  Uint8List? _imgBytes; // web
  String? _imgMime;
  String? _imgNombre;

  @override
  void initState() {
    super.initState();
    ctrl = EditarPreguntaController(widget.pregunta);
    _textoCtrl = TextEditingController(text: widget.pregunta.texto);
    _referenciaCtrl = TextEditingController(
      text: widget.pregunta.referencia ?? '',
    );
    _ordenCtrl = TextEditingController(
      text: widget.pregunta.numeroOrden.toString(),
    );
    _obligatoria = widget.pregunta.obligatoria;
    _activa = widget.pregunta.activa;
    _opCtrls = ctrl.initOpcionesControllers();

    // Cargar imagen inicial (según plataforma)
    if (kIsWeb) {
      _imgBytes = widget.pregunta.imagenApoyoBytes;
      _imgMime = widget.pregunta.imagenApoyoMime;
      _imgNombre = widget.pregunta.imagenApoyoNombre;
      _imgPath = null;
    } else {
      _imgPath = widget.pregunta.imagenApoyo;
      _imgBytes = null;
      _imgMime = null;
      _imgNombre = null;
    }
  }

  Future<void> _pickImage() async {
    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pick == null) return;

    if (kIsWeb) {
      final bytes = await pick.readAsBytes();
      setState(() {
        _imgBytes = bytes;
        _imgMime = pick.mimeType;
        _imgNombre = pick.name;
        _imgPath = null;
      });
    } else {
      setState(() {
        _imgPath = pick.path;
        _imgBytes = null;
        _imgMime = null;
        _imgNombre = pick.name;
      });
    }
  }

  Future<void> _eliminarPregunta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Eliminar Pregunta?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    await ctrl.eliminarPregunta();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => NavigationHelper.buildEditarVariables(widget.clienteUsuario),
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Pregunta eliminada')));
  }

  Future<void> _save() async {
    await ctrl.guardarCambios(
      texto: _textoCtrl.text.trim(),
      referencia: _referenciaCtrl.text.trim(),
      nuevoOrden: int.tryParse(_ordenCtrl.text.trim()) ?? 0,
      obligatoria: _obligatoria,
      activa: _activa,
      // imagen dual
      nuevaImagenPath: _imgPath,
      nuevaImagenBytes: _imgBytes,
      nuevaImagenMime: _imgMime,
      nuevaImagenNombre: _imgNombre,
      // opciones
      opcionesTexto: _opCtrls.map((c) => c.text).toList(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    _referenciaCtrl.dispose();
    _ordenCtrl.dispose();
    for (var c in _opCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esMultiple = widget.pregunta.tipoPregunta == TipoPregunta.multiple;

    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Editar Pregunta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                AppTextField(label: 'Referencia', controller: _referenciaCtrl),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Texto',
                  controller: _textoCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Orden',
                  controller: _ordenCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  value: _obligatoria,
                  title: const Text(
                    'Obligatoria',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeColor: const Color(0xFFFF5F00),
                  onChanged: (v) => setState(() => _obligatoria = v),
                ),
                SwitchListTile(
                  value: _activa,
                  title: const Text(
                    'Activa',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeColor: const Color(0xFFFF5F00),
                  onChanged: (v) => setState(() => _activa = v),
                ),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text(
                    'Cambiar imagen',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5F00),
                  ),
                ),

                if ((_imgPath != null && _imgPath!.isNotEmpty) ||
                    _imgBytes != null) ...[
                  const SizedBox(height: 10),
                  kIsWeb
                      ? Image.memory(_imgBytes!, height: 150, fit: BoxFit.cover)
                      : Image.file(
                        File(_imgPath!),
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                ],

                if (esMultiple) ..._buildOpcionesUI(),

                const SizedBox(height: 30),

                // Guardar
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Eliminar
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Eliminar Pregunta',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _eliminarPregunta,
                  ),
                ),
              ],
            ),
          ),

          // ← Flecha naranja reutilizable
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

  List<Widget> _buildOpcionesUI() {
    return [
      const SizedBox(height: 16),
      const Text(
        'Opciones',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 8),
      ..._opCtrls.asMap().entries.map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(label: 'Opción', controller: e.value),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white70),
                onPressed: () => setState(() => _opCtrls.removeAt(e.key)),
                tooltip: 'Eliminar opción',
              ),
            ],
          ),
        ),
      ),
      TextButton.icon(
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar opción',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => setState(() => _opCtrls.add(TextEditingController())),
      ),
    ];
  }
}
