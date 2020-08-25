---
title: "Escritorio virtual de Windows 10 (y II)"
author: "Jesús Torres"
#date: 2019-09-18T21:36:51.827Z

license: "CC-BY-4.0"

tags:
 - Linux
 - Virtualización

series:
 - virtual-desktop

images:
 - "images/12.png"
 - "images/13.png"
 - "images/14.png"
 - "images/15.png"
---

_Vamos a ver algunos consejos para optimizar la máquina virtual creada en el [artículo anterior]({{< ref "/posts/2019-09-18_escritorio-virtual-de-windows-10-parte-1" >}})._
_Este artículo pertenece a una serie donde se explica como instalar Windows 10 en una máquina virtual asignándole una de las GPU del equipo de forma exclusiva, para obtener un rendimiento gráfico similar al que tendría en una máquina real._
_Si te has perdido algún artículo anterior de esta historia, el primero lo tienes [aquí]({{< ref "/posts/2015-10-06_iommu-primer-asalto" >}})_.

___

Una vez apagada la máquina virtual, si seleccionamos en el menú el icono con una exclamación ---con el texto de ayuda {{< gui "Mostrar detalles del hardware virtual" >}}--- podemos ver la configuración definitiva y ajustarla.

{{< figure src="images/12.png" caption="Hardware de la máquina virtual tras la instalación." >}}

Podemos quitar las unidades CDROM o, en todo caso, dejar solo una por lo que pueda surgir.
También se puede quitar el dispositivo tipo {{< gui "Serial" >}} y añadir uno de tipo {{< gui "Tableta" >}}.
La tableta nos permite evitar problemas con el posicionamiento del puntero y usar el ratón con la pantalla de la máquina virtual sin antes tener que hacer clic.

Si hemos dejado una unidad CDROM, podemos cambiar su {{< gui "Bus de disco" >}} a {{< gui SCSI >}}.
Eso nos permite eliminar también los dispositivos {{< gui "Controller IDE" >}}.

## Rendimiento del almacenamiento

En las {{< gui "Opciones de Rendimiento" >}} del {{< gui "SCSI Disco" >}} se puede indicar el {{< gui "Modo caché">}} como {{< gui "none" >}} y el {{< gui "Modo E/S" "+" >}} como {{< gui "native" >}}.

El primero evita que el anfitrión consuma memora cacheando las operaciones de E/S de la máquina virtual.
Esto también lo hace el sistema operativo de la máquina virtual, por lo que no tiene sentido hacerlo dos veces.
Quizás fuera útil si pensáramos lanzar varias máquinas virtuales que accedan al mismo tiempo a los mismos dispositivos de almacenamiento.

El segundo activa el uso de [llamadas al sistema nativas de Linux para la E/S asíncrona](https://blog.cloudflare.com/io_submit-the-epoll-alternative-youve-never-heard-about/) al archivo con el contenido del disco duro virtual.
El valor por defecto usa hilos y operaciones síncronas.

La combinación de estas dos opciones debería ofrecernos mejor rendimiento que las opciones por defecto.

Dentro de la máquina virtual, en el intérprete de comandos de Windows, es interesante ejecutar este comando:

```
> fsutil behavior query DisableDeleteNotify
```

Si devuelve 0, nos indica que cuando un bloque del almacenamiento deja de usarse, Windows envía al dispositivo el comando TRIM para indicarle que ha quedado libre.

Si estamos usando una imagen de disco en formato {{< gui "raw" >}}, esto no tendrá ningún efecto. Pero con {{< gui "qcow2" >}} el archivo reducirá su tamaño, al necesitar menos espacio para almacenar la imagen.
Si usamos un volumen lógico LVM sobre un dispositivo SSD, como es mi caso, el comando TRIM se propagará hasta el SSD, evitando la degradación del rendimiento del dispositivo.

Si hiciera falta, para activarlo hay que ejecutar:

```
> fsutil behavior set DisableDeleteNotify 0
```

## Rendimiento de la interfaz de red

La tarjeta de red de la máquina virtual es el dispositivo con el nombre {{< gui "NIC <MAC>" >}}.
Por lo general se trata de una emulación de una tarjeta Intel e1000 o una [Realtek RTL8139](https://es.wikipedia.org/wiki/Realtek).
Se puede obtener mejor rendimiento cambiando el {{< gui "Modelo de dispositivo" >}} a {{< gui "virtio" >}}, que es una interfaz de red paravirtualizada, como la que usamos con el disco duro virtual.
Lo único es que es necesario iniciar la máquina virtual e instalar los controladores de la carpeta `NetKVM` de la ISO de controladores VirtIO.

Por defecto la interfaz de red de la máquina virtual está conectada a una red virtual llamada "default", en la que también está el equipo anfitrión.
En esta red la máquina virtual recibe una IP privada y su acceso a Internet se realiza a través del anfitrión usando [NAT](https://es.wikipedia.org/wiki/Traducci%C3%B3n_de_direcciones_de_red).

Todo esto se puede simplificar mucho cambiando {{< gui "Fuente de red" >}} a {{< gui "Dispositivo anfitrión <interfaz>: macvtap" >}} y {{< gui "Modo de fuente" >}} a {{< gui "Puente" >}}.
Usando [macvtap](https://virt.kernelnewbies.org/MacVTap) la máquina virtual pasa a algo así como a compartir la la tarjeta de red "<interfaz>" del equipo anfitrión.
La red le asignará a la máquina virtual una IP como si fuera una máquina real y de esta forma puede conectarse al resto de equipos de la red y a Internet sin usa al anfitrión como intermediario.

En mi caso, al usar _macvtap_ en Ubuntu 16.04, la interfaz de red funcionaba en el primer arranque pero nunca en posteriores. 
Se debía a un conflicto con _NetworkManager_, que decidía por su cuenta bajar la interfaz _macvtap_ anfitrión.
Se resuelve editando el archivo `/etc/NetworkManager/NetworkManager.conf` para añadir lo siguiente:

{{< highlight ini >}}
[keyfile]  
unmanaged-devices=interface-name:macvtap0
{{< / highlight >}}

para que _NetworkManager_ no intente gestionar esa interfaz.
En Ubuntu 18.04, por el momento no he tenido ningún problema similar, así que no parece que haga falta este truco.

## QXL

En el dispositivo {{< gui "Video Cirrus" >}} se puede cambiar el modelo a {{< gui QXL >}}.
El modelo {{< gui "Video Cirrus" >}} emula una tarjeta gráfica VGA del fabricante Cirrus Logic.
Mientras que QXL es un dispositivo de vídeo paravirtualizado, por lo que ofrece mejor rendimiento. 
Además, mientras que con la emulación VGA estamos limitados a una resolución 800x600, con QXL tenemos automáticamente 1024x768.
Será necesario iniciar la máquina virtual e instalar los controladores de la carpeta `qxldod` de la ISO de controladores VirtIO.

## Asignación de memoria RAM

En la configuración de memoria podemos configurar cuánta memoria pensará la máquina virtual que tiene ---la {{< gui "Asignación máxima" >}}--- y cuanta memoria del anfitrión puede realmente usar como máximo ---la {{< gui "Asignación actual" >}}---.

Por ejemplo, mi máquina virtual piensa que tiene 8GB de RAM pero el sistema anfitrión nunca le asignará más de 4GB de memoria.

{{< figure src="images/13.png" caption="Configuración de la asignación de memoria." >}}

Desde el punto de vista del sistema operativo, la máquina virtual es un proceso más.
Cuando se inicia, pide al sistema operativo la cantidad de memoria indicada en {{< gui "Asignación máxima">}} como memoria RAM para la máquina.
El sistema operativo le reserva el espacio de direcciones pero realmente solo le asigna la memoria según va a accediendo a ella. 
Es decir, que la memoria se asigna a la máquina virtual a demanda.

Si miramos el hardware detectado por nuestro sistema operativo, seguramente veremos un dispositivo desconocido que se corresponde con el dispositivo balón de memoria ---en inglés, _balloon device_---.
Para que funcione adecuadamente es necesario instalar en la máquina virtual el controlador `balloon` de la ISO de controladores VirtIO.

Con el controlador del balón de memoria instalado, cuando el sistema operativo arranca, dicho controlador reserva una porción de la memoria de la máquina para que nunca pueda usarse.
¿Cuánta memoria reserva?.
La necesaria para que el sistema nunca pueda usar más memoria que la cantidad indicada en {{< gui "Asignación actual" >}}.

Es decir, que la máquina virtual piensa que la memoria instalada es {{< gui "Asignación máxima" >}} pero nunca podrá usar más de {{< gui "Asignación actual" >}} de la memoria del sistema anfitrión.

La cantidad indicada en "Asignación actual" se puede cambiar en tiempo de ejecución desde el anfitrión mediante el comando `virsh`:

```
$ sudo virsh setmem <máquina_virtual> 2G --live
```

Si el nuevo valor es mayor, el balón se encogerá para que el sistema de la máquina virtual pueda consumir más memoria.
Obviamente nunca podremos asignar un valor superior a {{< gui "Asignación actual" >}}.

Por el contrario, si el nuevo valor es menor, el balón crecerá y devolverá la memoria adicional que reserve al sistema anfitrión, haciendo que haya menos memoria para la máquina virtual.

Si no nos interesa este comportamiento, basta con que no instalemos el controlador del balón de memoria. 
O que pongamos en {{< gui "Asignación máxima" >}} y en {{< gui "Asignación actual" >}} la misma cantidad.
Pero hay que tener presente que durante el arranque, Windows pone a ceros toda la memoria de la máquina, haciendo que el sistema anfitrión tenga que asignarle efectivamente la memoria indicada en "Asignación máxima".
El controlador del balón de memoria nos permite obligar después a Windows a devolver buena parte de la memoria, hasta lo indicado en {{< gui "Asignación actual" >}}.

## Espacio de intercambio en la máquina virtual

En algunos foros se sugiere desactivar el espacio de intercambio ---o _swap_ --- en el sistema operativo de la máquina virtual.
La justificación es que el sistema anfitrión ya tiene su espacio de intercambio donde pueda intercambiar cualquier porción de la memoria, incluida la asignada a las máquinas virtuales.

Pero lo cierto es que nadie mejor que el sistema operativo de la máquina virtual para saber qué partes intercambiar primero, por lo que es mejor que tenga su propio espacio de intercambio.

Al reducir la cantidad de memoria disponible con el _balloon device_, obligamos al sistema operativo de la máquina virtual a decidir qué partes de la memoria son menos importantes respecto al rendimiento, para liberarlas o intercambiarlas primero.

## Kernal SamePage Merging (KSM)

En algunos foros se sugiere activar [KSM](https://en.wikipedia.org/wiki/Kernel_same-page_merging) en el sistema Linux anfitrión.
KSM es una tecnología creada originalmente para intentar maximizar el número de máquinas virtuales en un mismo equipo.
Básicamente consiste en un hilo del núcleo que recorre la memoria buscando regiones con el mismo contenido.
Cuando las encuentra, ahorra memoria liberando los duplicados y quedándose solo con una copia.

Por tanto parece una tecnología interesante para evitar que las máquinas virtuales con Windows acaparen demasiada memoria cuando la llenan de ceros durante el arranque.
De hecho [Red Hat hizo un experimento](https://kernelnewbies.org/Linux_2_6_32#Kernel_Samepage_Merging_.28memory_deduplication.29) donde pudo lanzar hasta 52 Windows con 1GB en un servidor con tan solo 16GB.

Sin embargo hay que tener presente que recorrer la memoria de esta manera no es gratis.
KSM sacrifica tiempo de CPU para maximizar el número de máquinas virtuales.
Por eso eso yo no he activado y probado KSM, hasta el momento.

## Afinidad de los procesadores

Las CPU de la máquina virtual se implementan como hilos de ejecución en el anfitrión.
Para mejorar el rendimiento se puede vincular cada uno de esos hilos a una CPU real, evitando que migren de CPU a criterio del sistema, lo que dificulta aprovechar adecuadamente las memorias caché.

Lamentablemente, para configurar esta funcionalidad no podemos usar la interfaz gráfica de usuario de _virt-manager_. Tenemos que ejecutar:

```
$ sudo virsh edit <máquina_virtual>
```

desde la línea de comandos y modificar el XML ---que describe la máquina virtual --- a mano para añadir antes de la etiqueta `<os>` lo siguiente:

{{< highlight xml >}}
<cputune>  
  <vcpupin vcpu='0' cpuset='0'/>  
  <vcpupin vcpu='1' cpuset='1'/>  
  <vcpupin vcpu='2' cpuset='2'/>  
  <vcpupin vcpu='3' cpuset='3'/>  
</cputune>
{{< / highlight >}}

{{< admonition  warning "Ojo con olvidarnos de sudo" >}}
Si nos olvidamos de `sudo` al ejecutar `virsh`, o el comando falla con el error `error: Domain not found` por no encontrar la máquina virtual o acabaremos editando una máquina virtual diferente a la que hemos configurado en virt-manager.
{{< / admonition >}}

En mi sistema las CPU de la 0 a la 3 corresponde con los núcleo del primero al cuarto.
Mientras que las CPU de la 4 a la 7 son hilos de esos mismos núcleos.
Como hemos configurado la máquina virtual con 4 núcleos de 1 hilo, vinculamos cada uno de esos 4 núcleos virtuales con uno de los 4 núcleos de la CPU real.

La topología de las CPU reales de nuestros sistema se puede conocer mirando `/proc/cpuinfo` en el sistema anfitrión.

## Huge Pages

Además se puede indicar que el proceso de la máquina virtual use páginas de memoria de gran tamaño o [_huge pages_](https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt).
El tamaño de página típico son 4KB pero algunas CPU permiten tamaños superiores ---en la familia x86 se admiten páginas de 4KB, 2MB y 1GB, según el modelo de CPU--- lo que evita consultar algunos niveles de más en la tabla de página, durante la traducción de las direcciones virtuales y permite consumir menos entradas de la [TLB](https://es.wikipedia.org/wiki/Translation_Lookaside_Buffer).

Para activar su uso, primero hay que editar el XML de la máquina virtual:

```
sudo virsh edit <máquina_virtual>
```

y añadir lo siguiente antes de la etiqueta `<os>`:

{{< highlight xml >}}
<memoryBacking>  
  <hugepages/>  
</memoryBacking>
{{< / highlight >}}

Las _huge pages_ pueden no estar disponibles cuando se necesitan debido a la fragmentación de la memoria. 
Por eso, si se quieren usar, hay que configurar el sistema para reservar la cantidad necesaria durante el arranque:

```
$ echo "vm.nr_hugepages=2048" | sudo tee /etc/sysctl.d/hugepages.conf
```

Donde 2048 páginas de 2MB son 4096MB, suficiente para una máquina virtual de 4GB.
Sin embargo hay que tener presente que la memoria reservada no puede ser usada con otro propósito ni puede ser intercambiada.
Como mi sistema solo tiene 16GB, yo he optado por no activar el uso de _huge pages_.
Obviamente tendría sentido activarlo si dispusiera de mucha más memoria.

## Asignar a la máquina virtual la GPU

Llegados a este punto, antes de continuar, lo primero que deberíamos hacer es [crear un punto de restauración](https://support.microsoft.com/es-es/help/4027538) en Windows.
Así, si las cosas se ponen muy mal, no tendremos que volver a empezar desde cero.

Volvemos a la configuración de la máquina virtual, hacemos clic en {{< gui "+ Agregar hardware" >}} y seleccionamos {{< gui "Dispositivo PCI anfitrión" >}}. Hay que escoger la tarjeta gráfica que queremos asignar.
En mi caso es el dispositivo que dice {{< gui "0000:01:00:0 NVIDIA Corporation GM206 [Geforce GTX 950]" >}}.

{{< figure src="images/14.png" caption="Añadir la tarjeta gráfica como dispositivo PCI del anfitrión." >}}

Lo mismo se hace con el dispositivo justo debajo ---el `0000:01:00:1` --- que es la salida de audio digital de la tarjeta gráfica a través del conector HDMI. 
A fin de cuentas, ambos dispositivos están en la misma tarjeta y no es conveniente asignar uno a la máquina virtual y el otro no.

Yo también hice lo mismo con el dispositivo {{< gui "0000:05:00:0 ASMedia Technology Inc. ASM1042 SuperSpeed USB Host Controller" >}} para tener puertos USB donde conectar directamente un teclado, un ratón, un _gamepad_ o un _pendrive_; si hiciera falta.

En principio para una tarjeta gráfica AMD esto sería todo.
Al iniciar la máquina virtual ya no debería inicializarse en el monitor virtual en _virt-manager_.
En su lugar debemos ver el arranque en el monitor físico conectado a la tarjeta gráfica.
Una vez haya arrancado Windows, vamos a la web de fabricante de la GPU, bajamos los controladores para el dispositivo y los instalamos.
Es preferible seleccionar el controlador adecuado nosotros mismos antes que utilizar la autodetección, ya que esto último puede dar problemas.

Sin embargo [con Windows 10 algunos usuarios informan de que pueden ser necesarios algunos trucos adicionales](https://ubuntuforums.org/showthread.php?t=2289210).
En mi caso intenté una actualización de Windows 8.1 a Windows 10 que no se completaba sino editaba el XML de la máquina virtual

```
$ sudo virsh edit <máquina_virtual>
```

para eliminar toda la etiqueta `<hyperv>` en `<features>` y añadir lo siguiente:

{{< highlight xml >}}
<kvm>  
  <hidden state='on'/>  
</kvm>
{{< / highlight >}}

De hecho mi etiqueta `<features>` es así:

{{< highlight xml >}}
<features>  
  <acpi/>  
  <apic/>  
  <pae/>  
  <kvm>  
    <hidden state='on'/>  
  </kvm>  
</features>
{{< / highlight >}}

Cuando se tiene una GPU de NVIDIA hace falta cambiar lo mismo, independientemente de la versión de Windows, para que funcione.
También se recomienda buscar la etiqueta `<timer name=’hypervclock’ ... >` dentro de `<clock>` y dejarla así...

{{< highlight xml >}}
<timer name='hypervclock' present='no'>
{{< / highlight >}}

...o borrarla.

Con estos cambios el arranque debe ocurrir como hemos descrito anteriormente.
Después solo tendremos que buscar el controlador adecuado e instalarlo.

## Activar el uso de Message Signaled Interrupts (MSI)

[MSI](https://en.wikipedia.org/wiki/Message_Signaled_Interrupts) es una alternativa al mecanismo tradicional de señalar las interrupciones mediante líneas dedicadas, que puede proporcionar una pequeña mejora de rendimiento.

Para activar su uso con nuestro tarjeta gráfica, básicamente tenemos que:

1. Comprobar en el {{< gui "Administrador de dispositivos" >}} que la tarjeta soporta MSI. Lo más probable es que sí.
1. Ejecutar `regedit` en Windows, localizar la clave de registro del dispositivo y añadir allí la configuración que activa el uso de MSI para el dispositivo.

Todos los detalles del proceso están perfectamente descritos en el primer mensaje de [este hilo](https://forums.guru3d.com/threads/windows-line-based-vs-message-signaled-based-interrupts.378044/) en un foro.

## Detalles finales

Si todo ha ido bien, ya tenemos una máquina virtual con una GPU real.
Como ya no estamos usando el visor de _virt-manager_, quizás haga falta conectar temporalmente un teclado y un ratón a los puertos USB reales que le hemos asignado.

### Teclado y ratón compartido

Eso de tener dos teclados no es muy práctico a largo plazo, por lo que utilizo [_Synergy_](https://symless.com/synergy) para compartir el teclado y el ratón del anfitrión con la máquina virtual.
También permite compartir el portapapeles entre ambos sistemas.

En `conf/synergy.conf` dentro de mi [repositorio}(https://github.com/aplatanado/virtual-desktop) hay un ejemplo de mi configuración de _Synergy_.
_Synergy_ hace que al llegar al borde derecho de mi monitor en el sistema anfitrión, este aparezca por la izquierda en el monitor de la máquina virtual.

Este comportamiento a veces da problemas con juegos o con herramientas de edición 3D. 
Para esos casos he configurado la combinación de teclas {{< kbd "Alt+W" >}} para que al pulsarla se confine el ratón al escritorio del sistema en el que esté en ese momento.
Así el ratón y la entrada de teclado no puede cambiar de un sistema a otro por error.

_Synergy_ usa la red para conectar servidor y cliente, pero al usar _macvtap_, anfitrión y máquina virtual no pueden.
Por eso he añadido a la máquina virtual una nueva red virtual privada que solo la conecta con el anfitrión.
Es a través de esa red aislada por la que conecta el cliente con el servidor de _Synergy_.

### Monitor compartido

En mi caso no tengo un monitor para cada sistema.
Tengo dos para ambos.
La gráfica integrada se conecta a ellos mediante salidas DVI, mientras que la gráfica asignada a la máquina virtual utiliza las salidas HDMI.
Cambiando la entrada que me interesa en cada monitor, puedo elegir si quiero ver el escritorio de la máquina virtual o del anfitrión.

Tengo en mente un proyecto para poder hacer eso utilizando combinaciones de teclas, evitando usar los incómodos controles de los monitores. Pero ya veremos si algún día me pongo a ello :wink:.

### Sonido

El sonido es seguramente el aspecto con el que menos satisfecho estoy. Después de probar muchas alternativas, creo que las mejores opciones son:

* **Conectar directamente una tarjeta de sonido o unos auriculares** en un puerto USB asignado a la máquina virtual por _PCI Passthrough_.
Sin duda es así como se consigue la mejor calidad de sonido. 
También sirve la salida de audio HDMI de la tarjeta gráfica asignada.
Se puede escuchar por los altavoces del monitor ---si los tiene--- o conectar algunos por la salida de audio que los monitores suelen traer.
Si no queremos tener dos parejas de altavoces, una para cada sistema, ni estar conectando y desconectado cables según nos interese, podemos comprar un mezclador barato para combinar ambas salidas de audio y tener solo unos altavoces conectados.
* **Usar una tarjeta de sonido virtual de red**, como la del proyecto {{< github "duncanthrax/scream" >}}.
La idea de la tarjeta virtual de red es instalar en Windows un controlador de dispositivo de tarjeta de sonido que realmente envíe el audio por red a otro equipo para su reproducción.
En ese sentido, el proyecto _scream_ proporciona tanto los controladores para Windows como el servidor para Linux.
El resultado es bastante bueno, prácticamente sin distorsiones ni latencia.
* **Añadir un dispositivo de sonido emulado a la máquina virtual** y que _QEMU_ haga el resto. 
Esta es la solución típica. Necesita muchos ajustes y al final el resultado no es muy satisfactorio. Pero voy a explicar como lo he configurado yo.

Primero hay que añadir un dispositivo de sonido a la máquina virtual.
En mi caso, tras varias pruebas, he dejado el modelo ICH9, que es bastante moderno y funciona perfectamente.

Luego hay que indicar a _QEMU_ como reproducir en el anfitrión el sonido del dispositivo emulado.
Simplemente editamos el XML de la máquina virtual:

```
$ sudo virsh edit <máquina_virtual>
```

y añadimos lo siguiente al final:

{{< highlight xml >}}
<qemu:commandline>  
  <qemu:env name='QEMU_AUDIO_DRV' value='pa'/>  
  <qemu:env name='QEMU_PA_SERVER' value='127.0.0.1'/>  
  <qemu:env name='QEMU_PA_SAMPLES' value='1024'/>  
</qemu:commandline>
{{< / highlight >}}

Esto hace que _QEMU_ use el servidor _pulseaudio_ del anfitrión para reproducir el sonido, al igual que el resto de aplicaciones de Linux.

El valor de `QEMU_PA_SAMPLES` permite controlar el tamaño del buffer de muestras.
Con valores muy altos, se consigue una calidad similar a la que se obtiene con _Scream_, al menos durante los primeros minutos.
Pero el retardo es excesivo, haciendo imposible ver un vídeo. Con 1024 el retardo es inapreciable, pero la calidad del sonido no es tan alta.

Por defecto _pulseaudio_ no acepta conexiones de red por TCP.
Para resolverlo hay que editar `/etc/pulse/default.pa` y descomentar la línea del módulo `module-native-protocol-tcp` y que quede así:

```
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
```

Por defecto, si tenemos activado el monitor virtual VNC, _libvirt_ ignorará lo indicado en `QEMU_AUDIO_DRV` para redirigir todo el sonido por VNC, tanto si el cliente VNC sabe reproducir el audio como si no es así.
Es necesario editar `/etc/libvirt/qemu.conf` y asegurarnos que la siguiente línea está descomentada y aparece así:

```
vnc_allow_host_audio = 1
```

para que _libvirt_ haga siempre lo indicado por `QEMU_AUDIO_DRV`.

Por último, hay que indicar a Windows que la frecuencia de muestreo por defecto del dispositivo de audio es 44100Hz, que es la frecuencia de muestro por defecto en Linux.
El valor por defecto en Windows es 48000Hz.
Si la frecuencia de muestro en Windows y en Linux no coincide, oiremos los sonidos distorsionados. Los pasos son:

{{< figure src="images/15.png" caption="Configuración de la frecuencia de muestreo en Windows 10." >}}

1. En la máquina virtual hay que buscar el icono del altavoz en la bandeja del sistema, hacer clic con el botón derecho del ratón y seleccionar {{< gui "Abrir Configuración de sonido" >}}.
1. Hacer clic en {{< gui "Panel de control de sonido" >}}.
1. En {{< gui "Reproducción" >}} seleccionar {{< gui "Altavoces (High Definition Audio Device)" >}} y luego hacer clic en propiedades.
1. Hacer clic en la pestaña {{< gui "Opciones avanzadas" >}}.
1. Hacer clic en la lista de selección y escoger {{< gui "16 bit, 44100 Hz (Calidad de CD)" >}}.
1. Aplicar y salir.

Y ya solo queda reproducir algo para ver como suena.
En mi caso el sonido va acompañado a ratos de unos clics.
Dependiendo de para qué vayamos a usar la máquina virtual, es posible que nos interese probar otra solución de las comentadas.
