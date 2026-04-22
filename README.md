# Encuestas Casa del Yeti

App Flutter (Android) para capturar encuestas de la activación **Casa del Yeti** de Free Fire, diseñada para tablets Xiaomi en **landscape** (3200x2136).

- Flujo **una pregunta por pantalla** con auto-avance en opciones únicas, botón "Avanzar" en multi-selección y botón "Finalizar" en la pregunta abierta final.
- **Offline-first**: todas las respuestas se guardan en local (`responses.jsonl`).
- **Panel oculto** accesible desde la pantalla de bienvenida: **tap en esquina superior-izq → superior-der → inferior-izq** dentro de 3 segundos.
- Exportación a **XLSX** (share sheet nativo) y envío opcional por **email con SendGrid** (con XLSX adjunto), solo si hay conexión.

## Requisitos

- Flutter 3.41+ (Dart 3.11+).
- Android SDK, `minSdk` 23.

## Ejecutar en desarrollo

```bash
flutter pub get
flutter run
```

Sin `--dart-define` la app funciona 100% offline; el botón "Enviar por email" queda deshabilitado.

## Build release (APK) con SendGrid

Necesitas:
- Una API Key de SendGrid con permiso `Mail Send` ([docs](https://docs.sendgrid.com/api-reference/mail-send/mail-send)).
- Un remitente (email + nombre) verificado en SendGrid (Single Sender o Domain Auth).

```bash
flutter build apk --release \
  --dart-define=SENDGRID_API_KEY=SG.xxxxxxxx \
  --dart-define=SENDGRID_FROM=no-reply@tudominio.com \
  --dart-define=SENDGRID_FROM_NAME="Casa del Yeti"
```

El APK firmado queda en `build/app/outputs/flutter-apk/app-release.apk`.

> Nota: la API key viaja **embebida** en el APK. Mantén el APK con acceso controlado y rota la key cuando termine la activación.

## Install en la tablet

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Uso

1. Pantalla de bienvenida → botón **Comenzar encuesta**.
2. 8 preguntas, navegación automática (o botón "Avanzar"/"Finalizar"). Hay botón **Atrás** discreto para corregir.
3. Al finalizar, pantalla de "¡Gracias!" y vuelta automática al inicio en ~4 s.

### Panel de resultados (oculto)

Desde la pantalla de bienvenida, toca en este orden las esquinas (zona de ~90 px):

1. Superior-izquierda
2. Superior-derecha
3. Inferior-izquierda

Tienes 3 s entre el primer y el último toque. Entrarás al panel con:

- Contador total, primera y última fecha.
- **Exportar XLSX** (share sheet: guardar, mandar por WhatsApp/Drive, etc.).
- **Enviar por email** (solo online + SendGrid configurado).
- **Borrar todo** (doble confirmación).

## Estructura de datos

Cada encuesta se guarda en `responses.jsonl` como una línea JSON:

```json
{"id":"uuid","createdAt":"2026-04-22T15:43:00Z","answers":{"q1":"...","q4":["Alegría","Sorpresa"],"q7":9,"q8":"..."}}
```

Columnas en el XLSX: `ID | Fecha | q1 | q2 | q3 | q4 | q5 | q6 | q7 | q8`.

## Assets

- `assets/background/fondo_tablet.png` — fondo de pantalla.
- `assets/icon/android-icon-192x192.png` — fuente del icono de la app (generado con `flutter_launcher_icons`).

Para regenerar los iconos tras cambiar la imagen fuente:

```bash
flutter pub run flutter_launcher_icons
```

## Licencia

Ver [`LICENSE`](LICENSE).
