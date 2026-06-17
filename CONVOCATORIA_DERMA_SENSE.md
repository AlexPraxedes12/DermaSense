# Derma Sense - Documento base para convocatoria

## 1. Nombre del proyecto

**Derma Sense**

Sistema inteligente de monitoreo de presion y temperatura para apoyo en la prevencion de lesiones por presion, ulceras por presion y zonas de riesgo en personas sentadas o acostadas.

## 2. Resumen ejecutivo

Derma Sense es un prototipo funcional compuesto por un tapete sensorizado, una placa electronica propia, firmware en ESP32 y una aplicacion multiplataforma. El sistema mide en tiempo real una matriz de presion de 8 x 8 puntos y seis sensores de temperatura NTC distribuidos sobre zonas anatomicas relevantes.

La informacion se transmite por WiFi desde el ESP32 hacia una aplicacion llamada Derma Sense, donde se visualizan el mapa de presion, las temperaturas normalizadas y recomendaciones interpretativas segun si la persona esta sentada o acostada.

El objetivo del proyecto es ofrecer una herramienta accesible, portable y de bajo costo para detectar patrones de presion sostenida y cambios de temperatura que puedan indicar zonas de riesgo en piel o tejido blando. El prototipo no sustituye una valoracion clinica, pero puede funcionar como apoyo preventivo, herramienta educativa, sistema de monitoreo experimental o base para futuras validaciones medicas.

## 3. Problema que atiende

Las lesiones por presion aparecen cuando una zona del cuerpo permanece sometida a presion durante demasiado tiempo, especialmente en personas con movilidad limitada, pacientes encamados, adultos mayores, usuarios de silla de ruedas o personas en rehabilitacion.

El problema practico es que muchas veces la presion excesiva no se percibe a simple vista hasta que ya existe irritacion, enrojecimiento o dano tisular. Ademas, la distribucion de presion cambia segun postura, peso, apoyo corporal, superficie y tiempo.

Derma Sense busca ayudar a visualizar dos variables utiles:

- Presion distribuida sobre una superficie de apoyo.
- Temperatura local aproximada en puntos seleccionados.

La combinacion de ambas variables permite observar zonas de carga, asimetrias y posibles puntos calientes que requieren reposicionamiento o revision.

## 4. Propuesta de solucion

El proyecto propone un tapete sensorizado con:

- Matriz de presion de 8 x 8 puntos.
- Seis sensores NTC de temperatura.
- Placa electronica dedicada con multiplexores analogicos.
- ESP32 como unidad de procesamiento y comunicacion.
- Comunicacion WiFi local sin depender de internet.
- Aplicacion Flutter multiplataforma.
- Interpretacion adaptable para modo sentado y modo acostado.

La persona se coloca sobre el area activa del tapete. El ESP32 escanea la matriz, lee los NTC, normaliza las mediciones y envia los datos por WebSocket. La aplicacion recibe los datos y los muestra como una interfaz visual clara.

## 5. Usuarios beneficiados

Posibles beneficiarios:

- Personas con movilidad reducida.
- Usuarios de silla de ruedas.
- Pacientes encamados.
- Adultos mayores.
- Cuidadores familiares.
- Personal de enfermeria o rehabilitacion.
- Estudiantes o investigadores de salud, biomecanica o ergonomia.
- Proyectos de monitoreo preventivo de bajo costo.

## 6. Innovacion y diferenciadores

Derma Sense combina varias ideas en un prototipo compacto:

- Integra presion y temperatura en una sola superficie.
- Usa una matriz de presion 8 x 8 para ver distribucion espacial.
- Usa 6 NTC para zonas anatomicas clave.
- Tiene una app multiplataforma con visualizacion en tiempo real.
- Funciona con un ESP32 como punto de acceso WiFi local.
- No requiere router ni internet para operar.
- El hardware fue disenado como PCB propia.
- El sistema puede funcionar con powerbank.
- Incluye carcasa impresa en 3D para integrar placa, bateria, interruptor y cableado.
- Permite reinterpretar los mismos sensores segun postura: sentado o acostado.

## 7. Medidas fisicas conocidas

### Tapete

- Area activa aproximada: **40 x 40 cm**.
- Area total aproximada del tapete/fomi: **50 x 50 cm**.
- Matriz de sensado: **8 filas x 8 columnas**, total 64 puntos.
- Superficie experimental construida sobre fomi/espuma.

### PCB

- Tamano de PCB: **100 x 100 mm**.
- Capas: **2 capas**.
- Material: **FR-4 TG150**.
- Espesor: **1.6 mm**.
- Mascara de soldadura: verde.
- Serigrafia: blanca.
- Cobre: **1 oz Cu**.
- Minimo track/spacing usado en pedido: **6/6 mil**.
- Minimo hole size usado en pedido: **0.3 mm**.
- Tiene 4 agujeros de montaje.

### Powerbank

- Powerbank usada en el prototipo: aproximadamente **9.5 x 2 x 2 cm**.
- Capacidad estimada mencionada: **5000 mAh**.
- Duracion estimada con placa y ESP32: entre **6 y 8 horas** en uso normal, o **4 a 6 horas** si la transmision WiFi es frecuente o la eficiencia de conversion es baja.

### Caja impresa en 3D

- Carcasa disenada para alojar PCB, powerbank, interruptor y cableado.
- El prototipo requirio espacio extra para los cables USB de la powerbank.
- La powerbank tuvo que considerarse con margen para entrada/salida de cable.
- Se diseno una base interna/soporte para mantener la PCB elevada.
- Se considero una elevacion de PCB de aproximadamente **2 cm** para evitar interferencias con cableado y caja.

## 8. Arquitectura de hardware

Componentes principales:

- ESP32 DevKit V1 como microcontrolador y transmisor WiFi.
- 2 x CD74HC4067M96 / HC4067M como multiplexores analogicos.
- ADS1115 breakout como ADC externo I2C para cuatro sensores NTC.
- 6 sensores NTC.
- Matriz resistiva de presion 8 x 8.
- Headers para ROWS y COLS.
- Terminal de entrada 5V.
- Borneras/terminales para NTC.
- Powerbank 5V.
- Interruptor externo.
- Caja impresa en 3D.

## 9. Funcionamiento electronico

La matriz de presion funciona como una red de filas y columnas. Dos multiplexores CD74HC4067 permiten seleccionar una fila y una columna para leer la respuesta resistiva del punto seleccionado.

Esquema conceptual:

```text
ESP32 GPIOs -> seleccion de MUX filas/columnas
MUX columnas -> matriz de presion -> MUX filas -> senal analogica de presion
ESP32 ADC -> lectura de presion
```

Los sensores NTC funcionan como divisores de voltaje. Cuatro se leen por medio del ADS1115 y dos se leen directamente por ADC interno del ESP32.

Distribucion de lectura:

| Sensor | Lectura |
| --- | --- |
| NTC1 | ADS1115 A0 |
| NTC2 | ADS1115 A1 |
| NTC3 | ADS1115 A2 |
| NTC4 | ADS1115 A3 |
| NTC5 | ESP32 GPIO35 |
| NTC6 | ESP32 GPIO36 |

## 10. Mapeo de sensores NTC

Mapeo fisico actual definido por el usuario:

| NTC | Ubicacion fisica |
| --- | --- |
| NTC1 | Muslo izquierdo |
| NTC2 | Muslo derecho |
| NTC3 | Isquion izquierdo |
| NTC4 | Isquion derecho |
| NTC5 | Sacro |
| NTC6 | Referencia ambiental |

La aplicacion interpreta esos sensores segun el modo:

### Modo sentado

- NTC1: Muslo izquierdo.
- NTC2: Muslo derecho.
- NTC3: Isquion izquierdo.
- NTC4: Isquion derecho.
- NTC5: Sacro / coccix.
- NTC6: Referencia ambiental.

### Modo acostado

- NTC1: Muslo posterior izquierdo.
- NTC2: Muslo posterior derecho.
- NTC3: Pelvis / gluteo izquierdo.
- NTC4: Pelvis / gluteo derecho.
- NTC5: Sacro.
- NTC6: Referencia ambiental.

Este cambio es importante porque la misma posicion fisica del sensor puede significar una region anatomica distinta dependiendo de si el usuario esta sentado o acostado.

## 11. Firmware

El firmware del ESP32:

- Inicia automaticamente al encender la placa.
- Crea una red WiFi propia.
- Lee la matriz de presion 8 x 8.
- Lee los 6 NTC.
- Aplica normalizacion/calibracion basica.
- Empaqueta los datos en mensajes JSON.
- Transmite los datos por WebSocket.

Datos de conexion actuales:

```text
SSID: TapeteMedico-ESP32
Password: tapete1234
WebSocket: ws://192.168.4.1:81
```

El sistema esta pensado para operar sin internet. El telefono o computadora se conecta directamente al WiFi generado por el ESP32.

## 12. Software

La aplicacion principal se llama **Derma Sense**.

Tecnologia:

- Flutter.
- Dart.
- WebSocket para datos en tiempo real.
- Preparada para Android, Windows, macOS, Linux, iOS y Web.

Funciones principales:

- Conexion a ESP32 por WebSocket.
- Campo configurable para URL.
- Reconexion manual.
- Simulacion de datos para pruebas sin hardware.
- Visualizacion de matriz de presion 8 x 8.
- Visualizacion de presion maxima y promedio.
- Visualizacion de 6 temperaturas.
- Normalizacion de NTC.
- Modo sentado / acostado.
- Recomendaciones visuales segun presion y temperatura.
- Indicadores de estado de conexion.

URL predeterminada:

```text
ws://192.168.4.1:81
```

## 13. Estructura de la aplicacion

Proyecto local:

```text
C:\Users\alexp\OneDrive\Documentos\Projects\tapete_medico
```

Estructura relevante:

```text
lib/core/        Configuracion, constantes, tema y utilidades.
lib/models/      Modelos de datos.
lib/viewmodels/  Controlador principal del dashboard.
lib/views/       Pantallas y widgets.
assets/          Iconos y recursos visuales.
android/         Configuracion Android.
windows/         Configuracion Windows.
```

Dependencias destacadas:

- `web_socket_channel`
- `google_fonts`
- `flutter_launcher_icons`

## 14. Estado actual del prototipo

Estado general: **prototipo funcional**.

Se logro:

- Fabricar la PCB.
- Ensamblar los multiplexores.
- Montar ESP32.
- Montar ADS1115.
- Conectar NTC.
- Probar lecturas de temperatura.
- Probar matriz de presion.
- Comunicar datos por WiFi.
- Visualizar datos en la app.
- Generar APK Android.
- Generar build/instalador Windows.
- Integrar electronica en caja impresa en 3D.
- Alimentar el sistema con powerbank.

## 15. Pruebas realizadas

Pruebas ya realizadas durante el desarrollo:

- Continuidad electrica en PCB.
- Verificacion de 5V y 3.3V.
- Pruebas de polaridad de entrada.
- Pruebas de lectura ADC en ESP32.
- Pruebas de ADS1115 por I2C.
- Pruebas de NTC individuales.
- Pruebas de matriz 8 x 8.
- Pruebas de ruido y valores fantasma.
- Pruebas con ESP32 nuevos.
- Pruebas con powerbank.
- Pruebas de app en Android.
- Pruebas de APK firmado.
- Pruebas de comunicacion por WebSocket.
- Pruebas de interfaz en pantallas pequenas.

## 16. Aprendizajes importantes del prototipo

Durante el proceso se encontraron varios puntos criticos:

- El footprint/orientacion fisica del ESP32 debe revisarse con mucho cuidado.
- Los modulos ESP32 DevKit V1 pueden variar entre fabricantes.
- El ADS1115 debe respetar exactamente el orden de pines.
- Las borneras deben elegirse por pitch correcto: 2.54 mm para NTC y 5.08 mm para entrada de poder.
- Los NTC no tienen polaridad.
- El montaje mecanico debe considerar espacio para cables, conectores y powerbank.
- El IDE y el core ESP32 pueden afectar la carga y comportamiento si cambian versiones.
- En Android release se requiere permiso de internet y permitir trafico cleartext para WebSocket local.

## 17. Limitaciones actuales

Derma Sense es todavia un prototipo y requiere validacion adicional:

- No es un dispositivo medico certificado.
- Las lecturas de presion son relativas, no una medicion clinica en mmHg.
- La calibracion depende del material de la matriz.
- Los NTC requieren calibracion y normalizacion por sensor.
- La app da recomendaciones orientativas, no diagnosticos.
- El sistema debe probarse con mas usuarios, pesos, posturas y superficies.
- La integracion mecanica aun puede mejorar.
- La carcasa impresa en 3D es funcional, pero no version industrial.

## 18. Posibles mejoras futuras

Mejoras propuestas:

- Calibracion guiada por usuario.
- Guardado historico de sesiones.
- Graficas de evolucion temporal.
- Alertas por tiempo prolongado en una misma zona.
- Comparacion de simetria izquierda/derecha.
- Mejor algoritmo de filtrado de ruido.
- Bateria integrada con medicion de carga.
- Version PCB revisada con orientacion de ESP32 corregida.
- Conectores mas robustos para ROWS/COLS.
- Carcasa mas compacta e industrial.
- Exportacion de reportes PDF/CSV.
- App para escritorio con instalador firmado.
- Integracion BLE como alternativa a WiFi.
- Validacion con profesionales de salud.

## 19. Flujo de uso propuesto

1. Encender Derma Sense desde el interruptor de la caja.
2. Esperar a que el ESP32 cree la red WiFi.
3. Conectar telefono o computadora a:

```text
TapeteMedico-ESP32
```

4. Usar password:

```text
tapete1234
```

5. Abrir la app Derma Sense.
6. Confirmar que la URL sea:

```text
ws://192.168.4.1:81
```

7. Presionar "Aplicar URL" o "Reconectar".
8. Elegir modo sentado o acostado.
9. Colocar a la persona sobre el tapete.
10. Observar mapa de presion, temperaturas y recomendaciones.

## 20. Archivos/builds relevantes

APK Android generado:

```text
C:\Users\alexp\OneDrive\Documentos\Projects\tapete_medico\build\app\outputs\flutter-apk\app-release.apk
```

Instalador Windows generado:

```text
C:\Users\alexp\OneDrive\Documentos\Projects\tapete_medico\build\windows\installer\derma_sense_setup_1.0.0.exe
```

SHA256 del APK release generado previamente:

```text
BAF65D46A61A69C2689DCEEAC468252D9EC524247723E6CFC0262649F9B8A12C
```

SHA256 del instalador Windows generado previamente:

```text
9be32b4b6129b1c5d6458709a83547543419339903055f277ff49bb14ecc5061
```

## 21. Descripcion corta para formulario

Derma Sense es un tapete inteligente de 50 x 50 cm con area activa de 40 x 40 cm que integra una matriz de presion 8 x 8 y seis sensores de temperatura NTC. El sistema usa una PCB propia con ESP32, dos multiplexores analogicos CD74HC4067 y un ADC ADS1115 para transmitir datos por WiFi a una app Flutter multiplataforma. Su objetivo es apoyar la deteccion temprana de zonas de presion y temperatura elevadas en personas sentadas o acostadas, ofreciendo visualizacion en tiempo real y recomendaciones orientativas.

## 22. Descripcion tecnica corta

El prototipo utiliza una matriz resistiva de presion de 64 puntos escaneada mediante dos CD74HC4067. La lectura analogica se realiza con el ADC del ESP32. Cuatro sensores NTC se leen mediante ADS1115 por I2C y dos sensores NTC se leen con ADC interno del ESP32. El firmware levanta un punto de acceso WiFi local y transmite los datos por WebSocket a `ws://192.168.4.1:81`. La aplicacion Derma Sense, desarrollada en Flutter, visualiza presion, temperatura, estado de conexion, modo postural y recomendaciones.

## 23. Pitch de 30 segundos

Derma Sense convierte un tapete comun en una herramienta inteligente para visualizar presion y temperatura corporal en tiempo real. Esta pensado para personas con movilidad limitada, cuidadores y entornos de rehabilitacion. El prototipo combina una matriz de presion 8 x 8, seis sensores de temperatura, una placa electronica propia y una app multiplataforma. Funciona con powerbank y WiFi local, por lo que no depende de internet. Su proposito es ayudar a identificar zonas de riesgo antes de que se conviertan en lesiones.

## 24. Prompt para otros LLM

Puedes usar este prompt para pedir ayuda a otro modelo:

```text
Estoy preparando una convocatoria de inventores/diseno para un proyecto llamado Derma Sense. Es un prototipo funcional de tapete sensorizado para apoyo en prevencion de lesiones por presion. El tapete total mide 50 x 50 cm y el area activa mide 40 x 40 cm. Tiene una matriz de presion 8 x 8 y 6 sensores NTC. La electronica usa una PCB propia de 100 x 100 mm, 2 capas, FR-4 TG150, 1.6 mm, ESP32 DevKit V1, 2 multiplexores CD74HC4067, un ADS1115, entrada 5V y powerbank de 5000 mAh. El ESP32 crea una red WiFi llamada TapeteMedico-ESP32 con password tapete1234 y transmite datos por WebSocket en ws://192.168.4.1:81. La app Flutter se llama Derma Sense y muestra presion, temperatura, modo sentado/acostado y recomendaciones orientativas.

Ayudame a convertir esta informacion en respuestas claras para una convocatoria de inventores/diseno. No hagas afirmaciones medicas absolutas; tratala como herramienta de apoyo preventivo y prototipo en validacion. Sugiere mejoras, impacto social, usuarios beneficiados, innovacion, descripcion tecnica, problema que resuelve, propuesta de valor y resumen ejecutivo.
```

## 25. Nota de responsabilidad

Derma Sense debe presentarse como prototipo tecnologico de apoyo, monitoreo y visualizacion. No debe presentarse como dispositivo medico certificado ni como herramienta diagnostica. Cualquier uso clinico requeriria validacion, calibracion formal, pruebas con usuarios, evaluacion de seguridad electrica, biocompatibilidad de materiales y cumplimiento normativo aplicable.
