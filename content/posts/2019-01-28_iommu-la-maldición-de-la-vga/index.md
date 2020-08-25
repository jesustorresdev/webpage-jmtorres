---
title: "IOMMU: La maldición de la VGA"
author: "Jesús Torres"
#date: 2019-01-28T07:01:01.105Z

license: "CC-BY-4.0"

tags:
 - Linux
 - Virtualización

series:
 - virtual-desktop

featuredImage: "images/featured.jpg" 
images:
 - "images/1.jpg" 
 - "images/2.png" 
 - "images/3.jpg" 

aliases:
 - "/iommu-la-maldición-de-la-vga-cb016e0385a7"
---

_Voy a explicar el problema con las gráficas integradas Intel (IGD) y las gráficas discretas antiguas que no soportan UEFI cuando se intenta crear un escritorio virtual_
_Este artículo corresponde a una serie donde se explica como montar un sistema de escritorio virtualizado, asignándole una GPU de forma exclusiva para obtener un rendimiento similar al de un sistema no virtualizado._
_Si te has perdido la parte anterior, la tienes [aquí]({{< ref "/posts/2015-10-06_iommu-primer-asalto" >}})._

____

## El estándar VGA

VGA es un estándar gráfico diseñado en 1987 y que aun hoy se sigue utilizando en PC.
El estándar contempla muchas aspectos, pero para nosotros lo más relevante es cómo prevé que el resto del sistema tenga acceso a la tarjeta gráfica.


{{< figure src="images/1.jpg" caption="Conector VGA --- Swift.Hg, [Licencia CC-BY-SA-3.0](https://commons.wikimedia.org/wiki/File:Male_VGA_connector.jpg)" >}}


Toda tarjeta gráfica VGA tiene cierta cantidad de memoria de vídeo (VRAM).
Esta memoria se asigna a la memoria del ordenador en una ventana de direcciones que va desde `0xA0000` a `0xBFFFF`.
Es decir, que cuando la CPU accede a esas posiciones de la memoria del sistema realmente está accediendo a la memoria de vídeo de la tarjeta gráfica y no a la memoria RAM.
Lamentablemente, con ese rango solo se pueden direccionar 128KB, que además se reparten entre regiones para modos gráficos, modos texto y compatibilidad con estándares anteriores.
Por lo tanto, ese rango de direcciones era suficiente para los 640x480 y 16 colores originales del estándar VGA, pero es insuficiente para direccionar la memoria de las tarjetas gráficas modernas, que suelen venir con varios GB.

Las tarjetas gráficas también traen una memoria ROM con la Video BIOS (VBIOS) que no es sino un programa que debe ejecutarse durante el arranque del ordenador para iniciar la tarjeta correctamente.
Este código es propio de cada fabricante para cada tarjeta.
Por lo general se le asigna el rango de direcciones de `0xC0000` a `0xC7FFF` de la memoria del sistema.
El objeto de esto es que durante el arranque la BIOS del sistema ejecute el código de la VBIOS ---accesible en el rango de direcciones indicado--- para iniciar la tarjeta gráfica VGA y que así se pueda utilizar desde las primeras fases del arranque para mostrar información por la pantalla.

## Tarjetas gráficas modernas

Las tarjetas gráficas modernas en buses PCI y PCIe son mucho más potentes que las antiguas tarjetas gráficas del estándar VGA, pero mantienen la compatibilidad hacia atrás.

{{< figure src="images/2.png" caption="Mapa de memoria del sistema." >}}

Durante el arranque, a las tarjetas gráficas modernas se les asigna un rango de direcciones más grande para poder acceder a su memoria de vídeo.
Sin embargo, también se les asigna el rango de `0xA0000` a `0xC0000` y la VBIOS también se mapea en la memoria.
Así la BIOS del sistema se puede hacer cargo de iniciar la tarjeta gráfica durante las primeras fases del arranque.
Y la tarjeta puede utilizarse por la BIOS, el gestor de arranque y hasta por el propio sistema operativo como una VGA convencional, hasta que este último carga los controladores de dispositivo correspondientes.
A partir de ese instante la interfaz VGA prácticamente deja utilizarse, ya que los controladores tienen acceso a todo el rango de direcciones asignado a la tarjeta y con eso a la interfaz específica que el fabricante haya preparado para acceder al dispositivo.

## Cuando hay más de una tarjeta gráfica

En un sistema moderno, una vez todo el sistema operativo ha terminado de arrancar, no es problema utilizar varias tarjetas gráficas a la vez.
A fin de cuentas cada una es un dispositivo diferente con su propio rango de direcciones y sus propios controladores.

El conflicto surge en las primeras fases del arranque, cuando ambas se comportan como tarjetas VGA que escuchan en el mismo rango de direcciones de la memoria principal.
Por suerte, en los sistemas con buses PCI y PCIe se puede controlar qué tarjeta en cada momento es accesible a través de la interfaz VGA.

Durante el arranque, la BIOS selecciona una de las tarjetas gráficas como principal y le asigna a la interfaz VGA.
Esa tarjeta es iniciada y el proceso se desarrolla como hemos comentado anteriormente.
Una vez el sistema operativo ha cargado su controlador de dispositivo y ya no necesita más la vieja interfaz VGA, estas direcciones son asignadas a la tarjeta no principal, para iniciarla mediante su VBIOS, y luego cargar sus controladores de dispositivo, momento a partir del cuál tampoco necesitará la interfaz VGA nunca más.

Hay que señalar que las tarjetas gráficas más actuales, aparte de soportar esta forma compatible con las BIOS de mapear su VBIOS e iniciarse, también soportan un modo más flexible, compatible con UEFI, que no necesita que se le asigne al código de la VBIOS de la tarjeta un rango fijo de direcciones de la memoria principal por debajo del primer MB.
De esta manera se simplifican mucho las cosas cuando se quieren utilizar simultáneamente varias tarjetas gráficas, por que ya no es necesario utilizar con ellas la vieja interfaz del estándar VGA, ni siquiera durante el arranque para iniciarlas.

El proceso descrito es muy similar si la segunda gráfica no es usada en el mismo sistema anfitrión, sino que es asignada directamente a una máquina virtual para que la use directamente.
Este es el caso que nos interesa para virtualizar el escritorio.

Incluso es posible arrancar múltiples máquinas virtuales al mismo tiempo, cada una con su propia tarjeta gráfica.
Porque aunque todas necesiten utilizar el mismo rango de direcciones de la interfaz VGA, el sistema se encarga de evitar conflictos a través de lo que se llama el arbitraje VGA.
Este componente del sistema anfitrión asigna el rango de direcciones VGA a una tarjeta o a la otra según se detecten intentos de acceso desde las máquinas virtuales, garantizando el acceso exclusivo de cada máquina virtual a su tarjeta a través del rango compartido de direcciones de la interfaz VGA, mientras sea necesario.

Vistas toda estas particularidades, parece vidente que, tal y como comentamos en [la primera parte]({{< ref "/posts/2015-10-06_iommu-primer-asalto" >}}), el _PCI passthrough_ de tarjetas gráficas es bastante más complejo que el de otro tipo de dispositivos.
Aun así, con el soporte adecuado por parte de la CPU y del software de virtualización, no deberíamos tener problema para tener varias tarjetas gráficas discretas y asignarlas a nuestras máquinas virtuales.

## Gráficas integradas Intel

El problema viene si queremos aprovechar la gráfica integrada Intel (IGD) que probablemente venga con nuestra placa madre.
Seguramente no nos sirva para tener un escritorio para jugar a juegos recientes, pero si para otras actividades.

El arbitraje VGA tiene varias opciones para evitar que una tarjeta reclame una transacción en el rango de direcciones de la interfaz VGA:

* Desactivar el uso de este rango a través de algún mecanismo interno de la propia tarjeta.
* Desactivar el acceso del dispositivo al bus PCI o PCIe.

Lamentablemente, la capacidad de desactivar el rango de la interfaz VGA no funciona o ha sido eliminado de las IGD.
El único mecanismo posible para evitar conflictos, es desactivar el acceso del dispositivo al bus.
Pero eso también desactiva el acceso a través del resto del rango de direcciones asignado al dispositivo y los controladores no pueden hacer su trabajo si el acceso al dispositivo se mantiene desactivado permanente.

{{< figure src="images/3.jpg" caption="Por lo tanto las IGD no pueden asignarse a ninguna máquina virtual." >}}

Solo se pueden aprovechar como gráfica del sistema operativo anfitrión.
Y, además, como acaparan el rango de direcciones VGA, es importante que las gráficas discretas asignadas a las máquinas virtuales no utilicen en ningún momento dicho rango.
Por eso, en este caso particular, es necesario que las máquinas virtuales arranquen con UEFI ---en lugar de con BIOS--- y que las tarjetas gráficas tenga soporte UEFI, permitiendo así que la inicialización de la tarjeta se realice sin recurrir al estándar VGA.

Con esto aclarado, en futuras partes veremos como configurar un sistema de escritorio virtual con una GPU discreta, usando la IGD para el sistema anfitrión y empleado con _QEMU/KVM_ y _libvirt_.

_(Parte 3, [aquí]({{< ref "/posts/2019-09-18_escritorio-virtual-de-windows-10-parte-1" >}}))_