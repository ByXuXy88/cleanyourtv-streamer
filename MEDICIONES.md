# Tiempos de respuesta en el Google TV Streamer

Pruebas en el mismo Google TV Streamer (4K), Android 14, compilación `UTTK.260317.003`. El punto de partida es una configuración anterior de CleanYourTV. Las columnas son observaciones de sesiones distintas con el mismo procedimiento. El estado de la caché y la carga del sistema pueden cambiar entre sesiones.

| Medida | Versión anterior, animación normal | Versión anterior, movimiento reducido | Versión con los añadidos, perfil habitual |
| --- | ---: | ---: | ---: |
| Arranque en frío, mediana de 3 | 492 ms | 516 ms | 481 ms |
| Volver desde Ajustes, mediana de 5 | 69 ms | 66 ms | 80 ms |
| Tiempo de dibujo por fotograma, percentil 95 | 14 ms | 13 ms | 14 ms |
| Fotogramas con retraso según Android | 0 de 747 | 0 de 265 | 1 de 693 (0,14 %) |
| Memoria atribuida a CleanYourTV (PSS) | 68,4 MiB | 64,5 MiB | 54,4 MiB |

La última sesión dio 481, 498 y 472 ms en frío, y 74, 82, 80, 87 y 74 ms al volver desde Ajustes. Son valores `WaitTime` de `am start -W`. Para los fotogramas, `dumpsys gfxinfo` registró la misma secuencia de 48 pulsaciones en cada sesión. El tiempo físico desde que se pulsa el mando queda fuera de esta medición.

Para repetir el procedimiento, deja Inicio abierto y usa el [script de medición](measure-cleanyourtv.sh). Durante la prueba el script cierra y vuelve a abrir el launcher. Comprueba el modelo y que CleanYourTV tenga el rol HOME antes de comenzar.

```sh
adb -s "<dispositivo>" shell sh -s < measure-cleanyourtv.sh
```

En PowerShell puedes usar `Get-Content -Raw measure-cleanyourtv.sh | adb -s "<dispositivo>" shell sh -s`.

## Reposo después de un reinicio completo

El chip apareció gris. Al pulsarlo se inició el monitor desde el propio Streamer y pasó a verde. En el siguiente reposo se cerraron 5 apps. La RAM disponible pasó de 2 059 196 a 2 072 032 KiB. Al volver a Inicio apareció [el aviso de 13 MB durante cinco segundos](aviso.png). La cantidad es una estimación de esa sesión.
