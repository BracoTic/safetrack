import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/reporte.dart';
import '../models/pregunta.dart';
import '../models/cliente_usuario.dart';
import '../models/respuesta.dart';
import '../models/ranking.dart'; // rankings para el popup de usuario
import '../data/local/dao/pregunta_dao.dart';

import '/core/ui/app_chrome.dart'; // AppBackButton, AppOrangePanel
import '/core/ui/app_fields.dart'; // AppTextField
import '/core/entities/usuario_detalle.dart'; // entidad del popup
import '/widgets/detalle_usuario_popup.dart'; // mostrarDetalleUsuarioPopup
import '/widgets/detalle_reporte_popup.dart'; // popup de detalle de reporte

class VisualizarCienciaDatosScreen extends StatefulWidget {
  final ClienteUsuario clienteUsuario;

  const VisualizarCienciaDatosScreen({super.key, required this.clienteUsuario});

  @override
  State<VisualizarCienciaDatosScreen> createState() =>
      _VisualizarCienciaDatosScreenState();
}

class _VisualizarCienciaDatosScreenState
    extends State<VisualizarCienciaDatosScreen> {
  final _preguntaDao = PreguntaDAO();
  final _filterCtrl = TextEditingController();

  // Scrollbars blancas (horizontal / vertical)
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  bool _loading = true;
  List<Pregunta> _preguntas = [];
  List<Reporte> _reportesAll = [];
  List<Reporte> _reportesFiltrados = [];

  /// respuestas[reporteId][preguntaId] = "texto"
  final Map<int, Map<int, String>> _respuestas = {};

  /// --- Filtros avanzados ---
  final Map<String, bool> _estadosSel = {
    'pendiente': true,
    'aprobado': true,
    'rechazado': true,
  };

  DateTime? _desdeFecha;
  DateTime? _hastaFecha;
  TimeOfDay? _desdeHora;
  TimeOfDay? _hastaHora;

  /// Columnas visibles (por pregunta)
  Map<int, bool> _colSel = {};

  @override
  void initState() {
    super.initState();
    _filterCtrl.addListener(_aplicarFiltros);
    _loadAll();
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    // 1) Columnas: preguntas activas (ordenadas)
    final preguntas = await _preguntaDao.getAllActivas();
    preguntas.sort((a, b) => a.numeroOrden.compareTo(b.numeroOrden));

    // 2) Filas: TODOS los reportes (ordenados por fecha desc)
    final reportesBox = await Hive.openBox<Reporte>('reportes');
    final base =
        reportesBox.values.toList()
          ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    // 3) Respuestas indexadas
    final respBox = await Hive.openBox<Respuesta>('respuestas');
    final Map<int, Map<int, String>> respuestas = {};
    for (final resp in respBox.values) {
      final repId = resp.reporte.idReporte;
      final pregId = resp.pregunta.idPregunta!;
      respuestas.putIfAbsent(repId, () => {});
      respuestas[repId]![pregId] = resp.respuesta;
    }

    setState(() {
      _preguntas = preguntas;
      _reportesAll = base;
      _reportesFiltrados = List.of(base);
      _respuestas
        ..clear()
        ..addAll(respuestas);
      _colSel = {for (final p in preguntas) p.idPregunta!: true};
      _loading = false;
    });
  }

  // ===== Helpers Usuario popup =====
  String _periodoActual() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<UsuarioDetalle> _construirDetalle(ClienteUsuario cu) async {
    final reportesBox = await Hive.openBox<Reporte>('reportes');
    final delUsuario = reportesBox.values.where(
      (r) =>
          r.clienteUsuario.usuario.numeroIdentificacion ==
          cu.usuario.numeroIdentificacion,
    );

    final total = delUsuario.length;
    final pendientes =
        delUsuario
            .where((r) => (r.aprobacion.toLowerCase() == 'pendiente'))
            .length;
    final aprobados =
        delUsuario
            .where((r) => (r.aprobacion.toLowerCase() == 'aprobado'))
            .length;
    final rechazados =
        delUsuario
            .where((r) => (r.aprobacion.toLowerCase() == 'rechazado'))
            .length;

    final rankingsBox = await Hive.openBox<Ranking>('rankings');
    final todosRankings = rankingsBox.values.where(
      (rk) =>
          rk.usuario.usuario.numeroIdentificacion ==
          cu.usuario.numeroIdentificacion,
    );

    final periodo = _periodoActual();
    final mensual =
        todosRankings.where((rk) => rk.periodo == periodo).toList()
          ..sort((a, b) => a.periodo.compareTo(b.periodo));
    final rMensual = mensual.isNotEmpty ? mensual.last : null;

    final puntosAcumulados = todosRankings.fold<int>(
      0,
      (acc, rk) => acc + rk.puntuacion,
    );

    final rMasReciente =
        (todosRankings.toList()
          ..sort((a, b) => a.periodo.compareTo(b.periodo)));
    final medallaAcumulada =
        rMasReciente.isNotEmpty ? rMasReciente.last.medalla : 'Sin medalla';

    return UsuarioDetalle(
      usuario: cu.usuario,
      totalReportes: total,
      pendientes: pendientes,
      aprobados: aprobados,
      rechazados: rechazados,
      medallaMensual: rMensual?.medalla ?? 'Sin medalla',
      puntajeMensual: rMensual?.puntuacion ?? 0,
      medallaAcumulada: medallaAcumulada,
      puntajeAcumulado: puntosAcumulados,
    );
  }

  Future<void> _abrirPopupUsuario(ClienteUsuario cu) async {
    final detalle = await _construirDetalle(cu);
    mostrarDetalleUsuarioPopup(context, detalle);
  }

  // ===== Detalle de reporte =====
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

  Future<void> _abrirPopupReporte(Reporte rep) async {
    final ok = await mostrarDetalleReportePopup(context, reporte: rep);
    if (ok == true) {
      await _loadAll();
      _aplicarFiltros(); // conserva filtros al refrescar
    }
  }

  // ===== Filtros avanzados =====
  Future<void> _pickDesdeFecha() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _desdeFecha ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => _desdeFecha = d);
    _aplicarFiltros();
  }

  Future<void> _pickHastaFecha() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _hastaFecha ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => _hastaFecha = d);
    _aplicarFiltros();
  }

  Future<void> _pickDesdeHora() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _desdeHora ?? const TimeOfDay(hour: 0, minute: 0),
    );
    if (t != null) setState(() => _desdeHora = t);
    _aplicarFiltros();
  }

  Future<void> _pickHastaHora() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _hastaHora ?? const TimeOfDay(hour: 23, minute: 59),
    );
    if (t != null) setState(() => _hastaHora = t);
    _aplicarFiltros();
  }

  DateTime? _combinar(DateTime? f, TimeOfDay? t, {required bool end}) {
    if (f == null && t == null) return null;
    final base = f ?? DateTime.now();
    final h = t?.hour ?? (end ? 23 : 0);
    final m = t?.minute ?? (end ? 59 : 0);
    final s = end ? 59 : 0;
    return DateTime(base.year, base.month, base.day, h, m, s);
  }

  void _limpiarFiltros() {
    setState(() {
      _estadosSel.updateAll((_, __) => true);
      _desdeFecha = null;
      _hastaFecha = null;
      _desdeHora = null;
      _hastaHora = null;
      _filterCtrl.clear();
    });
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final query = _filterCtrl.text.trim().toLowerCase();
    final activos =
        _estadosSel.entries.where((e) => e.value).map((e) => e.key).toSet();

    final from = _combinar(_desdeFecha, _desdeHora, end: false);
    final to = _combinar(_hastaFecha, _hastaHora, end: true);

    setState(() {
      _reportesFiltrados =
          _reportesAll.where((rep) {
            // Estado
            if (!activos.contains(rep.aprobacion.toLowerCase())) return false;

            // Fecha/hora
            if (from != null && rep.fechaHora.isBefore(from)) return false;
            if (to != null && rep.fechaHora.isAfter(to)) return false;

            if (query.isEmpty) return true;

            final nombre = rep.clienteUsuario.usuario.nombre.toLowerCase();
            if (nombre.contains(query)) return true;

            final mapa = _respuestas[rep.idReporte] ?? const <int, String>{};
            return mapa.values.any((v) => v.toLowerCase().contains(query));
          }).toList();
    });
  }

  void _editarColumnas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D2136),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Columnas a mostrar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ListView(
                  children:
                      _preguntas.map((p) {
                        final id = p.idPregunta!;
                        final val = _colSel[id] ?? true;
                        return CheckboxListTile(
                          value: val,
                          onChanged:
                              (v) => setState(() => _colSel[id] = v ?? true),
                          title: Text(
                            p.texto,
                            style: const TextStyle(color: Colors.white),
                          ),
                          activeColor: const Color(0xFFFF5F00),
                          checkColor: Colors.black,
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed:
                        () => setState(() {
                          for (final p in _preguntas)
                            _colSel[p.idPregunta!] = true;
                        }),
                    child: const Text('Seleccionar todo'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        () => setState(() {
                          for (final p in _preguntas)
                            _colSel[p.idPregunta!] = false;
                        }),
                    child: const Text('Limpiar'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5F00),
                    ),
                    child: const Text(
                      'Aplicar',
                      style: TextStyle(color: Colors.white),
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

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24293D),
      body: Stack(
        children: [
          SafeArea(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Visualizar Ciencia de Datos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Búsqueda libre
                          AppTextField(
                            label: 'Filtrar por usuario o respuesta…',
                            controller: _filterCtrl,
                          ),

                          const SizedBox(height: 10),

                          // Filtros avanzados (estado + fecha/hora + columnas)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1D29),
                              border: Border.all(
                                color: const Color(0xFFFF5F00),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _estadoChip('Pendiente', 'pendiente'),
                                _estadoChip('Aprobado', 'aprobado'),
                                _estadoChip('Rechazado', 'rechazado'),

                                const SizedBox(width: 8),

                                // Fechas
                                OutlinedButton.icon(
                                  onPressed: _pickDesdeFecha,
                                  icon: const Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _desdeFecha == null
                                        ? 'Desde (fecha)'
                                        : '${_desdeFecha!.year}-${_desdeFecha!.month.toString().padLeft(2, '0')}-${_desdeFecha!.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFFF5F00),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _pickHastaFecha,
                                  icon: const Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _hastaFecha == null
                                        ? 'Hasta (fecha)'
                                        : '${_hastaFecha!.year}-${_hastaFecha!.month.toString().padLeft(2, '0')}-${_hastaFecha!.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFFF5F00),
                                    ),
                                  ),
                                ),

                                // Horas
                                OutlinedButton.icon(
                                  onPressed: _pickDesdeHora,
                                  icon: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _desdeHora == null
                                        ? 'Desde (hora)'
                                        : _desdeHora!.format(context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFFF5F00),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _pickHastaHora,
                                  icon: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _hastaHora == null
                                        ? 'Hasta (hora)'
                                        : _hastaHora!.format(context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFFF5F00),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Columnas
                                ElevatedButton.icon(
                                  onPressed: _editarColumnas,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7D86A7),
                                  ),
                                  icon: const Icon(
                                    Icons.view_column,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Columnas',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),

                                TextButton(
                                  onPressed: _limpiarFiltros,
                                  child: const Text('Limpiar filtros'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: AppOrangePanel(
                              padding: const EdgeInsets.all(20),
                              // Redondeo interior de la tabla
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _buildTabla(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
          // ← Flecha naranja de nuestra UI
          AppBackButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _estadoChip(String label, String key) {
    final activo = _estadosSel[key] ?? true;
    return FilterChip(
      selected: activo,
      label: Text(
        label,
        style: TextStyle(color: activo ? Colors.black : Colors.white),
      ),
      selectedColor: const Color(0xFFFF5F00),
      backgroundColor: const Color(0xFF2A3044),
      onSelected: (v) {
        setState(() => _estadosSel[key] = v);
        _aplicarFiltros();
      },
    );
  }

  Widget _buildTabla(BuildContext context) {
    // Columnas visibles
    final visibles =
        _preguntas.where((p) => _colSel[p.idPregunta!] == true).toList();

    final columns = <DataColumn>[
      const DataColumn(
        label: Text(
          'Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      ...visibles.map(
        (p) => DataColumn(
          label: Text(
            p.texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];

    final rows =
        _reportesFiltrados.map((rep) {
          final usuario = rep.clienteUsuario.usuario;
          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Ver detalle de usuario',
                      icon: const Icon(
                        Icons.account_circle,
                        color: Color(0xFFFF5F00),
                      ),
                      onPressed: () => _abrirPopupUsuario(rep.clienteUsuario),
                    ),
                    IconButton(
                      tooltip: 'Ver / editar reporte',
                      icon: Icon(
                        Icons.assignment,
                        color: _estadoColor(rep.aprobacion),
                      ),
                      onPressed: () => _abrirPopupReporte(rep),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        usuario.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              ...visibles.map((p) {
                final txt = _respuestas[rep.idReporte]?[p.idPregunta!] ?? '';
                return DataCell(
                  Text(
                    txt,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
          );
        }).toList();

    // Scrollbars blancas: horizontal (abajo) + vertical (derecha)
    return Container(
      color: const Color(0xFF1A1D29), // para que el redondeo se note
      child: RawScrollbar(
        controller: _hCtrl,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),
        thumbColor: Colors.white,
        trackColor: Colors.white24,
        child: SingleChildScrollView(
          controller: _hCtrl,
          scrollDirection: Axis.horizontal,
          child: RawScrollbar(
            controller: _vCtrl,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
            radius: const Radius.circular(8),
            thumbColor: Colors.white,
            trackColor: Colors.white24,
            child: SingleChildScrollView(
              controller: _vCtrl,
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFF1E2231),
                  ),
                  dataRowColor: MaterialStateProperty.all(
                    const Color(0xFF1A1D29),
                  ),
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  border: TableBorder.symmetric(
                    inside: const BorderSide(color: Color(0x22FFFFFF)),
                  ),
                  columns: columns,
                  rows: rows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
