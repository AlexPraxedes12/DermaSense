# DermaSense

**DermaSense** is a low-cost smart mat for preventive monitoring of pressure and local temperature in people who remain seated or lying down for long periods.

The system combines an `8 x 8` pressure-sensing matrix, `6 NTC` temperature sensors, an `ESP32`, a custom PCB and a Flutter app that visualizes the data as a live pressure heatmap.

> **Important:** DermaSense is a preventive prototype and research/education tool. It is **not** a certified medical device and does **not** diagnose, treat or replace clinical assessment.

---

## Project overview

Pressure ulcers can appear when one body area remains under pressure for too long. In many care environments, prevention depends on manual checks, fixed routines and the caregiver remembering to reposition the person in time.

DermaSense aims to make pressure easier to understand by turning a support surface into a sensing interface. The app helps visualize:

- where pressure is concentrated;
- how pressure is distributed across the mat;
- local temperature readings from selected zones;
- whether the person is being interpreted in seated or lying mode;
- visual guidance for caregivers.

The goal is to support early awareness and better care decisions, especially in low-resource environments, rehabilitation, education and prototyping.

---

## Current prototype

The current prototype includes:

- `50 x 50 cm` approximate mat size;
- `40 x 40 cm` active sensing area;
- `8 x 8` pressure matrix, total `64` pressure points;
- Velostat and copper traces as the pressure-sensing layer;
- `6` NTC temperature sensors;
- ESP32 DevKit V1;
- `2 x CD74HC4067` multiplexers;
- ADS1115 for part of the temperature sensing;
- custom PCB designed in KiCad;
- 3D-printed control enclosure;
- powerbank-based `5V` supply;
- Flutter app for Android, Windows and desktop testing.

In this prototype revision, the matrix, NTC and power connections are soldered directly to the PCB. The first connector layout was too tight for reliable assembly, so direct soldering was used to improve continuity during testing. A future PCB revision will use better-spaced, more robust connectors.

---

## Quick connection

The ESP32 creates its own local WiFi network.

```text
WiFi SSID: TapeteMedico-ESP32
WiFi password: tapete1234
Default WebSocket: ws://192.168.4.1:81
```

The system does not require an internet connection. The phone or computer connects directly to the ESP32 access point.

---

## What the app shows

The Flutter app displays:

- live `8 x 8` pressure heatmap;
- maximum pressure value;
- average pressure value;
- readings from `6` NTC sensors;
- seated / lying interpretation mode;
- connection status;
- visual recommendations based on pressure and temperature patterns.

---

## Hardware architecture

```text
Pressure matrix + NTC sensors
          |
          v
Custom PCB
          |
          |-- ESP32 DevKit V1
          |-- 2 x CD74HC4067 multiplexers
          |-- ADS1115
          |-- soldered sensor and power connections
          |
          v
ESP32 local WiFi + WebSocket
          |
          v
Flutter app
```

### Pressure sensing

The pressure layer uses a resistive matrix made from copper traces and Velostat. Velostat changes resistance when pressure is applied. By scanning rows and columns, the system estimates relative pressure at each of the `64` intersections.

The readings are relative and require calibration. They should not be interpreted as clinical pressure units.

### Temperature sensing

The prototype uses `6` NTC temperature sensors placed around relevant body zones. Temperature is used as a complementary signal, not as a diagnostic measurement.

Current interpretation:

| Sensor | Intended physical zone |
|---|---|
| NTC1 | Left thigh |
| NTC2 | Right thigh |
| NTC3 | Left ischial / pelvic area |
| NTC4 | Right ischial / pelvic area |
| NTC5 | Sacrum |
| NTC6 | Ambient reference |

The same physical distribution can be interpreted differently depending on whether the person is seated or lying down.

---

## Software architecture

The app is built with Flutter and follows a simple MVVM-style structure.

```text
lib/core/        Configuration, constants, theme and utilities
lib/models/      Data models and domain objects
lib/viewmodels/  Dashboard state and orchestration
lib/views/       Screens and UI widgets
assets/          Icons and visual resources
android/         Android configuration
windows/         Windows configuration
```

Main technologies:

- Flutter
- Dart
- WebSocket communication
- MVVM-style app organization

---

## Supported platforms

The project is prepared for:

- Android
- Windows
- macOS
- Linux
- iOS
- Web

Current tested/generated builds:

- Android APK
- Windows build

---

## Basic usage

1. Turn on the DermaSense control unit.
2. Wait for the ESP32 WiFi network to appear.
3. Connect your phone or computer to:

```text
TapeteMedico-ESP32
```

4. Open the DermaSense app.
5. Confirm the WebSocket URL:

```text
ws://192.168.4.1:81
```

6. Tap `Apply URL` or `Reconnect`.
7. Select seated or lying mode.
8. Place the person or test load on the mat.
9. Observe the pressure heatmap and temperature readings.

---

## Development

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android APK:

```bash
flutter build apk --release
```

Build Windows version:

```bash
flutter build windows
```

Expected build artifacts:

```text
Android APK:
build/app/outputs/flutter-apk/app-release.apk

Windows executable:
build/windows/x64/runner/Release/derma_sense.exe
```

---

## Prototype images

Suggested documentation images:

1. Finished DermaSense mat with 3D-printed control case.
2. Early `4 x 4` matrix prototype.
3. Full `8 x 8` Velostat and copper pressure matrix.
4. NTC temperature sensors placed across the mat.
5. Flutter app showing pressure heatmap and temperature readings.
6. KiCad PCB layout for the custom ESP32-based control board.

You can place images inside a folder such as:

```text
docs/images/
```

Example:

```md
![Finished DermaSense prototype](docs/images/dermasense-final.jpg)
```

---

## Demo video

A short demo should show:

1. the finished mat;
2. the person lying or sitting on the sensing area;
3. the app receiving live data;
4. the pressure heatmap or temperature values changing in real time.

Recommended length: `15–45 seconds`.

---

## Battery estimate

The current prototype can be powered from a standard `5V` powerbank.

A `5000 mAh` powerbank is expected to provide approximately:

- `6 to 8 hours` under moderate use;
- `4 to 6 hours` if WiFi transmission is frequent or power conversion efficiency is lower.

Actual battery life still needs to be measured with the final hardware configuration.

---

## Current limitations

DermaSense is still a prototype. Current limitations include:

- it is not a certified medical device;
- it does not diagnose pressure ulcers;
- pressure readings are relative and require calibration;
- NTC readings require per-sensor normalization;
- the mat needs more comfort and durability testing;
- the system needs validation with known weights and controlled conditions;
- the current PCB revision uses direct soldered connections;
- future use in clinical environments would require formal validation, safety review and regulatory guidance.

---

## Roadmap

Planned next steps:

- calibrate the pressure matrix with known weights;
- normalize each NTC sensor;
- measure real battery life;
- improve cable routing and enclosure compactness;
- design a second PCB revision with better-spaced connectors;
- improve the washable cover and surface comfort;
- add session history to the app;
- add pressure-over-time alerts;
- add trend graphs;
- create a robust demo mode;
- collect feedback from physiotherapy, rehabilitation and nursing professionals;
- define a non-clinical testing protocol before any medical use.

---

## Safety and responsibility

DermaSense is designed as a preventive support prototype for visualization, education and early-stage research.

It should not be used as the only method for patient monitoring. Any medical or clinical use would require professional supervision, formal validation, electrical safety review, material safety review and compliance with applicable regulations.

---

## License

[TO BE DEFINED]

---

## Author

Developed by **Alejandro Aguilar Martínez**.

DermaSense is part of an accessible health-tech development line focused on low-cost sensing, embedded systems and preventive care tools.
"# LandingDerma" 
