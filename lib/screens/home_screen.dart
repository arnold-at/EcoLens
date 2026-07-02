import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';
import '../models/residuo.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GeminiService _geminiService = GeminiService();

  String _sugerencia = 'Cargando tu recomendación...';
  bool _cargandoSugerencia = true;
  int _totalResiduos = 0;
  int _racha = 0;
  bool _mostrarNiveles = false;

  @override
  void initState() {
    super.initState();
    _cargarSugerencia();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final historial = await _firestoreService.obtenerHistorialCompleto();
    final racha = _firestoreService.calcularRacha(historial);
    setState(() {
      _totalResiduos = historial.length;
      _racha = racha;
    });
  }

  Future<void> _cargarSugerencia() async {
    try {
      final historial = await _firestoreService.obtenerHistorialReciente(limite: 5);

      if (historial.isEmpty) {
        setState(() {
          _sugerencia = '¡Aún no has reciclado nada! Toma una foto de tu primer residuo para empezar.';
          _cargandoSugerencia = false;
        });
        return;
      }

      final tipos = historial.map((r) => r.tipo).toList();
      final sugerencia = await _geminiService.generarSugerencia(tipos);

      setState(() {
        _sugerencia = sugerencia;
        _cargandoSugerencia = false;
      });
    } catch (e) {
      setState(() {
        _sugerencia = '¡Sigue reciclando, cada acción cuenta!';
        _cargandoSugerencia = false;
      });
    }
  }

  List<int> _rangoNivel(int puntos) {
    if (puntos >= 300) return [300, 300];
    if (puntos >= 150) return [150, 300];
    if (puntos >= 50) return [50, 150];
    return [0, 50];
  }

  String _emojiPorNivel(String nivel) {
    switch (nivel) {
      case 'Eco Héroe':
        return '🌟';
      case 'Eco Guerrero':
        return '🌳';
      case 'Reciclador Bronce':
        return '🌿';
      default:
        return '🌱';
    }
  }

  String _saludoPorHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return '¡Buenos días, Eco Warrior! 🌞';
    if (hora >= 12 && hora < 19) return '¡Buenas tardes, Eco Warrior! 🌤️';
    return '¡Buenas noches, Eco Warrior! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🍃', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('EcoLens'),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo dinámico
              Text(
                _saludoPorHora(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sigamos cuidando el planeta juntos',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // Card de nivel, puntos y progreso
              StreamBuilder<int>(
                stream: _firestoreService.streamPuntos(),
                builder: (context, snapshot) {
                  final puntos = snapshot.data ?? 0;
                  final nivel = _firestoreService.calcularNivel(puntos);
                  final rango = _rangoNivel(puntos);
                  final minNivel = rango[0];
                  final maxNivel = rango[1];
                  final esNivelMaximo = minNivel == maxNivel;

                  final progreso = esNivelMaximo
                      ? 1.0
                      : (puntos - minNivel) / (maxNivel - minNivel);

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _mostrarNiveles = !_mostrarNiveles),
                              child: Row(
                                children: [
                                  Text(
                                    _emojiPorNivel(nivel),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    nivel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _mostrarNiveles
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Text('🍃', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '$puntos pts',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progreso.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          esNivelMaximo
                              ? '¡Nivel máximo alcanzado! 🎉'
                              : 'Te faltan ${maxNivel - puntos} pts para el siguiente nivel',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),

                        // Listado de niveles (colapsable)
                        if (_mostrarNiveles) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: const [
                                _NivelItem(emoji: '🌱', nombre: 'Reciclador Novato', rango: '0 - 49 pts'),
                                SizedBox(height: 8),
                                _NivelItem(emoji: '🌿', nombre: 'Reciclador Bronce', rango: '50 - 149 pts'),
                                SizedBox(height: 8),
                                _NivelItem(emoji: '🌳', nombre: 'Eco Guerrero', rango: '150 - 299 pts'),
                                SizedBox(height: 8),
                                _NivelItem(emoji: '🌟', nombre: 'Eco Héroe', rango: '300+ pts'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Contador de residuos + racha
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text('♻️', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalResiduos',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'clasificados',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      decoration: BoxDecoration(
                        color: _racha > 0 ? Colors.orange.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _racha > 0 ? Colors.orange.shade200 : Colors.green.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            '$_racha',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'días seguidos',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Tu agente EcoLens sugiere:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _cargandoSugerencia
                          ? Row(
                              children: const [
                                Text('🌱', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tu agente está pensando una idea para ti...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _sugerencia,
                              style: const TextStyle(fontSize: 15),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraScreen()),
                    );
                    _cargarSugerencia();
                    _cargarDatos();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Clasificar residuo',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NivelItem extends StatelessWidget {
  final String emoji;
  final String nombre;
  final String rango;

  const _NivelItem({
    required this.emoji,
    required this.nombre,
    required this.rango,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            nombre,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          rango,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}