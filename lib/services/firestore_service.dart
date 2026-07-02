import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/residuo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Usamos un solo usuario fijo (sin login) para la demo
  final String _userId = 'usuario_demo';

  DocumentReference get _userDoc => _db.collection('usuarios').doc(_userId);

  /// Guarda un nuevo residuo clasificado y actualiza los puntos totales
  Future<void> guardarResiduo(Residuo residuo) async {
    await _userDoc.collection('historial').add(residuo.toMap());

    await _userDoc.set({
      'puntos': FieldValue.increment(residuo.puntos),
    }, SetOptions(merge: true));
  }

  /// Obtiene los puntos totales actuales del usuario
  Future<int> obtenerPuntos() async {
    final doc = await _userDoc.get();
    if (!doc.exists) return 0;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['puntos'] ?? 0;
  }

  /// Calcula el nivel según los puntos
  String calcularNivel(int puntos) {
    if (puntos >= 300) return 'Eco Héroe';
    if (puntos >= 150) return 'Eco Guerrero';
    if (puntos >= 50) return 'Reciclador Bronce';
    return 'Reciclador Novato';
  }

  /// Obtiene los últimos N residuos clasificados (para el agente)
  Future<List<Residuo>> obtenerHistorialReciente({int limite = 10}) async {
    final snapshot = await _userDoc
        .collection('historial')
        .orderBy('fecha', descending: true)
        .limit(limite)
        .get();

    return snapshot.docs.map((doc) => Residuo.fromMap(doc.data())).toList();
  }

  /// Obtiene todo el historial (para la pantalla de Historial y cálculo de racha)
  Future<List<Residuo>> obtenerHistorialCompleto() async {
    final snapshot = await _userDoc
        .collection('historial')
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) => Residuo.fromMap(doc.data())).toList();
  }

  /// Cuenta el total de residuos clasificados históricamente
  Future<int> contarResiduos() async {
    final snapshot = await _userDoc.collection('historial').get();
    return snapshot.docs.length;
  }

  /// Calcula la racha de días consecutivos reciclando
  int calcularRacha(List<Residuo> historial) {
    if (historial.isEmpty) return 0;

    final fechasUnicas = historial
        .map((r) => DateTime(r.fecha.year, r.fecha.month, r.fecha.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    final diferenciaConHoy = hoySinHora.difference(fechasUnicas.first).inDays;
    if (diferenciaConHoy > 1) return 0;

    int racha = 1;
    for (int i = 0; i < fechasUnicas.length - 1; i++) {
      final diferencia = fechasUnicas[i].difference(fechasUnicas[i + 1]).inDays;
      if (diferencia == 1) {
        racha++;
      } else {
        break;
      }
    }

    return racha;
  }

  /// Stream en tiempo real de los puntos (útil para actualizar el Home automáticamente)
  Stream<int> streamPuntos() {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['puntos'] ?? 0;
    });
  }
}