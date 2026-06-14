# Derma Sense

Derma Sense es una app Flutter para visualizar en tiempo real la matriz de presion `8x8` y los `6 NTC` del sistema basado en `ESP32`.

## Conexion rapida

- Red WiFi del ESP32: `TapeteMedico-ESP32`
- Contrasena WiFi: `tapete1234`
- WebSocket por defecto: `ws://192.168.4.1:81`

## Plataformas

El proyecto esta preparado para:

- `Android`
- `iOS`
- `Web`
- `Windows`
- `macOS`
- `Linux`

En esta iteracion se dejaron listos los builds de:

- `Android APK`
- `Windows`

## Que muestra la app

- Mapa de presion `8x8`
- Presion maxima y promedio
- Temperaturas de `6 NTC`
- Modo de interpretacion:
  - `Sentado`
  - `Acostado`
- Recomendaciones visuales segun presion y temperatura

## Mapeo actual de NTC

### Modo acostado

- `NTC1`: Muslo izquierdo
- `NTC2`: Muslo derecho
- `NTC3`: Isquion izquierdo
- `NTC4`: Isquion derecho
- `NTC5`: Sacro
- `NTC6`: Referencia ambiental

### Modo sentado

La misma distribucion fisica puede reinterpretarse para sesiones sentado desde la app.

## Uso

1. Enciende el sistema.
2. Conecta el telefono o la computadora a la red `TapeteMedico-ESP32`.
3. Abre la app `Derma Sense`.
4. Verifica que la URL sea `ws://192.168.4.1:81`.
5. Toca `Aplicar URL` y luego `Reconectar` si hace falta.

## Arquitectura del proyecto

El codigo sigue una separacion por capas estilo `MVVM` (Model / ViewModel /
View) mas una capa `core` de utilidades transversales:

- `lib/core/` -> configuracion, tema y utilidades (sin logica de negocio)
- `lib/models/` -> datos y dominio (`MatReading`, recomendaciones)
- `lib/viewmodels/` -> estado y orquestacion (`DashboardController`)
- `lib/views/` -> pantallas y widgets de presentacion

## Desarrollo

Comandos utiles:

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

Builds principales:

```bash
flutter build apk --release
flutter build windows
```

Artefactos esperados:

- Android release: `build/app/outputs/flutter-apk/app-release.apk`
- Windows: `build/windows/x64/runner/Release/derma_sense.exe`

## Notas practicas

- El selector `Sentado / Acostado` ya esta ajustado para pantallas angostas.
- Si cambias el firmware del ESP32 o la IP, actualiza la URL desde la pantalla principal.
- El ejecutable de Windows no va firmado; puede mostrar advertencias normales de SmartScreen en equipos nuevos.

## Bateria 5000 mAh

Como aproximado practico, una powerbank de `5000 mAh` deberia dar:

- `6 a 8 horas` en uso normal
- `4 a 6 horas` si el WiFi transmite mas seguido o la powerbank tiene baja eficiencia

La autonomia real puede variar por calidad de la powerbank, conversion interna a `5V`, intensidad del WiFi y brillo/consumo de perifericos conectados.
