import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/residuo.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Residuo>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _historialFuture = _firestoreService.obtenerHistorialCompleto();
  }

  Future<void> _recargar() async {
    setState(() {
      _historialFuture = _firestoreService.obtenerHistorialCompleto();
    });
    await _historialFuture;
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Residuo>>(
        future: _historialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final historial = snapshot.data ?? [];

          if (historial.isEmpty) {
            return RefreshIndicator(
              onRefresh: _recargar,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🌱', style: TextStyle(fontSize: 70)),
                            const SizedBox(height: 16),
                            const Text(
                              'Todavía no hay historial',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Clasifica tu primer residuo\ny empieza a construir tu hábito ecológico',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final residuo = historial[index];
                final color = _colorPorTipo(residuo.tipo);
                final icono = _iconoPorTipo(residuo.tipo);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              residuo.tipo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd/MM/yyyy - HH:mm').format(residuo.fecha),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text('🍃', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '+${residuo.puntos}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}