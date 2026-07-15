import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';
import '../models/residuo.dart';
import '../data/tachos_data.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  final FirestoreService _firestoreService = FirestoreService();

  File? _imagenSeleccionada;
  bool _analizando = false;

  Future<void> _tomarFoto(ImageSource source) async {
    final XFile? foto = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (foto == null) return;

    setState(() {
      _imagenSeleccionada = File(foto.path);
    });
  }

  void _mostrarModalAnalizando() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '🍃 Tu agente EcoLens está analizando la foto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esto puede tomar unos segundos...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _analizarResiduo() async {
    if (_imagenSeleccionada == null) return;

    setState(() {
      _analizando = true;
    });

    _mostrarModalAnalizando();

    try {
      final bytes = await _imagenSeleccionada!.readAsBytes();
      final resultado = await _geminiService.clasificarResiduo(bytes);

      if (!mounted) return;
      Navigator.pop(context); // cierra el modal de carga

      final confianza = resultado['confianza'] ?? 'ALTA';

      if (confianza == 'BAJA') {
        final confirmado = await _mostrarModoConfianza(resultado);
        if (confirmado != true) {
          setState(() => _analizando = false);
          return; // el usuario canceló, no se guarda nada
        }
      }

      await _guardarYNavegar(resultado);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _analizando = false);
      _mostrarErrorDialog();
    }
  }

  Future<bool?> _mostrarModoConfianza(Map<String, String> resultado) async {
    final tachoInfo = obtenerTachoInfo(resultado['tacho'] ?? 'NEGRO');
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(child: Text('¿Es esto correcto?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No estoy del todo seguro con esta imagen. Creo que es:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tachoInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(tachoInfo.icono, color: tachoInfo.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${resultado['material']} → Tacho ${tachoInfo.categoria}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tachoInfo.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, tomar otra foto'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarYNavegar(Map<String, String> resultado) async {
    final tacho = resultado['tacho'] ?? 'NEGRO';
    final tachoInfo = obtenerTachoInfo(tacho);

    final residuo = Residuo(
      material: resultado['material'] ?? 'Desconocido',
      tacho: tacho,
      categoriaTacho: tachoInfo.categoria,
      mensajeImpacto: tachoInfo.mensajeImpacto,
      fecha: DateTime.now(),
      puntos: 10,
      confianza: resultado['confianza'] ?? 'ALTA',
    );

    await _firestoreService.guardarResiduo(residuo);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Guardado correctamente'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          residuo: residuo,
          imagen: _imagenSeleccionada!,
        ),
      ),
    );
  }

  void _mostrarErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 10),
            Text('No pudimos analizar la foto'),
          ],
        ),
        content: const Text(
          'El agente de IA está muy solicitado en este momento. '
          'Por favor, intenta nuevamente en unos segundos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _analizarResiduo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Clasificar residuo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: _imagenSeleccionada == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 80, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Toma o selecciona una foto\ndel residuo a clasificar',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imagenSeleccionada!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            if (_imagenSeleccionada == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _tomarFoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _tomarFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _analizando ? null : _analizarResiduo,
                  icon: _analizando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_analizando ? 'Analizando...' : 'Analizar con IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _analizando
                    ? null
                    : () => setState(() => _imagenSeleccionada = null),
                child: const Text('Elegir otra foto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}