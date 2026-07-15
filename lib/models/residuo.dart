class Residuo {
  final String material;
  final String tacho;
  final String categoriaTacho;
  final String mensajeImpacto;
  final DateTime fecha;
  final int puntos;
  final String confianza; // ALTA, MEDIA, BAJA

  Residuo({
    required this.material,
    required this.tacho,
    required this.categoriaTacho,
    required this.mensajeImpacto,
    required this.fecha,
    required this.puntos,
    this.confianza = 'ALTA',
  });

  Map<String, dynamic> toMap() {
    return {
      'material': material,
      'tacho': tacho,
      'categoriaTacho': categoriaTacho,
      'mensajeImpacto': mensajeImpacto,
      'fecha': fecha,
      'puntos': puntos,
      'confianza': confianza,
    };
  }

  factory Residuo.fromMap(Map<String, dynamic> map) {
    return Residuo(
      material: map['material'] ?? '',
      tacho: map['tacho'] ?? 'NEGRO',
      categoriaTacho: map['categoriaTacho'] ?? 'No aprovechables',
      mensajeImpacto: map['mensajeImpacto'] ?? '',
      fecha: (map['fecha'] as dynamic).toDate(),
      puntos: map['puntos'] ?? 0,
      confianza: map['confianza'] ?? 'ALTA',
    );
  }
}