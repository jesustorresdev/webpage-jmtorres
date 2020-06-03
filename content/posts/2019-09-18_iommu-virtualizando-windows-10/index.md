---
title: "IOMMU: Virtualizando Windows 10"
author: "Jesús Torres"
date: 2019-09-18T21:36:51.827Z
lastmod: 2020-06-03T11:43:06+01:00

description: "Cómo montar un sistema de escritorio virtualizado con Windows 10, asignándole una GPU de forma exclusiva."

subtitle: "Cómo montar un sistema de escritorio virtualizado con Windows 10, asignándole una GPU de forma exclusiva."

image: "/posts/2019-09-18_iommu-virtualizando-windows-10/images/1.png" 
images:
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/1.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/2.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/3.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/4.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/5.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/6.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/7.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/8.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/9.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/10.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/11.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/12.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/13.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/14.png" 
 - "/posts/2019-09-18_iommu-virtualizando-windows-10/images/15.png" 


aliases:
    - "/iommu-virtualizando-windows-10-9afb7c01c358"
---

![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/1.png)

Detalle de configuración de la máquina virtual en el anfitrión junto al escritorio de Windows 10 virtualizado.

_Este artículo corresponde a una serie donde se explica como montar un sistema de escritorio virtualizado, asignándole una GPU de forma exclusiva para obtener un rendimiento similar al de un sistema no virtualizado. Si te has perdido alguna parte anterior de esta historia, la primera la tienes_ [_aquí_](https://medium.com/jmtorres/iommu-primer-asalto-7d342f7e77e5) _y la segunda_ [_aquí_](https://medium.com/jmtorres/iommu-la-maldici%C3%B3n-de-la-vga-cb016e0385a7)_._Como he comentado en artículos anteriores, quiero instalar Windows 10 en una máquina virtual sobre Ubuntu 18.04 LTS. Como estoy interesado en conseguir el máximo rendimiento gráfico en Windows, quiero que la máquina virtual tenga acceso exclusivo a la tarjeta gráfica, dejando para Ubuntu la gráfica integrada de Intel.

Para que esta configuración funcione es necesario:

1.  Una CPU y una placa madre con soporte para la tecnología VT-d — o Intel(R) Virtualization Technology for Directed I/O, que es el nombre que Intel le da a la tecnología de la IOMMU — . En algunos casos hay que activar dicho soporte desde la BIOS / UEFI.
2.  Una tarjeta gráfica con una ROM que soporte UEFI. La mía es una Geforce GTX 950, pero cualquier tarjeta gráfica de los últimos años sirve.

### Instalación del software

Para empezar necesitamos QEMU/KVM, libvirt, OVMF y virt-manager:
`# sudo apt-get install qemu-kvm ovmf libvirt-clients \  
libvirt-daemon-system bridge-utils virt-manager`

[virt-manager](https://virt-manager.org/) (Virtual Machine Manager) será la aplicación que utilizaremos para configurar y lanzar la máquina virtual. Básicamente se trata de una aplicación de escritorio para gestionar máquinas virtuales a través de [libvirt](https://libvirt.org/), por lo que libvirt se instará automáticamente como dependencia de virt-manager.

Para que podamos lanzar máquinas virtuales con virt-manager necesitamos que nuestro usuario esté dentro del grupo `libvirt`. Podemos añadirlo así:
`# sudo adduser $(id -un) libvirt`

Obviamente tendremos que cerrar la sesión y volver a iniciarla para que el cambio tenga efecto.

Nuestra máquina virtual necesita un [firmware UEFI](https://es.wikipedia.org/wiki/Extensible_Firmware_Interface) para arrancar —como el de cualquier placa madre real — por lo que utilizaremos el del proyecto [OVMF](https://github.com/tianocore/tianocore.github.io/wiki/OVMF) (Open Virtual Machine Firmware) que es un firmware UEFI especialmente preparado para máquinas virtuales QEMU/KVM.

Desde [el repositorio del Gerd Hoffmann](https://www.kraxel.org/repos/jenkins/edk2/) se puede obtener la última versión compilada de OVMF. De hecho eso fue lo que hice la primera vez, al configurar una máquina virtual de esta manera en una Ubuntu 16.04 LTS. Sin embargo, actualmente no debería haber ningún problema con la versión de OVMF empaquetada con cualquier distribución moderna, así que nos saltaremos ese paso.

### Activar IOMMU

Lo primero es activar el soporte de [IOMMU](https://medium.com/jmtorres/iommu-primer-asalto-7d342f7e77e5) en el núcleo. Para eso editamos `/etc/default/grub` y añadimos `intel_iommu=on` a la variable `GRUB_CMDLINE_LINUX_DEFAULT`. Después ejecutamos:
`# sudo update-grub`

para actualizar la configuración del gestor de arranque con la nueva opción.

En algunos casos se ha informado de problemas durante el arranque o al reproducir sonido a través del HDMI de la gráfica integrada. Los efectos son diversos y diferentes entre sistemas. Por ejemplo, algunos informes hablan específicamente de problemas al usar el audio HDMI en procesadores de la micro-arquitectura Haswell, pero no siempre se pueden conectar estos problemas con un hardware concreto.

El asunto es que en caso de problemas es buena idea probar a desactivar la IOMMU para la gráfica integrada, utilizando la opción `intel_iommu=on,igfx_off`. De hecho mi configuración es:
``GRUB_CMDLINE_LINUX_DEFAULT=&#34;`intel_iommu=on,igfx_off quiet splash&#34;`

Además, se sabe que hay una importante pérdida de rendimiento en los procesador Sandy Bridge al activar IOMMU. En ese caso se recomienda usar la opción `intel_iommu=pt` en lugar de `intel_iommu=on`. En la [documentación de Linux](https://www.kernel.org/doc/Documentation/Intel-IOMMU.txt) hay más información sobre la configuración de IOMMU en Intel:

Una vez actualizada la configuración del gestor de arranque, debemos reiniciar el sistema y comprobar que el soporte de IOMMU está activado examinando los registros del sistema:
`# journalctl -b | grep DMAR`

Vamos por el buen camino si en la salida del comando anterior vemos una línea que dice:
`kernel: DMAR: IOMMU enabled`

Si hemos usado la opción `igfx_off`, además debe haber otra que dice:
`kernel: DMAR: Disable GFX device mapping`

Si vemos que el soporte de IOMMU no se activa, puede ser que se nos hayamos olvidado activar el soporte de VT-d en la configuración de la BIOS / UEFI de nuestro sistema. O tal vez nuestra CPU o nuestra placa madre no tengan soporte para VT-d.

### Registro de dispositivos en VFIO

Las aplicaciones de virtualización como QEMU/KVM necesitan acceso al dispositivo que se quiere mapear. Para hacerlo utilizan las facilidades de [VFIO](https://www.kernel.org/doc/Documentation/vfio.txt), que es un controlador de dispositivo de Linux cuya función es ofrecer a los procesos en modo usuario acceso directo a los dispositivos. Este tipo de acceso es lo que necesita la aplicación de virtualización, pero también puede ser útil para desarrollar controladores de dispositivo que se ejecuten en modo no privilegiado.

VFIO no puede ofrecer a las aplicaciones acceso a cualquier dispositivo del sistema. Solo lo hace a aquellos que han sido registrados previamente en VFIO. Y para que eso sea posible, el dispositivo no puede estar siendo usado por otro controlador.

Pongamos que, como queremos hacer _VGA passthrough_, nos interesa registrar nuestra tarjeta gráfica en VFIO. Lo primero es obtener la lista de dispositivos, ejecutando el comando:
`# lspci -nn`

El resultado será similar al de la siguiente imagen. La línea marcada corresponde con la tarjeta gráfica instada en mi ordenador que quiero usar con la máquina virtual:



![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/2.png)

Ejemplo de ejecutar el comando “lspci -nn”.

El texto `[10de:1002]` del final de la línea marcada nos indica que el fabricante de esa tarjeta gráfica tiene el identificador 0x10DE y que el modelo se identifica como 0x1402.

Así que para registrar esta tarjeta habría que indicarle al controlador VFIO estos identificadores de la siguiente manera:
`# echo 10DE 1402 |sudo tee /sys/bus/pci/drivers/vfio-pci/new_id`

El problema es que esto hay que hacerlo antes de iniciar la máquina virtual y para cada dispositivo que queremos asignarle. En mi caso no sólo es la tarjeta gráfica, también el dispositivo de audio HDMI de la misma tarjeta —justo en la linea siguiente — y un concentrador raíz USB — el ASM1042 SuperSpeed USB Host Controller — para poder conectar directamente un teclado y ratón USB, en caso de que hiciera falta.

Además, antes de registrar estos dispositivos en VFIO, hay que desregistrarlos del controlador de dispositivo que Linux le haya asignado para usarlos en el sistema anfitrión. En el caso particular de las tarjetas gráficas, es incluso mejor descargar el controlador de dispositivo correspondiente, porque no suelen llevar muy bien que les asignen y les quiten dispositivos en caliente durante la ejecución.

Para no hacerlo a mano en cada ocasión es interesante tener un _hook_ de libvirt que lo haga automáticamente cada vez que se inicia la máquina virtual.

### Instalar el libvirt hook

En GitHub tengo un repositorio donde he ido poniendo scripts y archivos de configuración relevantes para este proyecto:

[aplatanado/virtual-desktop](https://github.com/aplatanado/virtual-desktop)


Dentro del directorio `libvirt-hooks` está el script `qemu`, que es el _hook_ que se encargará del registro en VFIO durante el arranque de la máquina virtual.

Se puede instalar así:
`# sudo install -m755 libvirt-hooks/qemu /etc/libvirt/hooks`

[Libvirt admite 5 scripts de hook](https://libvirt.org/hooks.html#names). El script `qemu` se ejecuta cuando libvirt inicia, detiene o migra una máquina virtual de QEMU; que es nuestro caso. Eso significa que si tenemos varias máquinas virtuales de QEMU y queremos hacer cosas diferentes para cada una, debemos ponerlo todo en el mismo script `/etc/libvirt/hooks/qemu`.

Del script hay dos funciones a las que merece la pena echar un vistazo. Una es `vfio_bind_devices()` que, dado el identificador de un dispositivo, lo registra en VFIO para hacer _PCI passthrough_.




Da una buena idea de todos los pasos que habría que hacer si quisiéramos hacerlo a mano. Además, trata el caso de las tarjetas gráficas NVIDIA de forma especial, puesto que es mucho mejor descargar los módulos correspondientes del núcleo.

La otra función es el método `LibvirtHook.on_host_prepare()`, que contiene el código que llama a `vfio_bind_devices()` antes del inicio de la máquina virtual de nombre “hoth”, que es el nombre mi máquina virtual con Windows.




Si nuestra máquina virtual se llama “foo”, solo necesitamos renombrar el método como `on_foo_prepare()`.

Este método no sólo registra los dispositivos en VFIO para hacer _PCI passthrough_. También busca las redes virtuales a las que está conectada la máquina virtual y le indica a libvirt que las active.

### Liberar la gráfica

El script anterior solo podrá descargar el controlador de la tarjeta gráfica si no es la que estamos usando actualmente para el escritorio de Linux. Podemos consultar qué gráfica está usando actualmente nuestro entorno gráfico ejecutando:
`# prime-select query  
nvidia`

Si estamos usando la tarjeta gráfica, podemos seleccionar la gráfica integrada ejecutando:
`# prime-select intel`

Después tendremos que reiniciar el sistema o salir de la sesión de escritorio y reiniciar el gestor de pantalla:
`# sudo systemctl restart display-manager`

### Crear la máquina virtual

Hecho todo esto, podemos lanzar virt-manager para crear nuestra máquina virtual. Seleccionamos la opción de menú “Archivo” _&gt; “_Nueva máquina virtual”, se nos abrirá el asistente y seguimos los pasos indicados:

1.  Instalación mediante “Medio de instalación local”.
2.  Seleccionamos “Utilizar imagen ISO” y seleccionamos la imagen ISO con el contenido del CD de instalación de Windows.
3.  Asignamos el número de CPU disponibles y la cantidad de memoria RAM. En mi caso la máquina virtual tiene 4 CPU y 8GB de RAM. Sin embargo, posteriormente veremos cómo indicar que la cantidad real asignada sea menor.
4.  Indicamos el tamaño del disco duro de la máquina virtual. Yo opté por usar un [volumen lógico LVM](https://es.wikipedia.org/wiki/Logical_Volume_Manager), dentro del mismo grupo de volumen que contiene los volúmenes lógicos de mi sistema anfitrión Linux. Aunque no voy a detenerme en explicar cómo se hace.
5.  Por defecto la imagen del disco duro se guarda en un archivo con formato [“qcow2”](https://en.wikipedia.org/wiki/Qcow). Eso es interesante si queremos ahorrar espacio, dado que empieza siendo un archivo muy pequeño y su tamaño aumenta dinámicamente según va ocupando espacio la máquina virtual. Pero si lo que nos interesa es el mejor rendimiento, mejor optar por el formato “raw”. En ese caso elegimos “Seleccionar o crear almacenaje personalizado” y le pedimos crear un nuevo volumen. Nos dejará escoger el nombre del archivo, formato y tamaño.



![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/3.png)

Crear un volumen del almacenamiento en formato “raw”.



En la última ventana marcamos “Personalizar antes de instalar” y finalmente le damos un nombre.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/4.png)

Último paso en el asistente de creación de la máquina virtual.



Al pulsar en finalizar se abre la ventana de detalles de la nueva máquina virtual.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/5.png)

Detalles generales de configuración antes de iniciar la instalación.



Seleccionamos el firmware UEFI, en lugar de BIOS, y el modelo del _chipset_. La configuración más segura es con [i440FX](https://es.wikipedia.org/wiki/Intel_440FX). A mi no me fue posible iniciar la instalación con Q35, puesto que con ese _chipset_ la interfaz con los discos duros es AHCI y la versión de OVMF que estaba utilizando no lo soportaba. Entonces intenté añadir un chip PIIX4, para tener una interfaz IDE a la que conectar el disco duro, pero Windows no era capaz de verlo durante la instalación.

En principio, la primera opción debería ser i440FX, dejando Q35 para los casos en los que el primero no funciona. Por ejemplo, si queremos instalar una máquina virtual con macOS.

Aceptamos y avanzamos a la configuración de las CPU:




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/6.png)

Detalles sobre la configuración de las CPU antes de iniciar la instalación.



Aquí lo adecuado es indicar como modelo “host-passthrough”. Está opción no está en la lista desplegable, así que tendremos que escribirla a mano. Básicamente le dice a KVM que “pase” a la máquina virtual la CPU del anfitrión tal cual, sin modificaciones.

Además se puede modificar la topología, es decir, cómo se exponen las CPU a la máquina virtual. Como se puede ver he optado porque la máquina virtual tenga una sola CPU, con 4 núcleos y un hilo de ejecución en cada uno.

Lo siguiente es modificar la configuración del disco duro principal: “IDE Disco 1”.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/7.png)

Detalles sobre la configuración del disco duro antes de iniciar la instalación.



Por defecto QEMU emula una interfaz IDE para el acceso al disco duro. Sin embargo se puede mejorar el rendimiento desplegando “Opciones avanzadas” y cambiando “Bus de disco” a SCSI. Luego se pulsa en “Agregar hardware” y se añade un “Controlador” del tipo SCSI y modelo VirtIO SCSI.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/8.png)

Añadir un controlador de disco VirtIO SCSI.



[VirtIO](https://es.wikibooks.org/wiki/QEMU/Dispositivos/Virtio) es una interfaz de disco paravirtualizada. Es decir, no emula una interfaz de disco real, como IDE o SCSI; sino que la máquina virtual sabe que es una interfaz por software diseñada para virtualización. El resultado es un mayor rendimiento. Sin embargo Windows no sabe acceder a estos dispositivos si no se le proporcionan controladores adecuados durante la instalación.

Para que estos controladores estén disponibles necesitamos una segunda unidad de CDROM. Pulsamos en “Agregar hardware” y añadimos “Almacenamiento” de tipo de dispositivo CDROM y tipo de bus IDE.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/9.png)

Añadir una unidad de CDROM para los controladores VirtIO.



Hay que indicar que use la imagen ISO con los controladores VirtIO. La última versión se puede descargar desde [aquí](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/).

Finalmente pulsamos en iniciar la instalación.

Si el firmware UEFI no inicia la instalación sino que nos deja en una interfaz de línea de comandos como la siguiente_:_




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/10.png)

Interfaz de línea de comandos de OVMF



tendremos que buscar y lanzar nosotros mismos el arranque del instalador, ubicado seguramente en `FS0:\EFI\BOOT\BOOTX64`:




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/11.png)

Pasos para localizar el arranque del instalado de la ISO de Windows.



Llegados a este punto la instalación debería proceder con normalidad. Cuando nos pregunte dónde instalar Windows, pulsamos en la opción de “Cargar controlador”, buscamos la unidad de CDROM con los controladores VirtIO y navegamos por las carpetas hasta `viosci \ w10 \ amd64`, para instalar los controladores de 64 bits para Windows 10.

Una vez instalado el controlador, el instalador nos dejará seleccionar el disco duro virtual como unidad de destino y completar la instalación.

### Ajuste fino de la máquina virtual

Una vez apagada la máquina virtual, si seleccionamos en el menú el icono con una exclamación —con el texto de ayuda “Mostrar detalles del hardware virtual” — podemos ver la configuración definitiva y ajustarla.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/12.png)

Hardware de la máquina virtual tras la instalación.



Podemos quitar las unidades CDROM o, en todo caso, dejar solo una por lo que pueda surgir. También se puede quitar el dispositivo tipo “Serial” y añadir uno de tipo “Tableta”. La tableta nos permite evitar problemas con el posicionamiento del puntero y usar el ratón con la pantalla de la máquina virtual sin antes tener que hacer clic.

Si hemos dejado una unidad CDROM, podemos cambiar su “Bus de disco a SCSI”. Eso nos permite eliminar también los dispositivos “Controller IDE”.

#### Rendimiento del almacenamiento

En las “Opciones de Rendimiento” del “SCSI Disco” se puede indicar el modo caché como “none” y el modo E/S como “native”.

El primero evita que el anfitrión consuma memora cacheando las operaciones de E/S de la máquina virtual. Esto también lo hace el sistema operativo de la máquina virtual, por lo que no tiene sentido hacerlo dos veces. Quizás fuera útil si pensáramos lanzar varias máquinas virtuales que accedan al mismo tiempo a los mismos dispositivos de almacenamiento.

El segundo activa el uso de [llamadas al sistema nativas de Linux para la E/S asíncrona](https://blog.cloudflare.com/io_submit-the-epoll-alternative-youve-never-heard-about/) al archivo con el contenido del disco duro virtual. El valor por defecto usa hilos y operaciones síncronas.

La combinación de estas dos opciones debería ofrecernos mejor rendimiento que las opciones por defecto.

Dentro de la máquina virtual, en el intérprete de comandos de Windows, es interesante ejecutar este comando:
`fsutil behavior query DisableDeleteNotify`

Si devuelve 0, nos indica que cuando un bloque del almacenamiento deja de usarse, Windows envía al dispositivo el comando TRIM para indicarle que ha quedado libre.

Si estamos usando una imagen de disco en formato “raw”, esto no tendrá ningún efecto. Pero con “qcow2” el archivo reducirá su tamaño, al necesitar menos espacio para almacenar la imagen. Si usamos un volumen lógico LVM sobre un dispositivo SSD, como es mi caso, el comando TRIM se propagará hasta el SSD, evitando la degradación del rendimiento del dispositivo.

Si hiciera falta, para activarlo hay que ejecutar:
`fsutil behavior set DisableDeleteNotify 0`

#### Rendimiento de la interfaz de red

La tarjeta de red de la máquina virtual es el dispositivo con el nombre “NIC &lt;MAC&gt;”. Por lo general se trata de una emulación de una tarjeta Intel e1000 o una [Realtek RTL8139](https://es.wikipedia.org/wiki/Realtek). Se puede obtener mejor rendimiento cambiando el “Modelo de dispositivo” a “virtio”, que es una interfaz de red paravirtualizada, como la que usamos con el disco duro virtual. Lo único es que es necesario iniciar la máquina virtual e instalar los controladores de la carpeta `NetKVM` de la ISO de controladores VirtIO.

Por defecto la interfaz de red de la máquina virtual está conectada a una red virtual llamada “default”, en la que también está el equipo anfitrión. En esta red la máquina virtual recibe una IP privada y su acceso a Internet se realiza a través del anfitrión usando [NAT](https://es.wikipedia.org/wiki/Traducci%C3%B3n_de_direcciones_de_red).

Todo esto se puede simplificar mucho cambiando “Fuente de red” a “Dispositivo anfitrión &lt;interfaz&gt;: [macvtap](https://virt.kernelnewbies.org/MacVTap)” y “Modo de fuente” a “Puente”. Al hacerlo, la máquina virtual pasa a algo así como a compartir la la tarjeta de red “&lt;interfaz&gt;” del equipo anfitrión. La red le asignará a la máquina virtual una IP como si fuera una máquina real y de esta forma puede conectarse al resto de equipos de la red y a Internet sin usa al anfitrión como intermediario.

En mi caso, al usar “macvtap” en Ubuntu 16.04, la interfaz de red funcionaba en el primer arranque pero nunca en posteriores. Se debía a un conflicto con NetworkManager, que decidía por su cuenta bajar la interfaz “macvtap” anfitrión. Se resuelve editando el archivo `/etc/NetworkManager/NetworkManager.conf` para añadir lo siguiente:
`[keyfile]  
unmanaged-devices=interface-name:macvtap0`

para que NetworkManager no intente gestionar esa interfaz. En Ubuntu 18.04, por el momento no he tenido ningún problema similar, así que no parece que haga falta este truco.

#### QXL

En el dispositivo Video Cirrus se puede cambiar el modelo a QXL. El modelo Video Cirrus emula una tarjeta gráfica VGA del fabricante Cirrus Logic. Mientras que QXL es un dispositivo de vídeo paravirtualizado, por lo que ofrece mejor rendimiento. Además, mientras que con la emulación VGA estamos limitados a una resolución 800x600, con QXL tenemos automáticamente 1024x768. Será necesario iniciar la máquina virtual e instalar los controladores de la carpeta `qxldod` de la ISO de controladores VirtIO.

#### Asignación de memoria RAM

En la configuración de memoria podemos configurar cuánta memoria pensará la máquina virtual que tiene —la “Asignación máxima” — y cuanta memoria del anfitrión puede realmente usar como máximo —la Asignación actual — .

Por ejemplo, mi máquina virtual piensa que tiene 8GB de RAM pero el sistema anfitrión nunca le asignará más de 4GB de memoria.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/13.png)

Configuración de la asignación de memoria.



Desde el punto de vista del sistema operativo, la máquina virtual es un proceso más. Cuando se inicia, pide al sistema operativo la cantidad de memoria indicada en “Asignación máxima” como memoria RAM para la máquina. El sistema operativo le reserva el espacio de direcciones pero realmente solo le asigna la memoria según va a accediendo a ella. Es decir, que la memoria se asigna a la máquina virtual a demanda.

Si miramos el hardware detectado por nuestro sistema operativo, seguramente veremos un dispositivo desconocido que se corresponde con el dispositivo balón de memoria —en inglés, _balloon device_ — . Para que funcione adecuadamente es necesario instalar en la máquina virtual el controlador `balloon` de la ISO de controladores VirtIO.

Con el controlador del balón de memoria instalado, cuando el sistema operativo arranca, dicho controlador reserva una porción de la memoria de la máquina para que nunca pueda usarse. ¿Cuánta memoria reserva?. La necesaria para que el sistema nunca pueda usar más memoria que la cantidad indicada en “Asignación actual”.

Es decir, que la máquina virtual piensa que la memoria instalada es “Asignación máxima” pero nunca podrá usar más de “Asignación actual” de la memoria del sistema anfitrión.

La cantidad indicada en “Asignación actual” se puede cambiar en tiempo de ejecución desde el anfitrión mediante el comando `virsh`:
`# sudo virsh setmem &lt;máquina_virtual&gt; 2G --live`

Si el nuevo valor es mayor, el balón se encogerá para que el sistema de la máquina virtual pueda consumir más memoria. Obviamente nunca podremos asignar un valor superior a “Asignación máxima”.

Por el contrario, si el nuevo valor es menor, el balón crecerá y devolverá la memoria adicional que reserve al sistema anfitrión, haciendo que haya menos memoria para la máquina virtual.

Si no nos interesa este comportamiento, basta con que no instalemos el controlador del balón de memoria. O que pongamos en “Asignación máxima” y en “Asignación actual” la misma cantidad. Pero hay que tener presente que durante el arranque, Windows pone a ceros toda la memoria de la máquina, haciendo que el sistema anfitrión tenga que asignarle efectivamente la memoria indicada en “Asignación máxima”. El controlador del balón de memoria nos permite obligar a Windows a devolver buena parte de la memoria, hasta lo indicado en “Asignación actual”.

#### Espacio de intercambio en la máquina virtual

En algunos foros se sugiere desactivar el espacio de intercambio —o _swap_ — en el sistema operativo de la máquina virtual. La justificación es que el sistema anfitrión ya tiene su espacio de intercambio donde pueda intercambiar cualquier porción de la memoria, incluida la asignada a las máquinas virtuales.

Pero lo cierto es que nadie mejor que el sistema operativo de la máquina virtual para saber qué partes intercambiar primero, por lo que es mejor que tenga su propio espacio de intercambio.

Al reducir la cantidad de memoria disponible con el _balloon device,_ obligamos al sistema operativo de la máquina virtual a decidir qué partes de la memoria son menos importantes respecto al rendimiento, para liberarlas o intercambiarlas primero.

#### Kernal SamePage Merging (KSM)

En algunos foros se sugiere activar [KSM](https://en.wikipedia.org/wiki/Kernel_same-page_merging) en el sistema Linux anfitrión. KSM es una tecnología creada originalmente para intentar maximizar el número de máquinas virtuales en un mismo equipo. Básicamente consiste en un hilo del núcleo que recorre la memoria buscando regiones con el mismo contenido. Cuando las encuentra, ahorra memoria liberando los duplicados y quedándose solo con una copia.

Por tanto parece una tecnología interesante para evitar que las máquinas virtuales con Windows acaparen demasiada memoria cuando la llenan de ceros durante el arranque. De hecho [Red Hat hizo un experimento](https://kernelnewbies.org/Linux_2_6_32#Kernel_Samepage_Merging_.28memory_deduplication.29) donde pudo lanzar hasta 52 Windows con 1GB en un servidor con tan solo 16GB.

Sin embargo hay que tener presente que recorrer la memoria de esta manera no es gratis. KSM sacrifica tiempo de CPU para maximizar el número de máquinas virtuales. Por eso eso yo no he activado y probado KSM, hasta el momento.

#### Afinidad de los procesadores

Las CPU de la máquina virtual se implementan como hilos de ejecución en el anfitrión. Para mejorar el rendimiento se puede vincular cada uno de esos hilos a una CPU real, evitando que migren de CPU a criterio del sistema, lo que dificulta aprovechar adecuadamente las memorias caché.

Lamentablemente, para configurar esta funcionalidad no podemos usar la interfaz gráfica de usuario de virt-manager. Tenemos que ejecutar:
`# sudo virsh edit &lt;máquina_virtual&gt;`

desde la línea de comandos y modificar el XML —que describe la máquina virtual — a mano para añadir antes de la etiqueta `&lt;os&gt;` lo siguiente:
`&lt;cputune&gt;  
  &lt;vcpupin vcpu=&#39;0&#39; cpuset=&#39;0&#39;/&gt;  
  &lt;vcpupin vcpu=&#39;1&#39; cpuset=&#39;1&#39;/&gt;  
  &lt;vcpupin vcpu=&#39;2&#39; cpuset=&#39;2&#39;/&gt;  
  &lt;vcpupin vcpu=&#39;3&#39; cpuset=&#39;3&#39;/&gt;  
&lt;/cputune&gt;`

_Ojo con olvidarnos de_ `_sudo_` _al ejecutar_ `_virsh_`_. Si nos olvidamos, o el comando falla con el error_ `_error: Domain not found_` _por no encontrar la máquina virtual o acabaremos editando una máquina virtual diferente a la que hemos configurado en virt-manager._

En mi sistema las CPU de la 0 a la 3 corresponde con los núcleo del primero al cuarto. Mientras que las CPU de la 4 a la 7 son hilos de esos mismos núcleos. Como hemos configurado la máquina virtual con 4 núcleos de 1 hilo, vinculamos cada uno de esos 4 núcleos virtuales con uno de los 4 núcleos de la CPU real.

La topología de las CPU reales de nuestros sistema se puede conocer mirando `/proc/cpuinfo` en el sistema anfitrión.

#### Huge Pages

Además se puede indicar que el proceso de la máquina virtual use páginas de memoria de gran tamaño o [_Huge Pages_](https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt). El tamaño de página típico son 4KB pero algunas CPU permiten tamaños superiores —en la familia x86 se admiten páginas de 4KB, 2MB y 1GB, según el modelo de CPU— lo que evita consultar algunos niveles de más en la tabla de página, durante la traducción de las direcciones virtuales y permite consumir menos entradas de la [TLB](https://es.wikipedia.org/wiki/Translation_Lookaside_Buffer).

Para activar su uso, primero hay que editar el XML de la máquina virtual:
`# sudo virsh edit &lt;máquina_virtual&gt;`

y añadir lo siguiente antes de la etiqueta `&lt;os&gt;`:
`&lt;memoryBacking&gt;  
  &lt;hugepages/&gt;  
&lt;/memoryBacking&gt;`

Las _huge pages_ pueden no estar disponibles cuando se necesitan debido a la fragmentación de la memoria. Por eso, si se quieren usar, hay que configurar el sistema para reservar la cantidad necesaria durante el arranque:
`echo &#34;vm.nr_hugepages=2048&#34; | sudo tee /etc/sysctl.d/hugepages.conf`

Donde 2048 páginas de 2MB son 4096MB, suficiente para una máquina virtual de 4GB. Sin embargo hay que tener presente que la memoria reservada no puede ser usada con otro propósito ni puede ser intercambiada. Como mi sistema solo tiene 16GB, yo he optado por no activar el uso de _huge pages_. Obviamente tendría sentido activarlo si dispusiera de mucha más memoria.

### Asignar a la máquina virtual la GPU

Llegados a este punto, antes de continuar, lo primero que deberíamos hacer es [crear un punto de restauración](https://support.microsoft.com/es-es/help/4027538) en Windows. Así, si las cosas se ponen muy mal, no tendremos que volver a empezar desde cero.

Volvemos a la configuración de la máquina virtual, hacemos clic en “+ Agregar hardware” y seleccionamos “Dispositivo PCI anfitrión”. Hay que escoger la tarjeta gráfica que queremos asignar. En mi caso es el dispositivo que dice “0000:01:00:0 NVIDIA Corporation GM206 [Geforce GTX 950]”.




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/14.png)

Añadir la tarjeta gráfica como dispositivo PCI del anfitrión.



Lo mismo se hace con el dispositivo justo debajo —el 0000:01:00:1 — que es la salida de audio digital de la tarjeta gráfica a través del conector HDMI. A fin de cuentas, ambos dispositivos están en la misma tarjeta y no es conveniente asignar uno a la máquina virtual y el otro no.

Yo también hice lo mismo con el dispositivo “0000:05:00:0 ASMedia Technology Inc. ASM1042 SuperSpeed USB Host Controller” para tener puertos USB donde conectar directamente un teclado, un ratón, un _gamepad_ o un _pendrive_; si hiciera falta.

En principio para una tarjeta gráfica AMD esto sería todo. Al iniciar la máquina virtual ya no debería inicializarse en el monitor virtual en virt-manager. En su lugar debemos ver el arranque en el monitor físico conectado a la tarjeta gráfica. Una vez haya arrancado Windows, vamos a la web de fabricante de la GPU, bajamos los controladores para el dispositivo y los instalamos. Es preferible seleccionar el controlador adecuado nosotros mismos antes que utilizar la autodetección, ya que esto último puede dar problemas.

Sin embargo [con Windows 10 algunos usuarios informan de que pueden ser necesarios algunos trucos adicionales](https://ubuntuforums.org/showthread.php?t=2289210). En mi caso intenté una actualización de Windows 8.1 a Windows 10 que no se completaba sino editaba el XML de la máquina virtual
`# sudo virsh edit &lt;máquina_virtual&gt;`

para eliminar toda la etiqueta `&lt;hyperv&gt;` en `&lt;features&gt;` y añadir lo siguiente:
`&lt;kvm&gt;  
  &lt;hidden state=&#39;on&#39;/&gt;  
&lt;/kvm&gt;`

De hecho mi etiqueta `&lt;features&gt;` es así:
`&lt;features&gt;  
  &lt;acpi/&gt;  
  &lt;apic/&gt;  
  &lt;pae/&gt;  
  &lt;kvm&gt;  
    &lt;hidden state=&#39;on&#39;/&gt;  
  &lt;/kvm&gt;  
&lt;/features&gt;`

Cuando se tiene una GPU de NVIDIA hace falta cambiar lo mismo, independientemente de la versión de Windows, para que funcione. También se recomienda buscar la etiqueta `&lt;timer name=’hypervclock’ ... &gt;` dentro de `&lt;clock&gt;` y dejarla así…
`&lt;timer name=&#39;hypervclock&#39; present=&#39;no&#39;`

…o borrarla.

Con estos cambios el arranque debe ocurrir como hemos descrito anteriormente. Después solo tendremos que buscar el controlador adecuado e instalarlo.

#### Activar el uso de Message Signaled Interrupts (MSI)

[MSI](https://en.wikipedia.org/wiki/Message_Signaled_Interrupts) es una alternativa al mecanismo tradicional de señalar las interrupciones mediante líneas dedicadas, que puede proporcionar una pequeña mejora de rendimiento.

Para activar su uso con nuestro tarjeta gráfica, básicamente tenemos que:

1.  Comprobar en el “Administrador de dispositivos” que la tarjeta soporta MSI. Lo más probable es que sí.
2.  Ejecutar `regedit` en Windows, localizar la clave de registro del dispositivo y añadir allí la configuración que activa el uso de MSI para el dispositivo.

Todos los detalles del proceso están perfectamente descritos en el primer mensaje de [este hilo](https://forums.guru3d.com/threads/windows-line-based-vs-message-signaled-based-interrupts.378044/) en un foro.

### Detalles finales

Si todo ha ido bien, ya tenemos una máquina virtual con una GPU real. Como ya no estamos usando el visor de virt-manager, quizás haga falta conectar temporalmente un teclado y un ratón a los puertos USB reales que le hemos asignado.

#### Teclado y ratón compartido

Eso de tener dos teclados no es muy práctico a largo plazo, por lo que utilizo [Synergy](https://symless.com/synergy) para compartir el teclado y el ratón del anfitrión con la máquina virtual. También permite compartir el portapapeles entre ambos sistemas.

En `conf/synergy.conf` dentro de mi repositorio hay un ejemplo de mi configuración de Synergy:

[aplatanado/virtual-desktop](https://github.com/aplatanado/virtual-desktop)


Synergy hace que al llegar al borde derecho de mi monitor en el sistema anfitrión, este aparezca por la izquierda en el monitor de la máquina virtual.

Este comportamiento a veces da problemas con juegos o con herramientas de edición 3D. Para esos casos he configurado la combinación de teclas Alt+W para que al pulsarla se confine el ratón al escritorio del sistema en el que esté en ese momento. Así el ratón y la entrada de teclado no puede cambiar de un sistema a otro por error.

Synergy usa la red para conectar servidor y cliente, pero al usar “macvtap”, anfitrión y máquina virtual no pueden verse Por eso he añadido a la máquina virtual una nueva red virtual privada que solo la conecta con el anfitrión. Es a través de esa red aislada por la que conecta el cliente con el servidor de Synergy

#### Monitor compartido

En mi caso no tengo un monitor para cada sistema. Tengo dos para ambos. La gráfica integrada se conecta a ellos mediante salidas DVI, mientras que la gráfica asignada a la máquina virtual utiliza las salidas HDMI. Cambiando la entrada que me interesa en cada monitor, puedo elegir si quiero ver el escritorio de la máquina virtual o del anfitrión.

Tengo en mente un proyecto para poder hacer eso utilizando combinaciones de teclas, evitando usar los incómodos controles de los monitores. Pero ya veremos si algún día me pongo a ello ;)

#### Sonido

El sonido es seguramente el aspecto con el que menos satisfecho estoy. Después de probar muchas alternativas, creo que las mejores opciones son:

*   **Conectar directamente una tarjeta de sonido o unos auriculares** en un puerto USB asignado a la máquina virtual por _PCI Passthrough_. Sin duda es así como se consigue la mejor calidad de sonido. También sirve la salida de audio HDMI de la tarjeta gráfica asignada. Se puede escuchar por los altavoces del monitor —si los tiene — o conectar algunos por la salida de audio, que los monitores suelen traer. Si no queremos tener dos parejas de altavoces, una para cada sistema, ni estar conectando y desconectado cables según nos interese, podemos comprar un mezclador barato para combinar ambas salidas de audio y tener solo unos altavoces conectados.
*   **Usar una tarjeta de sonido virtual de red**, como la del proyecto [Stream](https://github.com/duncanthrax/scream). La idea de la tarjeta virtual de red es instalar en Windows un controlador de dispositivo de tarjeta de sonido que realmente envíe el audio por red a otro equipo para su reproducción. En ese sentido, el proyecto Stream proporciona tanto los controladores para Windows como el servidor para Linux. El resultado es bastante bueno, prácticamente sin distorsiones ni latencia.
*   **Añadir un dispositivo de sonido emulado a la máquina virtual** y que QEMU haga el resto. Esta es la solución típica. Necesita muchos ajustes y al final el resultado no es muy satisfactorio. Pero voy a explicar como lo he configurado yo.

Primero hay que añadir un dispositivo de sonido a la máquina virtual. En mi caso, tras varias pruebas, he dejado el modelo ICH9, que es bastante moderno y funciona perfectamente.

Luego hay que indicar a QEMU como reproducir en el anfitrión el sonido del dispositivo emulado. Simplemente editamos el XML de la máquina virtual:
`# sudo virsh edit &lt;máquina_virtual&gt;`

y añadimos lo siguiente al final:
`&lt;qemu:commandline&gt;  
  &lt;qemu:env name=&#39;QEMU_AUDIO_DRV&#39; value=&#39;pa&#39;/&gt;  
  &lt;qemu:env name=&#39;QEMU_PA_SERVER&#39; value=&#39;127.0.0.1&#39;/&gt;  
  &lt;qemu:env name=&#39;QEMU_PA_SAMPLES&#39; value=&#39;1024&#39;/&gt;  
&lt;/qemu:commandline&gt;`

Esto hace que QEMU use el servidor pulseaudio del anfitrión para reproducir el sonido, al igual que el resto de aplicaciones de Linux.

El valor de `QEMU_PA_SAMPLES` permite controlar el tamaño del buffer de muestras. Con valores muy altos, se consigue una calidad similar a la que se obtiene con Stream, al menos durante los primeros minutos. Pero el retardo es excesivo, haciendo imposible ver un vídeo. Con 1024 el retardo es inapreciable, pero la calidad del sonido no es tan alta.

Por defecto pulseaudio no acepta conexiones de red por TCP. Para resolverlo hay que editar `/etc/pulse/default.pa` y descomentar la línea del módulo `module-native-protocol-tcp` y que quede así:
`load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1`

Por defecto, si tenemos activado el monitor virtual VNC, libvirt ignorará lo indicado en QEMU_AUDIO_DRV para redirigir todo el sonido por VNC, tanto si el cliente VNC sabe reproducir el audio como si no es así. Es necesario editar `/etc/libvirt/qemu.conf` y asegurarnos que la siguiente línea está descomentada y aparece así:
`vnc_allow_host_audio = 1`

para que libvirt haga siempre lo indicado por QEMU_AUDIO_DRV.

Por último, hay que indicar a Windows que la frecuencia de muestreo por defecto del dispositivo de audio es 44100Hz, que es la frecuencia de muestro por defecto en Linux. El valor por defecto en Windows es 48000Hz. Si la frecuencia de muestro en Windows y en Linux no coincide, oiremos los sonidos distorsionados. Los pasos son:




![image](/posts/2019-09-18_iommu-virtualizando-windows-10/images/15.png)

Configuración de la frecuencia de muestreo en Windows 10.



1.  En la máquina virtual hay que buscar el icono del altavoz en la bandeja del sistema, hacer clic con el botón derecho del ratón y seleccionar “Abrir Configuración de sonido”.
2.  Hacer clic en “Panel de control de sonido”.
3.  En “Reproducción” seleccionar “Altavoces (High Definition Audio Device)” y luego hacer clic en propiedades.
4.  Hacer clic en la pestaña “Opciones avanzadas”.
5.  Hacer clic en la lista de selección y escoger “16 bit, 44100 Hz (Calidad de CD)”.
6.  Aplicar y salir.

Y ya solo queda reproducir algo para ver como suena. En mi caso el sonido va acompañado a ratos de unos clics. Dependiendo de para qué vayamos a usar la máquina virtual, es posible que nos interese probar otra solución de las comentadas.
