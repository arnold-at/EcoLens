import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
  }

  /// Analiza una imagen de residuo y devuelve tipo, contenedor y mensaje de impacto
  Future<Map<String, String>> clasificarResiduo(Uint8List imagenBytes) async {
    final prompt = TextPart('''
Eres un asistente experto en reciclaje. Analiza la imagen del residuo 
y responde SOLO en este formato JSON, sin texto adicional ni markdown:
{
  "tipo": "Plástico/Papel y cartón/Vidrio/Orgánico/Metal/No reciclable",
  "contenedor": "color o nombre del contenedor correspondiente según normativa general de reciclaje",
  "mensajeImpacto": "1-2 frases cortas y educativas sobre el impacto ambiental de reciclar este tipo de material, usando el mismo nombre de categoría del campo tipo"
}
''');

    final imagePart = InlineDataPart('image/jpeg', imagenBytes);

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    final text = response.text ?? '{}';
    final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

    // Parseo simple del JSON (sin librería extra por rapidez)
    final tipo = RegExp(r'"tipo":\s*"([^"]+)"').firstMatch(cleanText)?.group(1) ?? 'Desconocido';
    final contenedor = RegExp(r'"contenedor":\s*"([^"]+)"').firstMatch(cleanText)?.group(1) ?? 'Desconocido';
    final mensaje = RegExp(r'"mensajeImpacto":\s*"([^"]+)"').firstMatch(cleanText)?.group(1) ?? '';

    return {
      'tipo': tipo,
      'contenedor': contenedor,
      'mensajeImpacto': mensaje,
    };
  }

  /// Genera una sugerencia proactiva según el historial reciente
  Future<String> generarSugerencia(List<String> historialTipos) async {
    final prompt = '''
Eres un agente que motiva hábitos de reciclaje. Este es el historial 
reciente de tipos de residuos reciclados por el usuario: ${historialTipos.join(', ')}.
Genera UNA recomendación corta (máx 2 frases), motivadora y personalizada,
detectando qué categoría ha reciclado poco o sugiriendo diversificar.
Responde SOLO con el texto de la recomendación, sin comillas ni formato extra.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? '¡Sigue reciclando, cada acción cuenta!';
  }
}