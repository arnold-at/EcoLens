import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
  }

  /// Envuelve una acción con reintento automático y timeout ante errores
  /// temporales (ej: alta demanda del modelo, error 500/503, lentitud).
  Future<T> _conReintento<T>(Future<T> Function() accion, {int intentos = 2}) async {
    for (int i = 0; i < intentos; i++) {
      try {
        return await accion().timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Tiempo de espera agotado'),
        );
      } catch (e) {
        final esUltimoIntento = i == intentos - 1;
        if (esUltimoIntento) {
          throw Exception(
            'El agente de IA no está disponible en este momento. '
            'Por favor, intenta nuevamente en unos segundos.',
          );
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('No se pudo completar la solicitud.');
  }

  /// Analiza una imagen de residuo y devuelve material, tacho oficial y nivel de confianza
  Future<Map<String, String>> clasificarResiduo(Uint8List imagenBytes) async {
    return _conReintento(() async {
      final prompt = TextPart('''
Eres un asistente experto en reciclaje que sigue la Norma Técnica Peruana 
NTP 900.058:2019 (MINAM/INACAL), la cual define 4 tachos oficiales para 
residuos domésticos en Perú.

Analiza la imagen del residuo y responde SOLO en este formato JSON, 
sin texto adicional ni markdown:
{
  "material": "nombre específico del material (ej: botella de plástico, cáscara de fruta, pila usada)",
  "tacho": "VERDE/MARRON/NEGRO/ROJO",
  "confianza": "ALTA/MEDIA/BAJA"
}

Guía de clasificación según la norma:
- VERDE (Aprovechables): papel, cartón, vidrio, plástico, metales, textiles
- MARRON (Orgánicos): restos de alimentos, poda, hojarasca
- NEGRO (No aprovechables): papel encerado, cerámicos, colillas, productos sanitarios
- ROJO (Peligrosos): pilas, luminarias/focos, medicinas vencidas, plaguicidas

Usa "confianza": "BAJA" si la imagen tiene mala iluminación, el objeto está 
parcialmente visible, es un material mixto, o no estás seguro del material.
Usa "MEDIA" si hay algo de ambigüedad pero es razonablemente identificable.
Usa "ALTA" solo si el material es claramente identificable.
''');

      final imagePart = InlineDataPart('image/jpeg', imagenBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final material = RegExp(r'"material":\s*"([^"]+)"').firstMatch(cleanText)?.group(1) ?? 'Residuo desconocido';
      final tacho = RegExp(r'"tacho":\s*"([^"]+)"').firstMatch(cleanText)?.group(1)?.toUpperCase() ?? 'NEGRO';
      final confianza = RegExp(r'"confianza":\s*"([^"]+)"').firstMatch(cleanText)?.group(1)?.toUpperCase() ?? 'MEDIA';

      return {
        'material': material,
        'tacho': tacho,
        'confianza': confianza,
      };
    });
  }

  /// Genera una sugerencia proactiva según el historial reciente
  Future<String> generarSugerencia(List<String> historialTipos) async {
    try {
      return await _conReintento(() async {
        final prompt = '''
Eres un agente que motiva hábitos de reciclaje. Este es el historial 
reciente de tipos de residuos reciclados por el usuario: ${historialTipos.join(', ')}.
Genera UNA recomendación corta (máx 2 frases), motivadora y personalizada,
detectando qué categoría ha reciclado poco o sugiriendo diversificar.
Responde SOLO con el texto de la recomendación, sin comillas ni formato extra.
''';

        final response = await _model.generateContent([Content.text(prompt)]);
        return response.text?.trim() ?? '¡Sigue reciclando, cada acción cuenta!';
      }, intentos: 2);
    } catch (e) {
      return '¡Sigue reciclando, cada acción cuenta!';
    }
  }
}