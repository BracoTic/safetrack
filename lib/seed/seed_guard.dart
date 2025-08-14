// lib/seed/seed_guard.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';

import '../core/services/hive_config.dart'; // limpiarHive(), initHive()
import '../core/utils/default_data.dart'; // borrarYAgregarDatosPorDefecto()

/// Caja meta para guardar banderas de siembra.
const _metaBoxName = 'app_meta';
const _seedFlagKey = 'default_seeded_v1'; // ← súbele versión si cambias el seed

Future<Box> _openMetaBox() async {
  if (!Hive.isBoxOpen(_metaBoxName)) {
    await Hive.openBox(_metaBoxName);
  }
  return Hive.box(_metaBoxName);
}

Future<bool> _isSeeded() async {
  final b = await _openMetaBox();
  return (b.get(_seedFlagKey, defaultValue: false) as bool);
}

Future<void> _markSeeded(bool v) async {
  final b = await _openMetaBox();
  await b.put(_seedFlagKey, v);
}

/// Lee parámetros de la URL (Web) sin romper en móvil/escritorio.
Map<String, String> _queryParams() {
  try {
    return Uri.base.queryParameters;
  } catch (_) {
    return const {};
  }
}

/// ⚙️ Punto único de entrada desde main():
/// - ?reset=1  → limpiar + seed SIEMPRE
/// - ?seed=1   → seed solo si no estaba sembrado
/// - normal    → seed solo la primera vez
Future<void> initDatosPorDefectoSiHaceFalta() async {
  // 1) Triggers por URL (solo Web)
  final qp = _queryParams();
  final doReset = qp['reset'] == '1';
  final doSeed = qp['seed'] == '1';

  if (doReset) {
    // Limpia y vuelve a sembrar (útil para demos o “dejar todo como nuevo”)
    await limpiarHive(); // tu helper ya maneja Web vs no-Web
    await initHive(); // re-inicializa adaptadores si hace falta
    await borrarYAgregarDatosPorDefecto();
    await _markSeeded(true);
    return;
  }

  if (doSeed) {
    // Si no estaba sembrado, siembra ahora
    if (!(await _isSeeded())) {
      await borrarYAgregarDatosPorDefecto();
      await _markSeeded(true);
    }
    return;
  }

  // 2) Camino normal (sembrar una sola vez por navegador)
  if (!(await _isSeeded())) {
    await borrarYAgregarDatosPorDefecto();
    await _markSeeded(true);
  }
}

/// Forzar reseed programático (por ejemplo, botón oculto en Admin).
Future<void> forceResetAndSeed() async {
  await limpiarHive();
  await initHive();
  await borrarYAgregarDatosPorDefecto();
  await _markSeeded(true);
}

/// Borra solo la bandera (para pruebas avanzadas).
Future<void> clearSeedFlag() async {
  final b = await _openMetaBox();
  await b.delete(_seedFlagKey);
}
