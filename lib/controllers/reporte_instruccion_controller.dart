import 'package:flutter/material.dart';
import '../../models/cliente_usuario.dart';
import '../views/reporte_screen.dart';

class ReporteInstruccionController {
  static void iniciarReporte(
    BuildContext context,
    ClienteUsuario clienteUsuario,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporteScreen(clienteUsuario: clienteUsuario),
      ),
    );
  }
}
