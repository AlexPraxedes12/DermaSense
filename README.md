[![Download installers](https://img.shields.io/badge/Download%20installers-%20Releases-blue?style=for-the-badge&logo=github)](https://github.com/AlexPraxedes12/DermaSense/releases) [![Watch demo on YouTube](https://img.shields.io/badge/Watch%20Demo-YouTube-red?style=for-the-badge&logo=youtube)](https://youtube.com/shorts/jE4ANR4ltUI?feature=share) [![Project website](https://img.shields.io/badge/Visit%20website-DermaSense-orange?style=for-the-badge&logo=globe)](https://dermasense.org/)

# DermaSense

**DermaSense** is a low-cost smart mat for preventive monitoring of pressure and local temperature in people who remain seated or lying down for long periods.

The system combines an `8 x 8` pressure-sensing matrix, `6 NTC` temperature sensors, an `ESP32`, a custom PCB and a Flutter app that visualizes the data as a live pressure heatmap.

> **Important:** DermaSense is a preventive prototype and research/education tool. It is **not** a certified medical device and does **not** diagnose, treat or replace clinical assessment.

---

## Project overview

Pressure injuries can develop when a body area remains under pressure for an extended period. In many care environments, prevention depends on manual checks, repositioning routines and consistent observation by caregivers.

Pressure-ulcer risk is multifactorial. Pressure magnitude and exposure time matter, but moisture, friction/shear, mobility, skin condition, nutrition, local perfusion and temperature changes can also influence risk. DermaSense does not diagnose ulcers; it helps visualize pressure and temperature patterns that may support preventive awareness.

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

In this prototype revision, the matrix, NTC and power connections are soldered directly to the PCB. The first connector layout was too tight for reliable assembly, so direct soldering was used to complete and evaluate the prototype.

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
- pressure history by zone;
- temperature trend interpretation;
- identification of possible high, low or rapidly changing temperature patterns;
- seated / lying interpretation mode;
- connection status;
- visual recommendations based on pressure and temperature patterns.

Future versions are expected to support configurable pressure-history windows such as `5`, `10` and `15` minutes.

---

## New app features

- pressure history by matrix cell and posture mode;
- temperature history for each of the `6` NTC sensors;
- selectable `5`, `10` and `15` minute trend windows based on real timestamps;
- maximum and average pressure summaries for the selected window;
- sustained relative load analysis for the most persistent pressure cell;
- preventive temperature trend interpretation, including elevated, low, rising, dropping and rapid-change patterns;
- an in-memory retention limit to keep resource usage predictable;
- a calibration-ready pressure configuration while values remain relative;
- documentation for future protective textile and moisture-barrier testing.

Temperature history was prioritized because an instantaneous value alone does not describe how a zone evolves. Increases, rapid drops and abnormally cold areas may provide complementary context related to local perfusion changes. These trends support preventive observation only and are not diagnostic.

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

The pressure layer uses a resistive matrix made from copper traces and Velostat. Velostat changes resistance when pressure is applied. By scanning rows and columns, the system estimates the relative pressure distribution across `64` sensing points.

The current readings are relative and require calibration. A future calibration stage will compare the matrix output against known weights, a scale, a sphygmomanometer or other external references. When discussing pressure in clinical contexts, the correct unit is usually `mmHg`, meaning millimeters of mercury, not milligrams of mercury. Mapping the prototype output to `mmHg` must only be attempted after appropriate validation.

### Temperature sensing

The prototype uses `6` NTC temperature sensors placed around relevant body zones. Temperature is interpreted as a complementary trend, not as a diagnosis. The system should not only consider high temperature. Rapid drops or abnormally cold zones may also be relevant as complementary signals related to local perfusion changes.

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

## Clinical feedback

DermaSense received early clinical feedback from Evelyn Estefania Herrera Guerra, professor type A at Escuela Nacional de Estudios Superiores, Unidad León, Universidad Nacional Autónoma de México. Her comments helped strengthen the prototype around pressure calibration, temperature interpretation, moisture protection and pressure-history recording.

The feedback also emphasized that instantaneous temperature is not sufficient by itself. Recording thermal history can help observe increases, rapid decreases or unusually cold zones as complementary patterns that may relate to changes in local irrigation or perfusion. This interpretation remains preventive and does not constitute a diagnosis.

- Compare pressure readings with external references such as known weights, a scale or sphygmomanometer.
- Use `mmHg` correctly when discussing pressure references.
- Validate NTC readings with an external thermometer.
- Consider both high temperature and rapid drops or abnormally cold areas.
- Test a protective textile or barrier against liquids such as urine without significantly affecting pressure and temperature readings.
- Register pressure history by zones over time windows such as `5`, `10` and `15` minutes.

This feedback represents early guidance for prototype improvement and does not constitute certification, clinical validation or institutional endorsement.

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
- pressure values are not yet expressed in calibrated clinical units;
- the relationship between matrix readings and `mmHg` still needs validation;
- NTC readings require per-sensor normalization;
- temperature readings are complementary and not diagnostic;
- the mat needs more comfort and durability testing;
- the system needs validation with known weights and controlled conditions;
- the effect of textile or moisture barriers on pressure and temperature readings needs testing;
- the current PCB revision uses direct soldered connections;
- clinical use would require formal validation, safety review and regulatory review.

---

## Roadmap

Planned next steps:

- calibrate pressure readings with known weights and external references;
- explore `mmHg` mapping only after validation;
- validate each NTC sensor against an external thermometer;
- normalize each NTC sensor;
- measure real battery life;
- improve cable routing and enclosure compactness;
- design a second PCB revision with better-spaced connectors;
- improve the washable cover and surface comfort;
- test protective textiles or barriers against moisture;
- evaluate whether the barrier affects pressure and temperature readings;
- add pressure history by zone;
- add `5`, `10` and `15` minute pressure trend windows;
- add session history to the app;
- add pressure-over-time alerts;
- add trend graphs;
- create a robust demo mode;
- document feedback from physiotherapy, dermatology, rehabilitation or nursing professionals;
- define a non-clinical testing protocol before any medical use.

---

## Safety and responsibility

DermaSense is designed as a preventive support prototype for visualization, education and early-stage research. It is not a certified medical device, does not diagnose pressure ulcers, does not treat patients and does not replace clinical assessment. Any medical or clinical use would require professional supervision, formal validation, electrical safety review, material safety review, biocompatibility analysis, moisture-control testing and compliance with applicable regulations.

---

## References and clinical context

- National Pressure Injury Advisory Panel. *Pressure Injury Prevention Points*.
- NPIAP/EPUAP/PPPIA. *Prevention and Treatment of Pressure Ulcers/Injuries: Clinical Practice Guideline*.
- *Braden Scale for Predicting Pressure Sore Risk*.
- Mayo Clinic. *Bedsores (pressure ulcers): Symptoms and causes*.
- Literature on pressure-ulcer microclimate, moisture and temperature as risk factors.

---

## License

[TO BE DEFINED]

---

## Author

Developed by **Alejandro Aguilar Martínez**.

DermaSense is part of an accessible health-tech development line focused on low-cost sensing, embedded systems and preventive care tools.
"# LandingDerma" 
