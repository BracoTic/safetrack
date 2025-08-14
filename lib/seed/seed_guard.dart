// core/utils/seed_guard.dart
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:hive/hive.dart';
import '../core/utils/default_data.dart';

const _metaBoxName = 'meta_safetrack_seed';

/// Llamar una sola vez en main(): decide si hay que sembrar.
/// - Si es la primera vez -> siembra.
/// - Si la URL trae ?reset=1 (Web) -> resetea/siembra.
/// - En móvil/desktop no hace nada extra salvo primera vez.
Future<void> initDatosPorDefectoSiHaceFalta() async {
  final meta = await Hive.openBox(_metaBoxName);

  // 1) Forzar reset desde URL (solo Web): https://.../safetrack/?reset=1
  final qp = Uri.base.queryParameters;
  final resetFromUrl = kIsWeb && (qp['reset'] == '1');

  if (resetFromUrl) {
    await _resetAndSeed(meta);
    return;
  }

  // 2) Primera vez (no existe flag)
  final seeded = meta.get('seeded', defaultValue: false) as bool;
  if (!seeded) {
    await _resetAndSeed(meta);
  }
}

/// Botón/acción manual (por ejemplo en un menú oculto de admin).
Future<void> resetDemoData() async {
  final meta = await Hive.openBox(_metaBoxName);
  await _resetAndSeed(meta);
}

Future<void> _resetAndSeed(Box meta) async {
  // Tu función ya maneja Web/Móvil y limpia/siembra cajas
  await borrarYAgregarDatosPorDefecto();
  await meta.put('seeded', true);
}
