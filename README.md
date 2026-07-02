# 🍃 EcoLens

**Agente de IA para incentivar los hábitos de clasificación y reciclado doméstico**

Proyecto desarrollado para la **Hackathon QuipuSoft 2026** organizada por TECSUP.

## 📋 Descripción

EcoLens es una aplicación móvil que ayuda a las personas a reciclar mejor en casa. El usuario toma una foto de un residuo, un agente de IA lo identifica y le indica en qué contenedor va. El sistema recuerda el historial de reciclaje del usuario y, de forma proactiva, genera recomendaciones personalizadas para mejorar su hábito con el tiempo — sin que el usuario tenga que pedirlo.

## ❓ Problema que resuelve

La falta de información y motivación es una de las principales barreras para que las personas reciclen correctamente en sus hogares. EcoLens busca cerrar esa brecha combinando identificación automática de residuos, gamificación y acompañamiento personalizado mediante IA.

## ✨ Funcionalidades principales

- 📸 **Clasificación de residuos por foto** — identificación automática (Plástico, Papel y cartón, Vidrio, Orgánico, Metal, No reciclable) usando IA multimodal
- 💡 **Agente proactivo** — genera sugerencias personalizadas basadas en el historial de reciclaje del usuario
- 🏆 **Sistema de puntos y niveles** — Reciclador Novato 🌱 → Bronce 🌿 → Eco Guerrero 🌳 → Eco Héroe 🌟
- 🔥 **Racha de días consecutivos** reciclando
- ♻️ **Mensajes educativos de impacto ambiental** generados por IA para cada residuo clasificado
- 📜 **Historial** de residuos clasificados
- 🎬 **Onboarding** explicativo para nuevos usuarios

## 🛠️ Tecnologías utilizadas

| Parte | Tecnología |
|---|---|
| App | Flutter (Android) |
| Inteligencia Artificial | Firebase AI Logic (Gemini, modelo multimodal) |
| Base de datos | Cloud Firestore |

## 🚀 Cómo ejecutar el proyecto

### Requisitos previos
- Flutter SDK instalado
- Cuenta de Firebase con un proyecto configurado
- Firebase AI Logic habilitado (Gemini Developer API)

### Pasos

1. Clona el repositorio
```bash
   git clone https://github.com/arnold-at/EcoLens.git
   cd ecolens
```

2. Instala las dependencias
```bash
   flutter pub get
```

3. Conecta tu propio proyecto de Firebase
```bash
   flutterfire configure
```

4. Ejecuta la aplicación
```bash
   flutter run
```


## 📄 Licencia

Proyecto desarrollado con fines educativos y de competencia para la Hackathon QuipuSoft 2026.