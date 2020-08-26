---
title: "SnapRAID y MergerFS para almacenar archivos de forma fiable (y II)"
author: "Jesús Torres"
#date: 2019-02-27T11:29:01.097Z

summary: "Continuamos con la configuración de un espacio de almacenamiento fiable, automatizando la ejecución de SnapRAID en momentos concretos del día y configurando MergerFS para combinar varios discos en uno solo."

tags:
 - Linux
 - Almacenamiento

featuredImage: "images/featured.jpeg" 
images:
 - "images/1.jpeg" 

aliases:
 - "/snapraid-y-mergerfs-para-almacenar-archivos-de-forma-fiable-y-ii-11afbb19d23f"
---

_HDD --- [amendch](https://www.flickr.com/photos/39244466@N02/5427739593/in/photolist-9gCzT8-4UVUNJ-71Mb5R-91d5pX-oMFTx2-oMFQjD-5gDHxc-4oTnmH-bqrKL-6437bG-d3uXp7-9LgqFA-8bJz7i-3imxtM-ERbLe-7nGAFG-5gDHup-4oTnXc-9LgmKu-75fHu-qkKNAp-oWpoqT-pLwxeF-3KCpZN-9LgmbA-emkmar-9wLNNj-yoKes9-9Lgo3b-6j1N5L-xxhYh-ERcmU-9Lgrcw-dmA143-2DJQw-foCdqf-5wWien-9wHQvp-c9yGns-5TQgX3-2zEFt-VXYVdD-5SCmBK-6ViFwn-uHRq7-5TQoVw-s2QEx-uHRAy-VGJxwS-DCBbHY), [BY-NC-ND-2.0](https://creativecommons.org/licenses/by-nc-nd/2.0/)_

_Este artículo corresponde a una serie donde se explica como usar SnapRAID y MergerFS para disponer de un almacenamiento fiable formado por varios discos duros en un ordenador de sobremesa.
Si te has perdido la parte anterior, la tienes [aquí]({{< ref "posts/2019-02-18_snapraid-y-mergerfs-para-almacenar-archivos-de-forma-fiable-parte-1" >}})._

____

## Automatizar la ejecución de SnapRAID

Obviamente no podemos depender de acordarnos de ejecutar _SnapRAID_ cada día.
Así que lo que corresponde es automatizar su ejecución para que tenga lugar periódicamente.

Por fortuna [Zack Reed](http://zackreed.me) ofrece un script perfecto para la tarea, que yo mismo he modificado para adaptarlo a mis necesidades.
El script original está disponible [aquí](https://zackreed.me/updated-snapraid-sync-script/).
Mientras que el mio lo está en [GitHub Gist](https://gist.github.com/aplatanado/1ca6f96580be6e21957f877cfa3d5125).

Para instalarlo simplemente hay que descargarlo y copiarlo en `/usr/local/sbin/snapraid_diff_n_sync.sh`.
Después solo es necesario crear el archivo `/etc/cron.d/snapraid` con el siguiente contenido:

```
# /etc/cron.d/snapraid: crontab entries for snapraid package
# Run a SnapRAID diff and then sync  
30 23   * * *   root  /usr/local/sbin/snapraid_diff_n_sync.sh`
```

De esta forma el script será ejecutado automáticamente como `root` todos los días a las 23:30.

La diferencia entre el script original y el mío, es que el primero utiliza el correo electrónico para notificar cualquier problema detectado durante la ejecución.
Sin embargo, yo lo utilizo en un sistema de escritorio, por lo que prefiero que los mensajes se muestren en el área de notificaciones de la barra de tareas.

Para eso el script invoca otro script llamado `notify-send-all`, que sirve para enviar un mensaje a todos los usuarios con una sesión de escritorio activa.
Este script también debe ser descargado y copiado en la ruta `/usr/local/sbin/notify-send-all`.

{{< gist aplatanado e8810dbceece820b4ae5aa0ee5ca200a "notify-send-all" >}}

Finalmente puede ser necesario editar `snapraid_diff_n_sync.sh` para ajustar su configuración.
Esta configuración está disponible bajo la línea:

```
## USER DEFINED SETTINGS ##
```

* `DEL_THRESHOLD`, indica un umbral de archivos borrados.
Por ejemplo, si se establece a 50, la sincronización no tendrá lugar si se detecta que más del 50% de los archivos han sido borrados.
* `SCRUB_PERCENT`, indica el porcentaje de los datos que serán validados una vez se haya completado la sincronización.
Es decir, en cada ejecución se comprueba la integridad de una parte de los datos almacenados.
* `SCRUB_AGE`, indica la antigüedad mínima en días que debe tener un bloque para ser seleccionada para comprobar su integridad.

Una vez hecho, periódicamente la información de paridad se sincronizará con los últimos cambios y parte de nuestros datos más antiguos serán verificados.

## MergerFS

Ahora tenemos varios discos protegidos gracias a la información de paridad almacenada en el disco correspondiente.
Sin embargo, todos nuestros datos están repartidos entre discos diferentes.
Sería mucho mejor si pudiéramos acceder a todos los discos como si fueran un único dispositivo de almacenamiento.
Para eso es para lo que usaremos _MergerFS_.

Los paquetes de _MergerFS_ para distintas distribuciones se pueden descargar desde [GitHub](https://github.com/trapexit/mergerfs/releases).
Después solo hay que instalar _FUSE_ y el paquete descargado.
Por ejemplo:

```
$ sudo apt-get install fuse  
$ sudo dpkg -i mergerfs_2.25.1.ubuntu-xenial_amd64.deb
```

Luego se crea el punto de montaje:

```
$ sudo mkdir -p /media/storage/pool
```

Y se edita `/etc/fstab` para añadir la siguiente línea asegurar que se montan automáticamente durante el arranque del sistema:

{{< highlight cfg >}}
# BIBLIOTECA: MergerFS  
/media/storage/data* /media/storage/pool fuse.mergerfs defaults,allow_other,moveonenospc=true,minfreespace=20G,fsname=storage 0 0
{{< / highlight >}}

Esta línea monta todos discos de datos accesibles en `/media/storage` y los presenta como un único dispositivo de almacenamiento en `/media/storage/pool`.

### Opciones

Es interesante echar un vistazo a [todas las opciones que soporta MergerFS](https://github.com/trapexit/mergerfs#options) durante el montaje.
Como son muchas, solo voy a comentar las que utilizo yo:

* `allow_other`, permite que el sistema de archivos sea accesible por usuarios diferentes al que lo montó.
Como se monta automáticamente desde `/etc/fstab`, ese usuario es el `root`, por lo que esta opción es necesaria para poder usarlo desde una cuenta de usuario corriente del sistema.
* `moveonenospc=true`, si la escritura de datos en uno de los discos falla por falta de espacio, MergerFS buscará el disco con más espacio libre y con hueco suficiente para el archivo, moverá el archivo que se intenta modificar ahí y volverá a intentar la escritura.
* `minfreespace=20G`, asegura que a la hora de crear archivos nuevos solo se utilizarán aquellos discos con más de 20GB de espacio libre.
* `fsname`, la etiqueta del sistema de archivos con la que se mostrará en exploradores de archivos como Dolphin.

### Políticas

Tenemos que tener presente que _MergerFS_ soporta diferentes políticas a la hora de crear y modificar los archivos.
Por defecto:

*   Al crear un archivo en un ruta concreta, de todos los discos donde exista esa misma ruta cogerá aquel con más espacio libre.
Esta política sirve para controlar a dónde deben ir ciertos archivos, simplemente creando un directorio en el disco concreto que nos interese.
*   Al modificar las propiedades ---o metadatos--- de un archivo en una ruta concreta, se modificarán todos los archivos que tengan la misma ruta en todos los discos.
*   Para abrir un archivo se buscará en los discos según el orden indicado y se abrirá el primero que encuentre.

Según el uso que le queramos dar al almacenamiento puede ser interesante cambiar alguna de las políticas por defecto.
En [la documentación de MergerFS están explicadas las diferentes opciones](https://github.com/trapexit/mergerfs#functions--policies--categories).

## Mi experiencia

Llevo utilizando esta solución desde mayo de 2017 sin problemas.
Empleo el almacenamiento para guardar la colección de fotografías de las vacaciones ---gestionada con _digiKam_--- copias de seguridad de documentos, manuales, programas originales y otros contenidos.
Gracias a _Plex Server_, sirvo desde ahí los contenidos a otros dispositivos de la casa, sin ningún problema de rendimiento.

La sincronización ocurre todas las noches en segundo plano sin ningún inconveniente.
A veces se queja con una notificación en el escritorio si ese mismo día he movido de sitio una carpeta con muchos archivos.
Para resolverlo solo tengo que lanzar la sincronización manualmente, desde la línea de comandos.
Pero eso es buena señal.
Me da la seguridad de que si comento el error de hacer grandes cambios sin darme cuenta, la sincronización no tendrá lugar y podré volver hacia atrás fácilmente.

La política de asignación de espacio de _MergerFS_ funciona bastante bien.
El reparto del espacio ocupado en los discos es bastante equitativo.

Lo único que me falta es que un día falle un disco, para así comprobar si puedo sustituirlo por uno nuevo y recuperar su contenido con éxito.
Crucemos los dedos :wink:
