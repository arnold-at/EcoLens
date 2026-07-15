import 'package:flutter/material.dart';

class TachoInfo {
  final String nombre;
  final Color color;
  final IconData icono;
  final String categoria;
  final String mensajeImpacto;

  const TachoInfo({
    required this.nombre,
    required this.color,
    required this.icono,
    required this.categoria,
    required this.mensajeImpacto,
  });
}

/// Tabla curada según Norma Técnica Peruana NTP 900.058:2019 (MINAM/INACAL)
/// Los mensajes de impacto son datos fijos, no generados por IA,
/// para evitar información imprecisa.
const Map<String, TachoInfo> tachosData = {
  'VERDE': TachoInfo(
    nombre: 'Verde - Aprovechables',
    color: Colors.green,
    icono: Icons.recycling,
    categoria: 'Aprovechables',
    mensajeImpacto:
        'Los residuos aprovechables (papel, cartón, vidrio, plástico y metales) '
        'pueden reingresar a la cadena productiva, reduciendo la extracción de '
        'materia prima virgen y el consumo de energía en su fabricación.',
  ),
  'MARRON': TachoInfo(
    nombre: 'Marrón - Orgánicos',
    color: Color(0xFF795548),
    icono: Icons.eco,
    categoria: 'Orgánicos',
    mensajeImpacto:
        'Los residuos orgánicos bien gestionados (compostaje) evitan la generación '
        'de metano en rellenos sanitarios, un gas de efecto invernadero mucho más '
        'potente que el CO₂.',
  ),
  'NEGRO': TachoInfo(
    nombre: 'Negro - No aprovechables',
    color: Color(0xFF424242),
    icono: Icons.delete_outline,
    categoria: 'No aprovechables',
    mensajeImpacto:
        'Estos residuos no tienen actualmente una ruta de reciclaje viable, por lo '
        'que se disponen en rellenos sanitarios. Reducir su generación es la mejor '
        'estrategia ambiental.',
  ),
  'ROJO': TachoInfo(
    nombre: 'Rojo - Peligrosos',
    color: Color(0xFFC62828),
    icono: Icons.warning_amber,
    categoria: 'Peligrosos',
    mensajeImpacto:
        'Los residuos peligrosos (pilas, medicinas, plaguicidas) requieren '
        'disposición especial: contienen sustancias tóxicas que pueden contaminar '
        'suelo y agua si se mezclan con residuos comunes.',
  ),
};

TachoInfo obtenerTachoInfo(String tacho) {
  return tachosData[tacho.toUpperCase()] ?? tachosData['NEGRO']!;
}