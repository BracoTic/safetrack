import 'dart:typed_data';
import 'dart:io' show File; // móvil/escritorio
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cliente_usuario.dart';
import '../models/pregunta.dart';
import '../models/tipo_pregunta.dart';
import '../models/opcion_multiple.dart';
import '../models/clasificacion.dart';
import '../controllers/reporte_controller.dart';
import '../data/local/dao/reporte_dao.dart';
import '../data/local/dao/pregunta_dao.dart';
import '../data/local/dao/opcion_multiple_dao.dart';
import '../data/local/dao/evidencia_dao.dart';
import '../data/local/dao/clasificacion_dao.dart';
import '../core/utils/navigation_helper.dart';
import 'gracias_screen.dart';
import '../models/reporte.dart';

class ReporteScreen extends StatefulWidget {
  final ClienteUsuario clienteUsuario;

  const ReporteScreen({Key? key, required this.clienteUsuario})
    : super(key: key);

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  late final ReporteController controller;

  // 🔹 Ya no creamos el reporte aquí.
  List<Pregunta> preguntas = [];
  Map<int, String> respuestasTexto = {};
  Map<int, String> respuestasMultiple = {};
  List<Clasificacion> clasificaciones = [];

  /// RUTAS (móvil/escritorio)
  List<String> imagenes = [];

  /// BYTES (Web; también válido en móvil si quieres)
  List<Uint8List?> imagenesBytes = [];

  List<String> seleccionClasificaciones = [];
  Map<int, List<OpcionMultiple>> opcionesMultiple = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    controller = ReporteController(
      clienteUsuario: widget.clienteUsuario,
      reporteDao: ReporteDAO(),
      preguntaDao: PreguntaDAO(),
      opcionMultipleDao: OpcionMultipleDAO(),
      evidenciaDao: EvidenciaDAO(),
    );
    _prepararFormulario();
  }

  /// 🔹 Carga preguntas activas, clasificaciones y opciones (SIN crear reporte).
  Future<void> _prepararFormulario() async {
    final ps = await controller.cargarPreguntasActivas();
    final cls = await ClasificacionDAO().getAll();

    final Map<int, List<OpcionMultiple>> ops = {};
    for (final p in ps.where((p) => p.tipoPregunta == TipoPregunta.multiple)) {
      if (p.idPregunta != null) {
        ops[p.idPregunta!] = await controller.obtenerOpciones(p.idPregunta!);
      }
    }

    setState(() {
      preguntas = ps;
      clasificaciones = cls;
      opcionesMultiple = ops;
      imagenes = [''];
      imagenesBytes = [null];
      seleccionClasificaciones = [cls.isNotEmpty ? cls.first.nombre : ''];
      _cargando = false;
    });
  }

  Future<void> _seleccionarImagen(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && index < imagenes.length) {
      final bytes = await picked.readAsBytes(); // en Web, esto es lo útil
      setState(() {
        imagenes[index] = picked.path; // móvil/escritorio
        imagenesBytes[index] = bytes; // Web
      });
    }
  }

  Future<void> _guardar() async {
    // 1) Validación
    if (!controller.validarRespuestas(
      preguntas,
      respuestasTexto,
      respuestasMultiple,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todas las respuestas obligatorias.'),
        ),
      );
      return;
    }

    // 2) Crear ahora el reporte (recién aquí)
    final Reporte reporte = await controller.crearReporte();

    // 3) Vincular las preguntas del formulario a este reporte
    await controller.vincularPreguntasAReporte(reporte.idReporte, preguntas);

    // 4) Preparar evidencias (filtrando vacíos y manteniendo alineación)
    final rutas = <String>[];
    final bytesList = <Uint8List?>[];
    final clasifs = <String>[];

    for (int i = 0; i < imagenes.length; i++) {
      final path = imagenes[i];
      final bts = (i < imagenesBytes.length) ? imagenesBytes[i] : null;

      final usableOnWeb = kIsWeb ? (bts != null && bts.isNotEmpty) : false;
      final usableOnMobile = !kIsWeb ? path.isNotEmpty : false;

      if (usableOnWeb || usableOnMobile) {
        rutas.add(path);
        bytesList.add(bts);
        clasifs.add(seleccionClasificaciones[i]);
      }
    }

    final evidencias = controller.crearEvidencias(
      reporte: reporte,
      imagenesPaths: rutas,
      imagenesBytes: bytesList,
      clasificacionesSeleccionadas: clasifs,
      clasificacionesDisponibles: clasificaciones,
    );

    if (evidencias.isNotEmpty) {
      await controller.agregarEvidencias(reporte, evidencias);
    }

    // 5) Guardar respuestas
    await controller.guardarRespuestas(
      reporte: reporte,
      preguntas: preguntas,
      respuestasTexto: respuestasTexto,
      respuestasMultiples: respuestasMultiple,
    );

    if (!mounted) return;

    // 6) Éxito → Gracias
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GraciasScreen(clienteUsuario: widget.clienteUsuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: SafeArea(
        child:
            _cargando
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset('assets/logo.png', height: 100),
                                  Image.asset(
                                    'assets/cliente.png',
                                    height: 100,
                                  ),
                                ],
                              );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed:
                              () => NavigationHelper.volverAlMenu(
                                context,
                                widget.clienteUsuario,
                              ),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFFF5F00),
                          ),
                          label: const Text(
                            'VOLVER AL MENÚ',
                            style: TextStyle(
                              color: Color(0xFFFF5F00),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFF5F00),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Encuesta HSEQ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...preguntas.map(_buildPreguntaCard).toList(),
                            const SizedBox(height: 24),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Observaciones Especiales',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              imagenes.length,
                              _buildObservacionCard,
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  imagenes.add('');
                                  imagenesBytes.add(null);
                                  seleccionClasificaciones.add(
                                    clasificaciones.isNotEmpty
                                        ? clasificaciones.first.nombre
                                        : '',
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFFFF5F00),
                              ),
                              label: const Text(
                                'Agregar Evidencia',
                                style: TextStyle(color: Color(0xFFFF5F00)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _guardar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5F00),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: const Text(
                                  'Finalizar Reporte',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildPreguntaCard(Pregunta p) {
    final key = p.idPregunta!;
    final opciones = opcionesMultiple[key] ?? [];

    // Prioridad imagen de apoyo:
    // 1) Bytes (web/móvil si existen)
    // 2) Asset (assets/…)
    // 3) Ruta local (solo móvil/desktop)
    Widget? apoyo;

    if ((p as dynamic).imagenApoyoBytes != null &&
        (p as dynamic).imagenApoyoBytes!.isNotEmpty) {
      final bytes = (p as dynamic).imagenApoyoBytes as Uint8List;
      apoyo = GestureDetector(
        onTap:
            () => showDialog(
              context: context,
              builder:
                  (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    ),
                  ),
            ),
        child: Image.memory(bytes, height: 100, fit: BoxFit.cover),
      );
    } else if ((p.imagenApoyo ?? '').isNotEmpty) {
      final isAsset = p.imagenApoyo!.startsWith('assets/');
      if (isAsset) {
        apoyo = GestureDetector(
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: InteractiveViewer(
                        child: Image.asset(p.imagenApoyo!, fit: BoxFit.contain),
                      ),
                    ),
              ),
          child: Image.asset(p.imagenApoyo!, height: 100, fit: BoxFit.cover),
        );
      } else {
        apoyo =
            kIsWeb
                ? const Center(
                  child: Text(
                    'Vista previa no disponible en web',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
                : GestureDetector(
                  onTap:
                      () => showDialog(
                        context: context,
                        builder:
                            (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                child: Image.file(File(p.imagenApoyo!)),
                              ),
                            ),
                      ),
                  child: Image.file(
                    File(p.imagenApoyo!),
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF5F00), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E2231),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta ${p.numeroOrden}: ${p.texto}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (apoyo != null) ...[const SizedBox(height: 8), apoyo],
          const SizedBox(height: 12),
          if (p.tipoPregunta == TipoPregunta.string) ...[
            TextFormField(
              onChanged: (v) => respuestasTexto[key] = v,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF24293D),
                border: OutlineInputBorder(),
                hintText: 'Escribe tu respuesta...',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ] else ...[
            ...opciones.map(
              (o) => RadioListTile<String>(
                activeColor: const Color(0xFFFF5F00),
                title: Text(
                  o.textoOpcion,
                  style: const TextStyle(color: Colors.white),
                ),
                value: o.textoOpcion,
                groupValue: respuestasMultiple[key],
                onChanged: (v) => setState(() => respuestasMultiple[key] = v!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObservacionCard(int i) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF5F00), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E2231),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observación ${i + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: seleccionClasificaciones[i],
            items:
                clasificaciones
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.nombre,
                        child: Text(c.nombre),
                      ),
                    )
                    .toList(),
            onChanged:
                (v) => setState(() => seleccionClasificaciones[i] = v ?? ''),
            dropdownColor: const Color(0xFF1E2231),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Clasificación',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _seleccionarImagen(i),
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar Imagen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D86A7),
            ),
          ),
          if ((kIsWeb &&
                  (imagenesBytes[i] != null && imagenesBytes[i]!.isNotEmpty)) ||
              (!kIsWeb && imagenes[i].isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child:
                  kIsWeb
                      ? Image.memory(
                        imagenesBytes[i]!,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                      : Image.file(
                        File(imagenes[i]),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
            ),
        ],
      ),
    );
  }
}
