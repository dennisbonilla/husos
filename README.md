# Husos — conversor de zonas horarias

Dos relojes analógicos, uno sobre otro. Arrastrás cualquier manecilla y ambos
giran juntos, cada uno mostrando la hora de su zona. La carátula se tiñe de
día/noche (sol o luna) según la hora de esa ciudad, y avisa cuando cae en el
"día siguiente" o "día anterior". Incluye ~65 zonas horarias, con Centroamérica
y Costa Rica de primeras.

Al abrir, muestra una pantalla de bienvenida con los dos relojes girando hasta
sincronizarse y el crédito **Created by Dennis Bonilla**. El ícono de la app son
las dos carátulas superpuestas en latón sobre azul medianoche.

## Archivos

- `husos_main.dart` — la app (relojes, zonas, arrastre de manecillas)
- `splash_screen.dart` — pantalla de bienvenida animada con el crédito
- `icon/icon.png` — ícono base (1024×1024)
- `icon/icon_foreground.png` — capa frontal para íconos adaptativos de Android
- `icon_splash_config.yaml` — ajustes de ícono y splash nativo
- `.github/workflows/build.yml` — compila el APK en la nube

## Opción A — obtener el APK sin instalar nada (recomendada)

Todo se compila solo en la nube con GitHub Actions.

1. Creá una cuenta en https://github.com (gratis) e iniciá sesión.
2. Creá un repositorio nuevo, por ejemplo `husos`.
3. Subí **todos** los archivos de esta carpeta manteniendo la estructura:
   - `husos_main.dart`
   - `README.md`
   - `.github/workflows/build.yml`  ← ¡importante conservar las carpetas!
   (Podés arrastrarlos con el botón **Add file → Upload files**. Para la carpeta
   `.github/workflows`, subí el archivo y GitHub crea las carpetas si escribís la
   ruta `.github/workflows/build.yml` en el nombre.)
4. Andá a la pestaña **Actions** del repo. Verás el flujo **Construir APK**.
   Corre solo al subir; si no, tocá **Run workflow**.
5. Cuando termine (unos 3–5 min, aparece un ✓ verde), entrá al run y bajá
   **husos-apk** en la sección *Artifacts*. Ahí está tu `app-release.apk`.
6. Pasá el APK al teléfono, tocalo e instalá (activá "instalar de fuentes
   desconocidas" si te lo pide). Listo.

## Opción B — compilar en tu computadora

Necesitás el SDK de Flutter instalado (https://docs.flutter.dev/get-started/install).

```bash
flutter create --platforms=android --org cr.pura --project-name husos .
cp husos_main.dart lib/main.dart
cp splash_screen.dart lib/splash_screen.dart
flutter pub add timezone
flutter pub add dev:flutter_launcher_icons
flutter pub add flutter_native_splash
cat icon_splash_config.yaml >> pubspec.yaml
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.
Para probarlo con el teléfono conectado por USB: `flutter run`.

## Notas

- Las zonas usan el paquete `timezone` (base de datos IANA), así que el horario
  de verano se aplica correctamente.
- Para cambiar el nombre visible de la app o el ícono, se edita
  `android/app/src/main/AndroidManifest.xml` tras el primer `flutter create`.
