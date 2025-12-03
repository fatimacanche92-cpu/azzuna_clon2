# 🌸 Generador de Tarjetas de Acompañamiento para Flores

Una aplicación Flutter profesional para crear tarjetas de acompañamiento hermosas y personalizadas para tu negocio de flores.

## ✨ Características

- 🎨 **6 Plantillas de Diseño Diferentes**:
  - Romántica - Perfecta para San Valentín y ocasiones románticas
  - Elegante - Diseño sofisticado y clásico
  - Moderna - Estilo contemporáneo y minimalista
  - Clásica - Diseño tradicional y atemporal
  - Primaveral - Fresca y colorida
  - Boda - Especial para celebraciones matrimoniales

- 🎯 **10 Ocasiones Especiales** con mensajes automáticos:
  - San Valentín
  - Día de la Madre
  - Cumpleaños
  - Boda
  - Aniversario
  - Graduación
  - Pésame
  - Felicidades
  - Agradecimiento
  - General

- 🤖 **Generación Automática de Mensajes**: 
  - Mensajes predefinidos según la ocasión
  - Colores automáticos según la temática
  - Personalización completa opcional

- 🎨 **Personalización Total**:
  - Nombre del destinatario
  - Nombre del remitente
  - Mensaje personalizado (opcional)
  - Colores personalizables
  - Selección de plantilla

- 📱 **Exportación**:
  - Exportar a PDF
  - Vista completa para revisión
  - Listo para imprimir

## 🚀 Instalación

1. **Asegúrate de tener Flutter instalado**:
   ```bash
   flutter --version
   ```

2. **Configura el proyecto para web** (si aún no está configurado):
   ```bash
   flutter create . --platforms=web
   ```

3. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

4. **Ejecuta la aplicación**:

   **Opción A - En Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```
   O simplemente:
   ```bash
   flutter run -d web-server
   ```

   **Opción B - Construir APK para Android:**
   ```bash
   # Versión de depuración (más rápida, para pruebas)
   flutter build apk --debug
   
   # Versión de release (optimizada, para distribución)
   flutter build apk --release
   ```
   El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

   **Opción C - Construir para Web:**
   ```bash
   flutter build web
   ```
   Los archivos se generarán en: `build/web/`

## 📖 Uso

### Crear una Tarjeta

1. **Selecciona una Ocasión Especial**:
   - Elige de la lista desplegable (San Valentín, Día de la Madre, etc.)
   - Los colores y mensajes se ajustarán automáticamente

2. **Elige un Diseño**:
   - Selecciona una de las 6 plantillas disponibles
   - Cada diseño tiene su propio estilo único

3. **Personaliza el Contenido**:
   - Ingresa el nombre del destinatario
   - Ingresa tu nombre como remitente
   - Opcionalmente, escribe un mensaje personalizado
   - Si dejas el mensaje vacío, se generará uno automático

4. **Ajusta los Colores** (opcional):
   - Toca el color principal o secundario
   - Selecciona de los colores predefinidos
   - Los colores se ajustan automáticamente según la ocasión

5. **Genera el Mensaje**:
   - Presiona "Generar Mensaje Automático" para actualizar
   - O simplemente cambia la ocasión para generar uno nuevo

6. **Exporta tu Tarjeta**:
   - Usa "Vista Completa" para ver la tarjeta en pantalla completa
   - Usa "Exportar PDF" para guardar o imprimir

## 🎨 Plantillas Disponibles

### 🌹 Romántica
Diseño con gradientes suaves y decoraciones circulares. Perfecta para ocasiones románticas.

### 🌸 Elegante
Estilo sofisticado con patrones decorativos y tipografía clásica. Ideal para ocasiones formales.

### 💐 Moderna
Diseño minimalista con formas geométricas. Perfecta para clientes con gusto contemporáneo.

### 🌺 Clásica
Estilo tradicional con bordes decorativos. Atemporal y elegante.

### 🌼 Primaveral
Diseño fresco y colorido con decoraciones florales. Ideal para ocasiones alegres.

### 💍 Boda
Diseño especial con elementos dorados y decoraciones nupciales. Perfecta para celebraciones matrimoniales.

## 📋 Ocasiones Especiales

Cada ocasión incluye:
- **Mensajes predefinidos**: 4 variaciones diferentes que se seleccionan aleatoriamente
- **Colores temáticos**: Colores que representan la ocasión
- **Iconos visuales**: Identificación rápida de la ocasión

## 🛠️ Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── models/
│   └── card_data.dart          # Modelo de datos de la tarjeta
├── services/
│   └── message_generator.dart  # Generador de mensajes automáticos
├── screens/
│   ├── home_screen.dart        # Pantalla principal
│   └── customization_screen.dart # Panel de personalización
└── widgets/
    ├── card_factory.dart       # Factory para crear tarjetas
    └── card_templates/         # Plantillas de diseño
        ├── template_base.dart
        ├── romantic_template.dart
        ├── elegant_template.dart
        ├── modern_template.dart
        ├── classic_template.dart
        ├── spring_template.dart
        └── wedding_template.dart
```

## 💡 Consejos de Uso

1. **Para Ventas Rápidas**: 
   - Selecciona la ocasión y deja que el sistema genere el mensaje automáticamente
   - Solo necesitas agregar los nombres

2. **Para Clientes Especiales**:
   - Usa el mensaje personalizado para agregar un toque único
   - Ajusta los colores según las preferencias del cliente

3. **Para Ocasiones Específicas**:
   - El sistema detecta automáticamente la ocasión y ajusta todo
   - Puedes cambiar manualmente si prefieres otro estilo

## 🎯 Casos de Uso

- **Negocio de Flores**: Genera tarjetas profesionales para cada pedido
- **Eventos**: Crea tarjetas personalizadas para ocasiones especiales
- **Regalos**: Acompaña tus arreglos florales con mensajes hermosos
- **Marketing**: Usa las tarjetas como material promocional

## 📱 Requisitos

- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior
- Android Studio / VS Code con extensiones de Flutter

### Para Android:
- Android SDK instalado
- Java JDK (para compilar APK)

### Para Web:
- Chrome instalado (para ejecutar en desarrollo)
- No se requieren dependencias adicionales

## 🔧 Dependencias Principales

- `google_fonts`: Tipografías elegantes (compatible con web y Android)
- `printing`: Exportación a PDF (funciona en web y Android)
- `intl`: Formateo de fechas (compatible con todas las plataformas)

## 🌐 Compatibilidad de Plataformas

✅ **Web**: Totalmente compatible - Ejecuta con `flutter run -d chrome`  
✅ **Android**: Totalmente compatible - Construye APK con `flutter build apk`  
✅ **Exportación PDF**: Funciona en web y Android

## 📝 Notas

- Los mensajes se generan automáticamente pero puedes personalizarlos
- Los colores se ajustan según la ocasión, pero puedes cambiarlos manualmente
- Las tarjetas están optimizadas para impresión en tamaño estándar
- Todas las plantillas son responsive y se adaptan a diferentes tamaños

## 🎨 Personalización Avanzada

Si quieres agregar más plantillas o ocasiones:

1. **Agregar Nueva Plantilla**:
   - Crea un nuevo archivo en `lib/widgets/card_templates/`
   - Extiende `CardTemplateBase`
   - Agrega el caso en `CardFactory`

2. **Agregar Nueva Ocasión**:
   - Agrega el enum en `card_data.dart`
   - Agrega mensajes en `message_generator.dart`
   - Define el color y nombre de la ocasión

---

**Creado con ❤️ para tu negocio de flores**

¡Que tus tarjetas siempre transmitan el mensaje perfecto! 🌸
