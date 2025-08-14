import 'dart:io' show Directory, File;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/usuario.dart';
import '../../models/rol.dart';
import '../../models/ranking.dart';
import '../../models/clasificacion.dart';
import '../../models/tema.dart';
import '../../models/pregunta.dart';
import '../../models/opcion_multiple.dart';
import '../../models/evidencia.dart';
import '../../models/cliente.dart';
import '../../models/cliente_usuario.dart';
import '../../models/reporte.dart';
import '../../models/tipo_pregunta.dart';
import '../../models/respuesta.dart';
import '../../models/reporte_pregunta.dart'; // Asegúrate de importar el modelo de la tabla intermedia

late Directory hiveDirectory;

Future<void> ensureHiveDirectoryInitialized() async {
  if (kIsWeb) {
    await Hive.initFlutter(); // ✅ Web-safe
  } else {
    hiveDirectory = await getApplicationSupportDirectory();
    Hive.init(hiveDirectory.path);
  }
}

bool hiveDirectoryExists() {
  try {
    return kIsWeb ? true : hiveDirectory.path.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<void> limpiarHive() async {
  if (!kIsWeb) {
    await ensureHiveDirectoryInitialized();
    final files = hiveDirectory.listSync(recursive: true);
    for (final file in files) {
      if (file is File && file.path.endsWith('.hive')) {
        print('🧹 Eliminando archivo Hive: ${file.path}');
        await file.delete();
      }
    }
  }
}

Future<void> initHive() async {
  await ensureHiveDirectoryInitialized();

  Hive
    ..registerAdapter(RolAdapter())
    ..registerAdapter(UsuarioAdapter())
    ..registerAdapter(ClasificacionAdapter())
    ..registerAdapter(TemaAdapter())
    ..registerAdapter(RankingAdapter())
    ..registerAdapter(TipoPreguntaAdapter())
    ..registerAdapter(PreguntaAdapter())
    ..registerAdapter(OpcionMultipleAdapter())
    ..registerAdapter(EvidenciaAdapter())
    ..registerAdapter(ClienteAdapter())
    ..registerAdapter(ClienteUsuarioAdapter())
    ..registerAdapter(ReporteAdapter())
    ..registerAdapter(ReportePreguntaAdapter())
    ..registerAdapter(RespuestaAdapter()); // ✅ <-- Faltaba este

  await Hive.openBox<Usuario>('usuarios');
  await Hive.openBox<Clasificacion>('clasificaciones');
  await Hive.openBox<Tema>('temas');
  await Hive.openBox<Ranking>('rankings');
  await Hive.openBox<TipoPregunta>('tipo_pregunta');
  await Hive.openBox<Pregunta>('preguntas');
  await Hive.openBox<OpcionMultiple>('opcionesMultiple');
  await Hive.openBox<Evidencia>('evidencias');
  await Hive.openBox<Cliente>('clientes');
  await Hive.openBox<ClienteUsuario>('cliente_usuarios');
  await Hive.openBox<Reporte>('reportes');
  await Hive.openBox<ReportePregunta>('reporte_pregunta');
  await Hive.openBox<Respuesta>('respuestas'); // ✅ <-- Faltaba esta línea
}
