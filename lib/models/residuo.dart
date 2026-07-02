class Residuo {
  final String tipo;
  final String contenedor;
  final String mensajeImpacto;
  final DateTime fecha;
  final int puntos;

  Residuo({
    required this.tipo,
    required this.contenedor,
    required this.mensajeImpacto,
    required this.fecha,
    required this.puntos,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'contenedor': contenedor,
      'mensajeImpacto': mensajeImpacto,
      'fecha': fecha,
      'puntos': puntos,
    };
  }

  factory Residuo.fromMap(Map<String, dynamic> map) {
    return Residuo(
      tipo: map['tipo'] ?? '',
      contenedor: map['contenedor'] ?? '',
      mensajeImpacto: map['mensajeImpacto'] ?? '',
      fecha: (map['fecha'] as dynamic).toDate(),
      puntos: map['puntos'] ?? 0,
    );
  }
}