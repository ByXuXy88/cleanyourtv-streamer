# Chromecast con Google TV (4K)

La unidad de prueba se identificó como `sabrina` y ejecutaba Android 14, compilación `UTTC.250917.004.14193937`. Google indica 2 GB de RAM, 8 GB de almacenamiento, salida hasta 4K y Wi-Fi ac. [Comparativa oficial de Google](https://store.google.com/es/magazine/google_tv_streamer_compare?hl=es)

## Configuración probada

Se instaló la misma compilación de CleanYourTV que en el [Google TV Streamer](../google-tv-streamer-4k/README.md) y se verificó el tema de tres filas. El [tema reutilizable](../../config.json) permite elegir las apps de Inicio y reservar el cajón para utilidades como AIDA64 y X-plore.

En este firmware se verificó que CleanYourTV resolvía Inicio tras el cambio al launcher nativo. La operación requirió comprobar primero la red Wi-Fi guardada y deshabilitar el Inicio original y SetupWraith. Aplica ese cambio solo tras probar el launcher, el mando y los servicios que utilices. Netflix permaneció disponible. Cast puede verse afectado tras el reinicio y merece una prueba aparte si lo usas. [Instalación y reversión](../../INSTALACION-AVANZADA.md)

Se desactivaron para el usuario 0 Feedback, Health Connect, AdServices, Downloader, Play Juegos y Play Películas en la unidad probada. La lista es un registro de la prueba. Comprueba qué paquetes existen y guarda su estado antes de aplicar cambios en otro equipo.

## Mediciones

| Medida con AIDA64 2.26 y CleanYourTV | Resultado |
| --- | ---: |
| Apertura de AIDA64 en frío, mediana de 5 | 723 ms |
| Vuelta de AIDA64 a Inicio, mediana de 5 | 146 ms |
| Apertura de Inicio en frío, mediana de 3 | 595 ms |
| RAM disponible al tomar la muestra | 878.600 KiB |
| Espacio libre en `/data` al tomar la muestra | 815 MiB aprox. |

Los tiempos son `WaitTime` de Android. Las vueltas a Inicio fueron 1041, 116, 146, 136 y 218 ms. La muestra lenta quedó reflejada para que la mediana no oculte la variación observada. La [ficha del Streamer](../google-tv-streamer-4k/README.md#mediciones) recoge las mismas pruebas en ese dispositivo.

## Reposo, reinicio y ObtainX

Se probó el reinicio y el chip de limpieza. En la unidad probada, la depuración inalámbrica se desactivó después de reiniciar y hubo que volver a encenderla con el dispositivo en la Wi-Fi correcta. Para preparar el monitor, usa el modo `--experimental` del [procedimiento de reposo](../../README.md#activar-la-limpieza-en-reposo) y autoriza al propio dispositivo cuando el chip lo solicite.

Se añadieron en ObtainX las fuentes de Nuvio, SmartTube e IPTV Extreme Pro, con comprobaciones cada seis horas. Android registró el trabajo en segundo plano. La configuración se verificó antes de que hubiera una nueva versión que permitiera probar el siguiente ciclo de instalación.
