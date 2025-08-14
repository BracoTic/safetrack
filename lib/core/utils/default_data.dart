import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

import '/models/usuario.dart';
import '/models/clasificacion.dart';
import '/models/tema.dart';
import '/models/ranking.dart';
import '/models/rol.dart';
import '/models/cliente.dart';
import '/models/cliente_usuario.dart';
import '/models/pregunta.dart';
import '/models/opcion_multiple.dart';
import '/models/tipo_pregunta.dart';
import '/models/reporte_pregunta.dart';
import '/models/reporte.dart';
import '/models/respuesta.dart';

class _PQ {
  final Pregunta p;
  final List<String>? opts;
  _PQ(this.p, [this.opts]);
}

String _periodoActual() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

// ———————————————————————————————
// Reset seguro por plataforma
// ———————————————————————————————
Future<void> _resetBox(String name) async {
  try {
    if (kIsWeb) {
      if (Hive.isBoxOpen(name)) {
        final b = Hive.box(name);
        await b.clear();
        await b.close();
      } else if (await Hive.boxExists(name)) {
        final b = await Hive.openBox(name);
        await b.clear();
        await b.close();
      }
    } else {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close();
      }
      if (await Hive.boxExists(name)) {
        await Hive.deleteBoxFromDisk(name);
      }
    }
  } catch (e) {
    debugPrint('[_resetBox] No se pudo reiniciar "$name": $e');
  }
}

// ———————————————————————————————
// Verifica que un asset exista/cargue
// ———————————————————————————————
Future<bool> _assetExiste(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (e) {
    debugPrint('[default-data] Asset NO encontrado: $path -> $e');
    return false;
  }
}

Future<void> borrarYAgregarDatosPorDefecto() async {
  final cajas = <String>[
    'usuarios',
    'clasificaciones',
    'temas',
    'rankings',
    'clientes',
    'cliente_usuarios',
    'preguntas',
    'opcionesMultiple',
    'reporte_pregunta',
    'reportes',
    'respuestas',
    'evidencias',
  ];

  // 1) Reset
  for (final caja in cajas) {
    await _resetBox(caja);
  }

  // 2) Abrir boxes
  final usuariosBox = await Hive.openBox<Usuario>('usuarios');
  final clasificacionesBox = await Hive.openBox<Clasificacion>(
    'clasificaciones',
  );
  final temasBox = await Hive.openBox<Tema>('temas');
  final rankingsBox = await Hive.openBox<Ranking>('rankings');
  final clientesBox = await Hive.openBox<Cliente>('clientes');
  final clienteUsuariosBox = await Hive.openBox<ClienteUsuario>(
    'cliente_usuarios',
  );
  final preguntasBox = await Hive.openBox<Pregunta>('preguntas');
  final opcionesBox = await Hive.openBox<OpcionMultiple>('opcionesMultiple');
  final reportePreguntaBox = await Hive.openBox<ReportePregunta>(
    'reporte_pregunta',
  );
  final reportesBox = await Hive.openBox<Reporte>('reportes');
  final respuestasBox = await Hive.openBox<Respuesta>('respuestas');

  // 3) Cliente y Tema
  final cliente = Cliente(
    nombre: 'Serinco',
    logoPath: 'assets/cliente.png',
    colorPrimario: '#CD5D1B',
    colorSecundario: '#FFCCB2',
  );
  await clientesBox.add(cliente);

  final tema = Tema(nombre: 'General', descripcion: 'Preguntas generales');
  await temasBox.add(tema);

  // 4) Clasificaciones
  final clasificaciones = [
    Clasificacion(
      nombre: 'Condición Insegura',
      descripcion: 'Puede causar accidente.',
    ),
    Clasificacion(nombre: 'Acto Inseguro', descripcion: 'Acción peligrosa.'),
    Clasificacion(
      nombre: 'Observación General',
      descripcion: 'Observación general.',
    ),
  ];
  for (var c in clasificaciones) {
    await clasificacionesBox.add(c);
  }

  // 5) Preguntas
  const _imgCriticidad = 'assets/images/preguntas/criticidad.png';
  final seeds = <_PQ>[
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto: 'EQUIPO',
        referencia: 'equipo',
        tipoPregunta: TipoPregunta.multiple,
        obligatoria: true,
        numeroOrden: 1,
        activa: true,
      ),
      ['Excavadora', 'Retro', 'Camion', 'Otro'],
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto: 'CAMPO',
        referencia: 'campo',
        tipoPregunta: TipoPregunta.string,
        obligatoria: true,
        numeroOrden: 2,
        activa: true,
      ),
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto: 'MARQUE CON UNA X',
        referencia: 'tipo_hallazgo',
        tipoPregunta: TipoPregunta.multiple,
        obligatoria: true,
        numeroOrden: 3,
        activa: true,
      ),
      ['CONDICION INSEGURA', 'ACTO INSEGURO', 'AMBIENTAL', 'FELICITACION'],
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto:
            '¿En qué lugar identificó el hallazgo?\nEj. Mesa rotaria, diques, torre, retractil, etc.',
        referencia: 'lugar_hallazgo',
        tipoPregunta: TipoPregunta.string,
        obligatoria: true,
        numeroOrden: 4,
        activa: true,
      ),
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto: '¿Qué hizo al identificar el hallazgo?',
        referencia: 'accion_inicial',
        tipoPregunta: TipoPregunta.string,
        obligatoria: true,
        numeroOrden: 5,
        activa: true,
      ),
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto:
            'DESCRIPCIÓN DEL INCIDENTE, ACTO, CONDICIÓN INSEGURA, FELICITACIÓN.',
        referencia: 'descripcion_evento',
        tipoPregunta: TipoPregunta.string,
        obligatoria: true,
        numeroOrden: 6,
        activa: true,
      ),
    ),
    // ← Pregunta 7: aseguramos el asset ANTES de persistir
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto:
            'Clasifique el Nivel de Criticidad de acuerdo con la imagen 1: Nivel de criticidad',
        referencia: 'nivel_criticidad',
        tipoPregunta: TipoPregunta.multiple,
        obligatoria: true,
        numeroOrden: 7,
        activa: true,
        imagenApoyo: _imgCriticidad,
      ),
      ['Muy alto', 'Alto', 'Medio', 'Bajo'],
    ),
    _PQ(
      Pregunta(
        idPregunta: 0,
        tema: tema,
        texto: 'AREA RESPONSABLE PARA CIERRE',
        referencia: 'area_responsable',
        tipoPregunta: TipoPregunta.multiple,
        obligatoria: true,
        numeroOrden: 8,
        activa: true,
      ),
      [
        'AREA HSE',
        'AREA OPERACIONAL',
        'ECOPETROL',
        'TERCERAS COMPAÑÍAS',
        'AREA MANTENIMIENTO',
      ],
    ),
  ];

  final clavesPreguntas = <int>[];
  final preguntas = <Pregunta>[];

  for (final s in seeds) {
    // Si es asset, verificamos que realmente exista
    if ((s.p.imagenApoyo ?? '').isNotEmpty &&
        s.p.imagenApoyo!.startsWith('assets/')) {
      final ok = await _assetExiste(s.p.imagenApoyo!);
      if (!ok) {
        // Evita guardar una ruta inválida que cause "nada" en Web
        debugPrint(
          '[default-data] Removiendo imagenApoyo inválida: ${s.p.imagenApoyo}',
        );
        s.p.imagenApoyo = null;
      }
    }

    final id = await preguntasBox.add(s.p);
    s.p.idPregunta = id;
    await s.p.save();
    clavesPreguntas.add(id);
    preguntas.add(s.p);

    if (s.opts != null && s.opts!.isNotEmpty) {
      for (final texto in s.opts!) {
        await opcionesBox.add(
          OpcionMultiple(idPregunta: id, textoOpcion: texto),
        );
      }
    }
  }

  // 6) Usuarios Serinco
  final usuarios = [
    Usuario(
      tipoIdentificacion: 'CC',
      numeroIdentificacion: '1000831233',
      nombre: 'Sebastian David Gonzalez Gutierrez',
      cargo: 'Operario',
      empresa: 'Serinco',
      rol: Rol.normal,
      contrasena: '1000831233',
      correo: 'sebastian@serinco.com',
      telefono: '3000000000',
    ),
    Usuario(
      tipoIdentificacion: 'CC',
      numeroIdentificacion: '1015449215',
      nombre: 'Juan Felipe Mesa Cuestas',
      cargo: 'HSEQ Manager',
      empresa: 'Serinco',
      rol: Rol.especial,
      contrasena: '1015449215',
      correo: 'juan@serinco.com',
      telefono: '3000000001',
    ),
    Usuario(
      tipoIdentificacion: 'CC',
      numeroIdentificacion: '1015429966',
      nombre: 'Oscar Felipe Bohorquez Garcia',
      cargo: 'Director de HSEQ Admin',
      empresa: 'Serinco',
      rol: Rol.admin,
      contrasena: '1015429966',
      correo: 'oscar@serinco.com',
      telefono: '3000000002',
    ),
  ];

  final periodo = _periodoActual();

  for (final u in usuarios) {
    await usuariosBox.add(u);

    final clienteUsuario = ClienteUsuario(
      cliente: cliente,
      usuario: u,
      rol: u.rol,
    );
    await clienteUsuariosBox.add(clienteUsuario);

    await rankingsBox.add(
      Ranking(
        cliente: cliente,
        usuario: clienteUsuario,
        periodo: periodo,
        puntuacion: 0,
        medalla: 'Sin medalla',
      ),
    );

    // Reporte demo (admin)
    if (u.numeroIdentificacion == '1015429966') {
      final reporte = Reporte(
        idReporte: 0,
        clienteUsuario: clienteUsuario,
        fechaHora: DateTime.now(),
        sincronizado: false,
        solucion: 'Pendiente',
        aprobacion: 'pendiente',
      );
      final idReporte = await reportesBox.add(reporte);
      reporte.idReporte = idReporte;
      await reporte.save();

      for (final idPregunta in clavesPreguntas) {
        await reportePreguntaBox.add(
          ReportePregunta(idReporte: idReporte, idPregunta: idPregunta),
        );
      }

      await respuestasBox.add(
        Respuesta(
          reporte: reporte,
          pregunta: preguntas[1],
          respuesta: 'Campo A',
        ),
      );
      await respuestasBox.add(
        Respuesta(
          reporte: reporte,
          pregunta: preguntas[0],
          respuesta: 'Excavadora',
        ),
      );
    }
  }

  // Debug corto para validar que la P7 quedó con imagen
  try {
    final p7 = preguntas.firstWhere((p) => p.referencia == 'nivel_criticidad');
    debugPrint('[default-data] P7 imagenApoyo = ${p7.imagenApoyo}');
  } catch (_) {}
}
