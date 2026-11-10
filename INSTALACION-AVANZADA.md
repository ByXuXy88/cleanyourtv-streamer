# Inicio, limpieza de paquetes y reversión

## Antes de cambiar Inicio

Guarda localmente la compilación, el Inicio que resuelve Android y el estado de los paquetes. Hazlo con la conexión autorizada y el mando a mano. Guarda la captura fuera del repositorio público.

```sh
adb -s "<dispositivo>" shell getprop ro.build.display.id
adb -s "<dispositivo>" shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
adb -s "<dispositivo>" shell pm list packages -d --user 0
adb -s "<dispositivo>" shell pm list packages -3 --user 0
```

Prueba el launcher como app. Comprueba mando, Wi-Fi, actualizaciones, reproducción con DRM y Cast si lo usas. Puedes intentar seleccionar Inicio con `adb shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity` contra tu dispositivo explícito y comprobar otra vez qué actividad resuelve Android. En algunos firmwares Google TV sigue tomando el control. La redirección por accesibilidad de CleanYourTV es una opción documentada en la [guía original](https://github.com/Gathin23/cleanyourtv/blob/v3.4.0/docs/TROUBLESHOOTING.md).

En el Streamer probado, el paso a Inicio nativo incluyó deshabilitar el asistente de configuración de Google y su launcher. Esta parte es opcional, depende del firmware y requiere comprobar antes quién creó la red Wi-Fi guardada. En equipos Google puede romper el envío de contenido por Cast. El Chromecast con Google TV 4K también puede abrir una pantalla de recuperación al deshabilitar solo el launcher original. Consulta las [notas de Home para Sabrina](https://github.com/Gathin23/cleanyourtv/issues/1573) y la [incidencia de Cast](https://github.com/Gathin23/cleanyourtv/issues/361) antes de elegir esa ruta.

## Limpieza opcional y reversible

Los candidatos observados en el Streamer fueron Feedback de Google (`com.google.android.feedback`), Health Connect (`com.google.android.healthconnect.controller`), AdServices (`com.google.android.adservices.api`) y utilidades de terceros que el dueño dejó de usar. Comprueba que el paquete exista y que realmente prescindas de su función. Conserva los componentes de conexión, entrada, mando, DRM, Play Store y actualizaciones. Usa las herramientas y comprobaciones del [proyecto original](https://github.com/Gathin23/cleanyourtv/tree/v3.4.0#doing-it-by-hand) y prueba una modificación cada vez.

Si elegiste un tema con pocas utilidades visibles, puedes instalar AIDA64 y un explorador desde Play Store y añadir sus paquetes al cajón. Cada persona decide qué apps y accesos quiere ver.

## Actualizar apps con ObtainX y Shizuku

[ObtainX](https://github.com/bikram-agarwal/ObtainX) consulta las fuentes de cada app y puede usar [Shizuku](https://github.com/RikkaApps/Shizuku) como instalador en segundo plano. Instala ambas herramientas desde sus fuentes oficiales, inicia Shizuku, selecciónalo como modo de instalación en ObtainX y autoriza ObtainX en el aviso de Shizuku. Usa APK compatibles con el dispositivo y firmados con la misma clave que la app instalada. [Modos de instalación de ObtainX](https://github.com/bikram-agarwal/ObtainX/blob/main/docs/Difference_with_Obtainium.md).

En Android 11, Shizuku puede usar el emparejamiento inalámbrico si el fabricante lo ofrece. El manual de Shizuku documenta el inicio desde un ordenador con ADB para dispositivos sin root en Android 10 y anteriores. Comprueba los requisitos de la versión de Shizuku y de ObtainX que instales. La recuperación automática de CleanYourTV se comprobó en la [Philips con Android TV 11](perfiles/philips-ph0m-ea-t32/README.md#shizuku-y-obtainx) y depende de que el firmware vuelva a abrir el ADB local tras reiniciar. [Manual de Shizuku](https://shizuku.rikka.app/guide/setup/).

## Volver atrás

1. Detén el monitor de reposo con `python monitor.py --device "<dispositivo>" stop` y desactívalo desde CleanYourTV.
2. Restaura los estados originales de los paquetes que cambiaste con la [herramienta de reversión de CleanYourTV](https://github.com/Gathin23/cleanyourtv/blob/v3.4.0/tools/restore.sh) y la misma lista que aplicaste. Si cambiaste manualmente un paquete que antes estaba en estado predeterminado, usa `pm default-state --user 0 <paquete>` sobre ese paquete concreto.
3. Si cambiaste Inicio, vuelve a habilitar los componentes originales que desactivaste y selecciona el componente HOME que registraste. Pulsa Inicio y prueba el mando, Wi-Fi, DRM y Cast.
4. Si activaste la redirección por accesibilidad, desactiva únicamente el servicio de CleanYourTV desde Ajustes. Puedes restablecer el tema con la herramienta original.
