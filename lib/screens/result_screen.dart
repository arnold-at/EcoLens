import 'dart:io';
import 'package:flutter/material.dart';
import '../models/residuo.dart';

class ResultScreen extends StatefulWidget {
  final Residuo residuo;
  final File imagen;

  const ResultScreen({
    super.key,
    required this.residuo,
    required this.imagen,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _mostrarCategorias = false;

  Color _colorPorTipo(String tipo) {
    final tipoLower = tipo.toLowerCase();
    if (tipoLower.contains('plástico') || tipoLower.contains('plastico')) {
      return Colors.amber.shade700;
    } else if (tipoLower.contains('papel') || tipoLower.contains('cartón') || tipoLower.contains('carton')) {
      return Colors.blue.shade700;
    } else if (tipoLower.contains('vidrio')) {
      return Colors.green.shade700;
    } else if (tipoLower.contains('orgánico') || tipoLower.contains('organico')) {
      return Colors.brown.shade400;
    } else if (tipoLower.contains('metal')) {
      return Colors.blueGrey.shade600;
    } else if (tipoLower.contains('no reciclable')) {
      return Colors.grey.shade800;
    }
    return Colors.grey.shade700;
  }

  IconData _iconoPorTipo(String tipo) {
    final tipoLower = tipo.toLowerCase();
    if (tipoLower.contains('plástico') || tipoLower.contains('plastico')) {
      return Icons.local_drink;
    } else if (tipoLower.contains('papel') || tipoLower.contains('cartón') || tipoLower.contains('carton')) {
      return Icons.description;
    } else if (tipoLower.contains('vidrio')) {
      return Icons.wine_bar;
    } else if (tipoLower.contains('orgánico') || tipoLower.contains('organico')) {
      return Icons.eco;
    } else if (tipoLower.contains('metal')) {
      return Icons.settings;
    } else if (tipoLower.contains('no reciclable')) {
      return Icons.delete_forever;
    }
    return Icons.delete_outline;
  }

  @override
  Widget build(BuildContext context) {
    final residuo = widget.residuo;
    final imagen = widget.imagen;
    final color = _colorPorTipo(residuo.tipo);
    final icono = _iconoPorTipo(residuo.tipo);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  imagen,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Resultado de clasificación
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icono, color: color, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            residuo.tipo,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Contenedor: ${residuo.contenedor}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mensaje de impacto ambiental
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('♻️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        residuo.mensajeImpacto,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Puntos ganados (con animación)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '+${residuo.puntos} puntos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de categorías que el agente puede identificar (colapsable)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _mostrarCategorias = !_mostrarCategorias),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Categorías que el agente puede identificar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            _mostrarCategorias
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black45,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    if (_mostrarCategorias) ...[
                      const SizedBox(height: 10),
                      const _CategoriaItem(icono: Icons.local_drink, color: Colors.amber, nombre: 'Plástico'),
                      const _CategoriaItem(icono: Icons.description, color: Colors.blue, nombre: 'Papel y cartón'),
                      const _CategoriaItem(icono: Icons.wine_bar, color: Colors.green, nombre: 'Vidrio'),
                      const _CategoriaItem(icono: Icons.eco, color: Colors.brown, nombre: 'Orgánico'),
                      const _CategoriaItem(icono: Icons.settings, color: Colors.blueGrey, nombre: 'Metal'),
                      const _CategoriaItem(icono: Icons.delete_forever, color: Colors.grey, nombre: 'No reciclable'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriaItem extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String nombre;

  const _CategoriaItem({
    required this.icono,
    required this.color,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            nombre,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}