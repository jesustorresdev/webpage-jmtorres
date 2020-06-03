---
title: "Crea tu propia distro de Linux con Yocto"
author: "Jesús Torres"
date: 2013-01-22T00:00:00.000Z
lastmod: 2020-06-03T11:40:57+01:00

description: ""

subtitle: ""

image: "/posts/2013-01-22_crea-tu-propia-distro-de-linux-con-yocto/images/1.png" 
images:
 - "/posts/2013-01-22_crea-tu-propia-distro-de-linux-con-yocto/images/1.png" 


aliases:
    - "/crea-tu-propia-distro-de-linux-con-yocto-188157d840ea"
---

El objetivo de este artículo es explicar paso a paso como se puede utilizar el proyecto [Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) para crear nuestra propia distribución de Linux. Primero construiremos una para ejecutarla en [QEMU](http://wiki.qemu.org/) y después otra para nuestra Raspberry Pi.




![image](/posts/2013-01-22_crea-tu-propia-distro-de-linux-con-yocto/images/1.png)



### Inicio rápido

El inicio rápido con el proyecto [Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) está perfectamente documentado en [Yocto Project Quick Start](http://www.yoctoproject.org/docs/1.0/yocto-quick-start/yocto-project-qs.html). En cualquier caso aquí resumiremos los pasos deteniéndonos en los de mayor importancia.

#### Requisitos

*   **Una distribución de Linux.** En nuestro caso, por simplicidad, cualquiera de las basadas en Debian.
*   **Paquetes de desarrollo.** En el sistema deben estar instalados una serie de paquetes utilizados habitualmente en tareas de desarrollo. En un sistema basado en Debian deberían poder instalarse con el siguiente comando:`# sudo apt-get install sed wget cvs subversion git-core coreutils unzip texi2html texinfo libsdl1.2-dev docbook-utils gawk python-pysqlite2 diffstat help2man make gcc build-essential g++ desktop-file-utils chrpath libgl1-mesa-dev libglu1-mesa-dev mercurial autoconf automake groff`

*   **Una versión del proyecto** [**Yocto**](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/)**.** Las distintas versiones pueden descargarse desde la dirección [http://downloads.yoctoproject.org/releases/yocto/](http://downloads.yoctoproject.org/releases/yocto/)

### Construir una imagen de sistema Linux

El proceso de construir una imagen genera una distribución de Linux completa, incluyendo las herramienta de desarrollo para la misma.

Comenzamos descargando el sistema de construcción [Poky](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) de la última versión del proyecto [Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) y la descomprimimos.
`# wget [http://downloads.yoctoproject.org/releases/yocto/\  
yocto-1.6.1/poky-daisy-11.0.1.tar.bz2](http://downloads.yoctoproject.org/releases/yocto/yocto-1.6.1/poky-daisy-11.0.1.tar.bz2)  
# tar jxf poky-daisy-11.0.1.tar.bz2`

Creamos el directorio `raspberry-pi-build` donde construir la imagen y configuramos las variables de entorno necesarias.
`# source poky-daisy-11.0.1/oe-init-build-env raspberry-pi-build`

Como las variables de entorno configuradas por este comando se pierden al cerrar la shell, en caso de que eso ocurra o de abandonar la sesión sería necesario volver a ejecutar el anterior comando antes de continuar.

Construimos la imagen.
`# bitbake core-image-minimal`

Dicha imagen puede ejecutarse en [QEMU](http://wiki.qemu.org/) de la siguiente manera.
`$ runqemu qemux86`

Y en unos segundos tendremos acceso a la consola de nuestra nueva distribución.

#### Optimizando la construcción

En el archivo `conf/local.conf` del directorio `raspberry-pi-build` se pueden definir algunos parámetros que pueden reducir el tiempo necesario para construir la imagen si se dispone de un sistema multi-núcleo.

Si se tienen `N` núcleos, es conveniente descomentar las variables `BB_NUMBER_THREADS` y `PARALLEL_MAKE` y asignarle `N + 1`. Por ejemplo, con 8 núcleos el valor debería ser 9:
`BB_NUMBER_THREADS = “9”  
PARALLEL_MAKE = “-j 9”`

Mientras que para ahorrar espacio en disco se puede incluir la siguiente sentencia:
`INHERIT += “rm_work”`

Al hacerlo nos aseguramos de que el directorio donde se hace cada paquete es eliminado cuando se termina de hacer.

### Crear una distribución para ARM

El ejemplo estándar del proyecto [Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) se construye por defecto para la arquitectura **qemux86**. Es decir, para un sistema x86 que va a ejecutarse emulado sobre [QEMU](http://wiki.qemu.org/).

En caso de querer compilar para otra arquitectura sólo es necesario indicarlo en la configuración. Para eso, por ejemplo, buscamos la variable `MACHINE` en `raspberry-pi-build/conf/local.conf` e indicamos que la máquina de destino de la imagen es `qemuarm`:
`MACHINE ?= “qemuarm”`

Así estaríamos diciendo que queremos un sistema ARM que también va a ser ejecutado sobre [QEMU](http://wiki.qemu.org/). Para probarlo sólo nos quedaría construir la nueva imagen y ejecutarla en el emulador:
`# bitbake core-image-minimal  
# runqemu qemux86`

### Crear una distribución para Raspberry Pi

[Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) incluye de serie soporte para diversas arquitecturas. En caso de querer construir una imagen para alguna que no esté incluida sólo es necesario añadir una capa que incorpore los archivos de configuración necesarios.

Para Raspberry Pi dicha capa es **meta-raspberrypi**, una capa [BSP](http://en.wikipedia.org/wiki/Board_support_package) que agrupa todos los metadatos necesarios para construir imágenes para estos dispositivos. Fundamentalmente contiene configuraciones para el núcleo y opciones para la arquitectura.

Los pasos para incorporarla a nuestro proyecto comienzan por clonar localmente el repositorio **meta-raspberrypi** fuera del directorio `raspberry-pi-build`.
`# git clone [https://github.com/djwillis/meta-raspberrypi.git](https://github.com/djwillis/meta-raspberrypi.git)`

A continuación cambiamos a la rama **danny**, que es la de la versión de [Poky](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) que estamos usando.
`# cd meta-raspberrypi  
# git checkout danny`

Buscamos la variable `BBLAYERS` en `raspberry-pi-build/conf/bblayers.conf` y añadimos al final la ruta hasta el repositorio de la capa **meta-raspberrypi** para incluirla en el proceso de construcción. Por ejemplo:
`BBLAYERS ?= “   
 /home/usuario/poky-danny-8.0/meta   
 /home/usuario/poky-danny-8.0/meta-yocto   
 /home/usuario/poky-danny-8.0/meta-yocto-bsp   
 /home/usuario/meta-raspberry-pi   
“`

Posteriormente buscamos la variable `MACHINE` en `raspberry-pi-build/conf/local.conf` e indicamos que la máquina de destino de la imagen es `raspberrypi`
`MACHINE ?= “raspberrypi”`

Finalmente construimos la imagen.
`# cd raspberry-pi-build  
# bitbake rpi-basic-image`

Esta imagen incluye un servidor **SSH** y un _splash_ de Raspberry Pi durante el arranque. Mientras que la imagen alternativa `rpi-hwup-image` no contiene ninguna de las dos cosas.

Para probarla en el dispositivo, sólo tenemos que transferir la imagen construida a la tarjeta SD.
`sudo dd if=tmp/deploy/images/rpi-basic-image-raspberrypi.rpi-sdimg \ of=/ruta/a/la/sd`

### Referencias

1.  [Yocto Project Quick Start](http://www.yoctoproject.org/docs/1.0/yocto-quick-start/yocto-project-qs.html).
2.  [Poky HandBook](http://pokylinux.org/doc/poky-handbook.html).
3.  [Build a Custom Raspberry Pi Distro with OpenEmbedded &amp; Yocto](http://web.archive.org/web/20141220181842/http://www.pimpmypi.com/blog/blogPost.php?blogPostID=7).
