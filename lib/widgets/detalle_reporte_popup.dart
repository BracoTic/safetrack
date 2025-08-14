import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:hive/hive.dart';

// file_selector 1.0.3: solo usamos getDirectoryPath (no web)
import 'package:file_selector/file_selector.dart' show getDirectoryPath;

// ⬇️ helper de descarga con import condicional (web/no web)
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_html.dart'
    as webdl;

import '/models/reporte.dart';
import '/models/pregunta.dart';
import '/models/opcion_multiple.dart';
import '/models/respuesta.dart';
import '/models/evidencia.dart';
import '/models/reporte_pregunta.dart';
import '/models/tipo_pregunta.dart';

/// Abre el popup. Devuelve `true` si se guardó, `false/null` si se canceló.
Future<bool?> mostrarDetalleReportePopup(
  BuildContext context, {
  required Reporte reporte,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DetalleReporteDialog(reporte: reporte),
  );
}

class _DetalleReporteDialog extends StatefulWidget {
  final Reporte reporte;
  const _DetalleReporteDialog({required this.reporte});

  @override
  State<_DetalleReporteDialog> createState() => _DetalleReporteDialogState();
}

class _DetalleReporteDialogState extends State<_DetalleReporteDialog> {
  final _scrollCtrl = ScrollController();
  final GlobalKey _captureKey = GlobalKey();

  List<Pregunta> _preguntas = [];
  final Map<int, TextEditingController> _textoCtrls = {};
  final Map<int, String> _seleccionMultiple = {};
  final Map<int, List<OpcionMultiple>> _opciones = {};
  final Set<int> _editable = {};

  List<Evidencia> _evidencias = [];
  String _estado = 'pendiente';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _estado = widget.reporte.aprobacion.toLowerCase();
    _cargarTodo();
  }

  @override
  void dispose() {
    for (final c in _textoCtrls.values) {
      c.dispose();
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo() async {
    final rpBox = await Hive.openBox<ReportePregunta>('reporte_pregunta');
    final pBox = await Hive.openBox<Pregunta>('preguntas');
    final relaciones =
        rpBox.values
            .where((rp) => rp.idReporte == widget.reporte.idReporte)
            .toList();

    final preguntas = <Pregunta>[];
    for (final rp in relaciones) {
      final p = pBox.get(rp.idPregunta);
      if (p != null) preguntas.add(p);
    }
    preguntas.sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));

    final respBox = await Hive.openBox<Respuesta>('respuestas');
    final respuestasDeReporte =
        respBox.values
            .where((r) => r.reporte.idReporte == widget.reporte.idReporte)
            .toList();

    final opBox = await Hive.openBox<OpcionMultiple>('opcionesMultiple');
    final evidBox = await Hive.openBox<Evidencia>('evidencias');

    final opciones = <int, List<OpcionMultiple>>{};
    final textoCtrls = <int, TextEditingController>{};
    final seleccionMultiple = <int, String>{};

    for (final p in preguntas) {
      final pid = p.idPregunta;
      if (pid == null) continue;

      final existente =
          respuestasDeReporte
              .where((r) => r.pregunta.idPregunta == pid)
              .toList();

      if (p.tipoPregunta == TipoPregunta.string) {
        final valor = existente.isNotEmpty ? existente.first.respuesta : '';
        textoCtrls[pid] = TextEditingController(text: valor);
      } else {
        final valor = existente.isNotEmpty ? existente.first.respuesta : '';
        opciones[pid] = opBox.values.where((o) => o.idPregunta == pid).toList();
        seleccionMultiple[pid] = valor;
      }
    }

    final evidencias =
        evidBox.values
            .where((e) => e.reporte.idReporte == widget.reporte.idReporte)
            .toList();

    setState(() {
      _preguntas = preguntas;
      _opciones
        ..clear()
        ..addAll(opciones);
      _textoCtrls
        ..clear()
        ..addAll(textoCtrls);
      _seleccionMultiple
        ..clear()
        ..addAll(seleccionMultiple);
      _evidencias = evidencias;
      _cargando = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.amber;
    }
  }

  Future<void> _guardar() async {
    final reportesBox = await Hive.openBox<Reporte>('reportes');
    final lista =
        reportesBox.values
            .where((r) => r.idReporte == widget.reporte.idReporte)
            .toList();
    final r = lista.isNotEmpty ? lista.first : widget.reporte;
    r.aprobacion = _estado;
    await r.save();

    final respBox = await Hive.openBox<Respuesta>('respuestas');
    for (final p in _preguntas) {
      final pid = p.idPregunta;
      if (pid == null) continue;

      String valor = '';
      if (p.tipoPregunta == TipoPregunta.string) {
        valor = (_textoCtrls[pid]?.text ?? '').trim();
      } else {
        valor = (_seleccionMultiple[pid] ?? '').trim();
      }

      final existentes =
          respBox.values
              .where(
                (x) =>
                    x.reporte.idReporte == widget.reporte.idReporte &&
                    x.pregunta.idPregunta == pid,
              )
              .toList();

      if (existentes.isNotEmpty) {
        existentes.first.respuesta = valor;
        await existentes.first.save();
      } else if (valor.isNotEmpty) {
        await respBox.add(
          Respuesta(
            reporte: r,
            pregunta: p,
            respuesta: valor,
            sincronizado: false,
          ),
        );
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  // ----------------- CAPTURA COMPLETA DEL POPUP -----------------
  Future<Uint8List> _captureWholePopupToPngBytes({
    double pixelRatio = 3.0,
  }) async {
    final obj = _captureKey.currentContext?.findRenderObject();
    if (obj is! RenderRepaintBoundary) {
      throw StateError('No se encontró RenderRepaintBoundary');
    }

    if (!_scrollCtrl.hasClients ||
        !_scrollCtrl.position.hasViewportDimension ||
        _scrollCtrl.position.maxScrollExtent <= 0) {
      final one = await obj.toImage(pixelRatio: pixelRatio);
      final oneBytes =
          (await one.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
      return oneBytes;
    }

    final vp = _scrollCtrl.position.viewportDimension;
    final max = _scrollCtrl.position.maxScrollExtent;
    final contentLogicalHeight = max + vp;
    final original = _scrollCtrl.offset;

    final offsets = <double>[0];
    double off = 0;
    while (off + vp < max - 0.5) {
      off += vp;
      offsets.add(off);
    }
    if (offsets.isEmpty || (offsets.last - max).abs() > 0.5) offsets.add(max);

    final images = <ui.Image>[];

    for (final o in offsets) {
      _scrollCtrl.jumpTo(o);
      await WidgetsBinding.instance.endOfFrame;
      final img = await obj.toImage(pixelRatio: pixelRatio);
      images.add(img);
    }

    _scrollCtrl.jumpTo(original);
    await WidgetsBinding.instance.endOfFrame;

    final int widthPx = images.first.width;
    final int totalHeightPx = (contentLogicalHeight * pixelRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    for (int i = 0; i < images.length; i++) {
      final dyPx = offsets[i] * pixelRatio;
      canvas.drawImage(images[i], Offset(0, dyPx), paint);
    }

    final merged = await recorder.endRecording().toImage(
      widthPx,
      totalHeightPx,
    );
    final byteData = await merged.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Descarga PNG del contenido completo (Web + no Web)
  Future<void> _descargarPNG() async {
    try {
      final bytes = await _captureWholePopupToPngBytes(pixelRatio: 3.0);
      final filename =
          'reporte_${widget.reporte.idReporte}_${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        // ⬇️ Web: dispara descarga con <a download>
        final ok = await webdl.saveBytes(filename, bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? 'Descargando $filename…'
                    : 'No se pudo iniciar la descarga',
              ),
            ),
          );
        }
        return;
      }

      // ⬇️ Desktop/Móvil: elegir carpeta y escribir archivo
      final String? dir = await getDirectoryPath(
        confirmButtonText: 'Guardar aquí',
      );
      if (dir == null) return;

      final String sep = Platform.pathSeparator;
      final String fullPath = '$dir$sep$filename';
      final file = File(fullPath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PNG guardado en: $fullPath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al descargar PNG: $e')));
      }
    }
  }

  // ------------------------------ Helpers evidencia ------------------------------
  bool _hasBytes(Evidencia e) => (e.imgBytes != null && e.imgBytes!.isNotEmpty);
  bool _hasPath(Evidencia e) =>
      (e.imgInseguro != null && e.imgInseguro!.isNotEmpty);

  ImageProvider? _thumbProvider(Evidencia e) {
    if (_hasBytes(e)) return MemoryImage(e.imgBytes!);
    if (!kIsWeb && _hasPath(e)) return FileImage(File(e.imgInseguro!));
    return null;
  }

  Widget _previewDialog(Evidencia e) {
    if (_hasBytes(e)) {
      return Image.memory(e.imgBytes!, fit: BoxFit.contain);
    }
    if (!kIsWeb && _hasPath(e)) {
      return Image.file(File(e.imgInseguro!), fit: BoxFit.contain);
    }
    return const SizedBox(
      width: 480,
      height: 360,
      child: Center(
        child: Text(
          'Vista previa no disponible',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------------

  bool _isEditable(int pid) => _editable.contains(pid);
  void _toggleEditable(int pid) => setState(
    () => _editable.contains(pid) ? _editable.remove(pid) : _editable.add(pid),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF1D2136),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFF5F00), width: 1.5),
      ),
      child:
          _cargando
              ? const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
              : RepaintBoundary(
                key: _captureKey,
                child: RawScrollbar(
                  controller: _scrollCtrl,
                  thumbColor: Colors.white,
                  thickness: 6,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ),
                        Center(
                          child: Image.asset(
                            'assets/cliente.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.assignment,
                              color: _estadoColor(_estado),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Detalle de Reporte  •  ${widget.reporte.fechaHora.toLocal().toString().split(".").first}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Estado:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _estadoColor(_estado).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _estadoColor(_estado),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _estado,
                                dropdownColor: const Color(0xFF1D2136),
                                underline: const SizedBox.shrink(),
                                iconEnabledColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'pendiente',
                                    child: Text('Pendiente'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'aprobado',
                                    child: Text('Aprobado'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'rechazado',
                                    child: Text('Rechazado'),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(
                                      () => _estado = v ?? 'pendiente',
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text(
                          'Respuestas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._preguntas.map((p) {
                          final pid = p.idPregunta!;
                          final editable = _isEditable(pid);

                          if (p.tipoPregunta == TipoPregunta.string) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.texto,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip:
                                            editable
                                                ? 'Bloquear edición'
                                                : 'Editar respuesta',
                                        icon: Icon(
                                          Icons.edit,
                                          color:
                                              editable
                                                  ? const Color(0xFFFF5F00)
                                                  : Colors.white54,
                                        ),
                                        onPressed: () => _toggleEditable(pid),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _textoCtrls[pid],
                                    enabled: editable,
                                    maxLines: 2,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Respuesta...',
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF24293D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final ops =
                                _opciones[pid] ?? const <OpcionMultiple>[];
                            final actual = _seleccionMultiple[pid] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.texto,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip:
                                            editable
                                                ? 'Bloquear edición'
                                                : 'Editar selección',
                                        icon: Icon(
                                          Icons.edit,
                                          color:
                                              editable
                                                  ? const Color(0xFFFF5F00)
                                                  : Colors.white54,
                                        ),
                                        onPressed: () => _toggleEditable(pid),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  IgnorePointer(
                                    ignoring: !editable,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 0,
                                      children:
                                          ops.map((o) {
                                            final sel = actual == o.textoOpcion;
                                            return ChoiceChip(
                                              label: Text(
                                                o.textoOpcion,
                                                style: TextStyle(
                                                  color:
                                                      sel
                                                          ? Colors.black
                                                          : Colors.white,
                                                ),
                                              ),
                                              selected: sel,
                                              selectedColor: const Color(
                                                0xFFFF5F00,
                                              ),
                                              backgroundColor: const Color(
                                                0xFF2A3044,
                                              ),
                                              onSelected:
                                                  (_) => setState(
                                                    () =>
                                                        _seleccionMultiple[pid] =
                                                            o.textoOpcion,
                                                  ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        const Text(
                          'Evidencias',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_evidencias.isEmpty)
                          const Text(
                            'Sin evidencias adjuntas.',
                            style: TextStyle(color: Colors.white70),
                          )
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                _evidencias.map((ev) {
                                  final provider = _thumbProvider(ev);
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: InteractiveViewer(
                                                child: _previewDialog(ev),
                                              ),
                                            ),
                                      );
                                    },
                                    child: Container(
                                      width: 120,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFFF5F00),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFF2A3044),
                                        image:
                                            provider != null
                                                ? DecorationImage(
                                                  image: provider,
                                                  fit: BoxFit.cover,
                                                )
                                                : null,
                                      ),
                                      child:
                                          provider == null
                                              ? const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                ),
                                              )
                                              : null,
                                    ),
                                  );
                                }).toList(),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _descargarPNG,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7D86A7),
                              ),
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Descargar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5F00),
                                  ),
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Guardar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: _guardar,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
