---
title: "Escritorio virtual de Windows 10 (I)"
author: "Jesús Torres"
#date: 2019-09-18T21:36:51.827Z

license: "CC-BY-4.0"

tags:
 - Linux
 - Virtualización

series:
 - virtual-desktop

featuredImage: "images/featured.png"
images:
 - "images/featured.png"
 - "images/2.png"
 - "images/3.png"
 - "images/4.png"
 - "images/5.png"
 - "images/6.png"
 - "images/7.png"
 - "images/8.png"
 - "images/9.png"
 - "images/10.png"
 - "images/11.png"

aliases:
 - "/iommu-virtualizando-windows-10-9afb7c01c358"
---

_Este artículo pertenece a una serie donde se explica como instalar Windows 10 en una máquina virtual asignándole una de las GPU del equipo de forma exclusiva, para obtener un rendimiento gráfico similar al que tendría en una máquina real._
_En esta parte veremos como crear la máquina virtual e instalar Windows 10._
_Si te has perdido algún artículo anterior de esta historia, el primero lo tienes [aquí]({{< ref "/posts/2015-10-06_iommu-primer-asalto" >}}) y el segundo [aquí]({{< ref "/posts/2019-01-28_iommu-la-maldicion-de-la-vga" >}})_.

___

Como he comentado en artículos anteriores, quiero instalar Windows 10 en una máquina virtual sobre Ubuntu 18.04 LTS.
Como estoy interesado en conseguir el máximo rendimiento gráfico en Windows, quiero que la máquina virtual tenga acceso exclusivo a la tarjeta gráfica, dejando para Ubuntu la gráfica integrada de Intel que viene con la placa madre.

Para que esta configuración funcione es necesario:

1. Una CPU y una placa madre con soporte para la tecnología VT-d ---o Intel&reg; Virtualization Technology for Directed I/O, que es el nombre que Intel le da a la tecnología de la IOMMU---.
  En algunos casos hay que activar dicho soporte desde la BIOS / UEFI.

1. Una tarjeta gráfica con una ROM que soporte UEFI. La mía es una Geforce GTX 950, pero cualquier tarjeta gráfica de los últimos años sirve.

## Instalación del software

Para empezar necesitamos _QEMU/KVM_, _Libvirt_, _OVMF_ y _Virtual Machine Manager_:

```
$ sudo apt-get install qemu-kvm ovmf libvirt-clients libvirt-daemon-system bridge-utils virt-manager
```

[_Virtual Machine Manager_](https://virt-manager.org/) (o _virt-manager_) será la aplicación que utilizaremos para configurar y lanzar la máquina virtual.
Básicamente se trata de una aplicación de escritorio para gestionar máquinas virtuales a través de [_libvirt_](https://libvirt.org/), por lo que esta última se instará automáticamente como dependencia del primero.

Para que podamos lanzar máquinas virtuales con _virt-manager_ necesitamos que nuestro usuario esté dentro del grupo `libvirt`.
Podemos añadirlo así:

```
$ sudo adduser $(id -un) libvirt
```

Obviamente tendremos que cerrar la sesión y volver a iniciarla para que el cambio tenga efecto.

Nuestra máquina virtual necesita un [firmware UEFI](https://es.wikipedia.org/wiki/Extensible_Firmware_Interface) para arrancar ---como el de cualquier placa madre real--- por lo que utilizaremos el del proyecto [_OVMF_](https://github.com/tianocore/tianocore.github.io/wiki/OVMF) (siglas de Open Virtual Machine Firmware) que es un firmware UEFI especialmente preparado para máquinas virtuales _QEMU/KVM_.

Desde [el repositorio de Gerd Hoffmann](https://www.kraxel.org/repos/jenkins/edk2/) se puede obtener la última versión compilada de _OVMF_.
De hecho eso fue lo que hice la primera vez, al configurar una máquina virtual de esta manera en una Ubuntu 16.04 LTS.
Sin embargo, actualmente no debería haber ningún problema con la versión de _OVMF_ empaquetada con cualquier distribución moderna, así que nos saltaremos ese paso.

## Activar IOMMU

Lo primero es activar el soporte de [IOMMU]({{< ref "/posts/2015-10-06_iommu-primer-asalto" >}}) en el núcleo.
Para eso editamos `/etc/default/grub` y añadimos `intel_iommu=on` a la variable `GRUB_CMDLINE_LINUX_DEFAULT`.
Después ejecutamos:

```
$ sudo update-grub
```

para actualizar la configuración del gestor de arranque con la nueva opción.

En algunos casos se ha informado de problemas durante el arranque o al reproducir sonido a través del HDMI de la gráfica integrada.
Los efectos pueden ser diversos y diferentes entre sistemas.
Por ejemplo, algunos informes hablan específicamente de problemas al usar el audio HDMI en procesadores de la micro-arquitectura Haswell, pero no siempre se pueden conectar estos problemas con un hardware concreto.

El asunto es que en caso de problemas es buena idea probar a desactivar la IOMMU para la gráfica integrada, utilizando la opción `intel_iommu=on,igfx_off`.
De hecho mi configuración es:

```
GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on,igfx_off quiet splash"
```

Además, se sabe que hay una importante pérdida de rendimiento en los procesador Sandy Bridge al activar IOMMU.
En ese caso se recomienda usar la opción `intel_iommu=pt` en lugar de `intel_iommu=on`.
En la [documentación de Linux](https://www.kernel.org/doc/Documentation/Intel-IOMMU.txt) hay más información sobre la configuración de IOMMU en Intel.

Una vez actualizada la configuración del gestor de arranque, debemos reiniciar el sistema y comprobar que el soporte de IOMMU está activado examinando los registros del sistema:

```
$ journalctl -b | grep DMAR
```

Vamos por el buen camino si en la salida del comando anterior vemos una línea que dice:

```
kernel: DMAR: IOMMU enabled
```

Si hemos usado la opción `igfx_off`, además debe haber otra con lo siguiente:

```
kernel: DMAR: Disable GFX device mapping
```

Si vemos que el soporte de IOMMU no se activa, puede ser que se nos hayamos olvidado activar el soporte de VT-d en la configuración de la BIOS/UEFI de nuestro sistema.
O tal vez nuestra CPU o nuestra placa madre no tengan soporte para VT-d.

## Registro de dispositivos en VFIO

Las aplicaciones de virtualización como _QEMU/KVM_ necesitan acceso al dispositivo que se quiere mapear.
Para hacerlo utilizan las facilidades de [VFIO](https://www.kernel.org/doc/Documentation/vfio.txt), que es un controlador de dispositivo de Linux cuya función es ofrecer a los procesos en modo usuario acceso directo a los dispositivos.
Este tipo de acceso es lo que necesita la aplicación de virtualización, pero también puede ser útil para desarrollar controladores de dispositivo que se ejecuten en modo no privilegiado.

VFIO no puede ofrecer a las aplicaciones acceso a cualquier dispositivo del sistema.
Solo lo hace a aquellos que han sido registrados previamente en VFIO.
Y para que eso sea posible, el dispositivo no puede estar siendo usado por otro controlador.

Pongamos por caso que, como queremos hacer _VGA passthrough_, nos interesa registrar nuestra tarjeta gráfica en VFIO.
Lo primero es obtener la lista de dispositivos, ejecutando el comando:

```
$ lspci -nn
```

El resultado será similar al de la siguiente imagen. La línea marcada corresponde con la tarjeta gráfica, instada en mi ordenador, que quiero usar con la máquina virtual:

{{< figure src="images/2.png" caption="Ejemplo de ejecutar el comando \"lspci -nn\"." >}}

El texto `[10de:1002]` del final de la línea marcada nos indica que el fabricante de esa tarjeta gráfica tiene el identificador `0x10DE` y que el modelo se identifica como `0x1402`.
Así que para registrar esta tarjeta habría que indicarle al controlador VFIO estos identificadores de la siguiente manera:

```
$ echo 10DE 1402 |sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
```

El problema es que esto hay que hacerlo antes de iniciar la máquina virtual y para cada dispositivo que queremos asignarle.
En mi caso no sólo es la tarjeta gráfica, también el dispositivo de audio HDMI de la misma tarjeta ---justo en la línea siguiente--- y un concentrador raíz USB ---el ASM1042 SuperSpeed USB Host Controller--- para poder conectar directamente un teclado y ratón USB, en caso de que hiciera falta.

Además, antes de registrar estos dispositivos en VFIO, hay que deregistrarlos del controlador de dispositivo que Linux le haya asignado para usarlos en el sistema anfitrión.
En el caso particular de las tarjetas gráficas, es incluso mejor descargar el controlador de dispositivo correspondiente, porque no suelen llevar muy bien que les asignen y les quiten dispositivos en caliente durante la ejecución.

Para no hacerlo a mano en cada ocasión, es interesante tener un _hook_ de _libvirt_ que lo haga automáticamente cada vez que se inicia la máquina virtual.

## Instalar el libvirt hook

En el repositorio {{< github "aplatanado/virtual-desktop" >}} he ido poniendo scripts y archivos de configuración relevantes para este proyecto.
Dentro del directorio `libvirt-hooks` está el script `qemu`, que es el _hook_ que se encargará del registro en VFIO durante el arranque de la máquina virtual.

Se puede instalar así:

```
$ sudo install -m755 libvirt-hooks/qemu /etc/libvirt/hooks
```

[_Libvirt_ admite 5 scripts de hook](https://libvirt.org/hooks.html#names).
El script `qemu` se ejecuta cuando libvirt inicia, detiene o migra una máquina virtual de _QEMU_; que es exactamente nuestro caso. 
Eso significa que si tenemos varias máquinas virtuales de QEMU y queremos hacer cosas diferentes para cada una, debemos ponerlo todo en el mismo script `/etc/libvirt/hooks/qemu`.

Del script hay dos funciones a las que merece la pena echar un vistazo. Una es `vfio_bind_devices()` que, dado el identificador de un dispositivo, lo registra en VFIO para hacer _PCI passthrough_.

{{< highlight python "linenos=table,linenostart=24" >}}
def vfio_bind_devices(device_ids):
    """Bind the specified devices to the Linux VFIO driver
    :param device_ids: List of addresses of devices to bind to VFIO.
    :return: Dictionary with information about the device bound.
    """

    vfio_loaded = False
    nvidia_loaded = True

    devices = {}
    for id in device_ids:
        device_path = '/sys/bus/pci/devices/%s' % id
        try:
            device_driver = os.path.basename(os.readlink(device_path + '/driver'))
        except OSError:
            device_driver = None

        # Ignore devices already bound to VFIO driver because the system crashes sometimes after
        # a few bind/unbind cycles
        if device_driver != 'vfio-pci':
            device_info = {
                'path': device_path,
                'driver': device_driver
            }
            with open(device_path + '/vendor', 'r') as f:
                device_info['vendor'] = f.read()
            with open(device_path + '/device', 'r') as f:
                device_info['model'] = f.read()
            devices[id] = device_info
        else:
            vfio_loaded = True

    # Load vfio-pci module, if needed
    if not vfio_loaded and devices:
        subprocess.check_call(['modprobe', 'vfio-pci'])

    for id, device_info in devices.iteritems():
        # Unbind the device if it is bound to other driver
        if device_info['driver'] is not None:

            # Unload the NVIDIA driver instead of unbind the device
            if device_info['driver'] == 'nvidia':

                # Hotplug support of graphics card isn't good. Further, I guess that question 9 applies here:
                # http://vfio.blogspot.com.es/2014/08/vfiovga-faq.html
                # The driver locks the VGA arbiter, freezing the VM on its first access to VGA resources.

                # That shouldn't happen but...
                # https://bbs.archlinux.org/viewtopic.php?pid=1508940#p1508940
                if nvidia_loaded:
                    subprocess.call(['rmmod', 'nvidia_drm'])
                    subprocess.call(['rmmod', 'nvidia_modeset'])
                    subprocess.call(['rmmod', 'nvidia_uvm'])
                    subprocess.check_call(['rmmod', 'nvidia'])
                    nvidia_loaded = False
            else:
                with open(device_info['path'] + '/driver/unbind', 'w') as f:
                    f.write(id)

        # Bind the device to VFIO driver
        with open('/sys/bus/pci/drivers/vfio-pci/new_id', 'w') as f:
            f.write("%s %s" % (device_info['vendor'], device_info['model']))

    return devices
{{< / highlight >}}

Da una idea de todos los pasos que habría que hacer si quisiéramos hacerlo a mano.
Trata el caso de las tarjetas gráficas NVIDIA de forma especial, puesto que con esas GPU es recomendable descargar los módulos correspondientes del núcleo.

La otra función es el método `LibvirtHook.on_host_prepare()`, que contiene el código que llama a `vfio_bind_devices()` antes del inicio de la máquina virtual de nombre "hoth", que es el nombre mi máquina virtual con Windows.

{{< highlight python "linenos=table,linenostart=151" >}}
def on_hoth_prepare(self):
    """Hook method to 'prepare' the start of a VM named 'hoth'
    """
    # Bind the PCI devices to passthrough to VFIO driver
    device_ids = [
        format_device_id(**address.attrib)
        for address in self.object_description.findall("devices/hostdev[@type='pci']/source/address")
    ]
    vfio_bind_devices(device_ids)

    # Start all the networks where the VM will be connected
    network_names = [
        source.get('network')
        for source in self.object_description.findall("devices/interface[@type='network']/source")
    ]
    for network_name in network_names:
        network = self.virt_connection.networkLookupByName(network_name)
        if network and not network.isActive():
            network.create()
{{< / highlight >}}

Si nuestra máquina virtual se llama "foo", solo necesitamos renombrar el método como `on_foo_prepare()`.

Este método no sólo registra los dispositivos en VFIO para hacer _PCI passthrough_.
También busca las redes virtuales a las que está conectada la máquina virtual y le indica a libvirt que las active.

## Liberar la gráfica

El script anterior solo podrá descargar el controlador de la tarjeta gráfica si no es la que estamos usando actualmente para el escritorio de Linux.
Podemos consultar qué gráfica está usando actualmente nuestro entorno gráfico ejecutando:

```
$ prime-select query  
nvidia
```

Si estamos usando la tarjeta gráfica, podemos seleccionar la gráfica integrada ejecutando:

```
$ prime-select intel
```

Después tendremos que reiniciar el sistema o salir de la sesión de escritorio y reiniciar el gestor de pantalla:

```
$ sudo systemctl restart display-manager
```

## Crear la máquina virtual

Hecho todo esto, podemos lanzar _virt-manager_ para crear nuestra máquina virtual.
Seleccionamos la opción de menú {{< gui "Archivo/Nueva máquina virtual">}}, se nos abrirá el asistente y seguimos los pasos indicados:

1. Instalación mediante {{< gui "Medio de instalación local" >}}.
1. Seleccionamos {{< gui "Utilizar imagen ISO" >}} y seleccionamos la imagen ISO con el contenido del CD de instalación de Windows.
1. Asignamos el número de CPU disponibles y la cantidad de memoria RAM. En mi caso la máquina virtual tiene 4 CPU y 8GB de RAM.
  Sin embargo, posteriormente veremos cómo indicar que la cantidad real asignada sea menor.
1. Indicamos el tamaño del disco duro de la máquina virtual.
  Yo opté por usar un [volumen lógico LVM](https://es.wikipedia.org/wiki/Logical_Volume_Manager), dentro del mismo grupo de volumen que contiene los volúmenes lógicos de mi sistema anfitrión Linux.
  Aunque no voy a detenerme en explicar cómo se hace.
1. Por defecto la imagen del disco duro se guarda en un archivo con formato [{{< gui "qcow2" >}}](https://en.wikipedia.org/wiki/Qcow).
  Eso es interesante si queremos ahorrar espacio, dado que empieza siendo un archivo muy pequeño y su tamaño aumenta dinámicamente según va ocupando espacio la máquina virtual.
  Pero si lo que nos interesa es el mejor rendimiento, mejor optar por el formato {{< gui "raw" >}}.
  En ese caso elegimos {{< gui "Seleccionar o crear almacenaje personalizado" >}} y le pedimos crear un nuevo volumen.
  Nos dejará escoger el nombre del archivo, formato y tamaño.

{{< figure src="images/3.png" caption="Crear un volumen del almacenamiento en formato \"raw\"." >}}

En la última ventana marcamos {{< gui "Personalizar antes de instalar" >}} y finalmente le damos un nombre.

{{< figure src="images/4.png" caption="Último paso en el asistente de creación de la máquina virtual." >}}

Al pulsar en finalizar se abre la ventana de detalles de la nueva máquina virtual.

{{< figure src="images/5.png" caption="Detalles generales de configuración antes de iniciar la instalación." >}}

Seleccionamos el firmware UEFI, en lugar de BIOS, y el modelo del _chipset_.
La configuración más segura es con [i440FX](https://es.wikipedia.org/wiki/Intel_440FX).
A mi no me fue posible iniciar la instalación con Q35, puesto que con ese _chipset_ la interfaz con los discos duros es AHCI y la versión de OVMF que estaba utilizando no lo soportaba.
Entonces intenté añadir un chip PIIX4, para tener una interfaz IDE a la que conectar el disco duro, pero Windows no era capaz de verlo durante la instalación.

En principio, la primera opción debería ser i440FX, dejando Q35 para los casos en los que el primero no funciona.
Por ejemplo, si queremos instalar una máquina virtual con macOS.

Aceptamos y avanzamos a la configuración de las CPU:

{{< figure src="images/6.png" caption="Detalles sobre la configuración de las CPU antes de iniciar la instalación." >}}

Aquí lo adecuado es indicar como modelo {{< gui "host-passthrough" >}}.
Está opción no está en la lista desplegable, así que tendremos que escribirla a mano.
Básicamente le dice a _KVM_ que "pase" a la máquina virtual la CPU del anfitrión tal cual, sin modificaciones.

Además se puede modificar la topología, es decir, cómo se exponen las CPU a la máquina virtual. Como se puede ver he optado porque la máquina virtual tenga una sola CPU, con 4 núcleos y un hilo de ejecución en cada uno.

Lo siguiente es modificar la configuración del disco duro principal: {{< gui "IDE Disco 1" >}}.

{{< figure src="images/7.png" caption="Detalles sobre la configuración del disco duro antes de iniciar la instalación." >}}

Por defecto _QEMU_ emula una interfaz IDE para el acceso al disco duro.
Sin embargo se puede mejorar el rendimiento desplegando {{< gui "Opciones avanzadas" >}} y cambiando {{< gui "Bus de disco" >}} a SCSI.
Luego se pulsa en {{< gui "Agregar hardware" >}} y se añade un {{< gui "Controlador" >}} del tipo {{< gui SCSI >}} y modelo {{< gui "VirtIO SCSI" >}}.

{{< figure src="images/8.png" caption="Añadir un controlador de disco VirtIO SCSI." >}}

[VirtIO](https://es.wikibooks.org/wiki/QEMU/Dispositivos/Virtio) es una interfaz de disco paravirtualizada.
Es decir, no emula una interfaz de disco real, como IDE o SCSI; sino que la máquina virtual sabe que es una interfaz por software diseñada para virtualización. El resultado es un mayor rendimiento.
Sin embargo Windows no sabe acceder a estos dispositivos si no se le proporcionan controladores adecuados durante la instalación.

Para que estos controladores estén disponibles necesitamos una segunda unidad de CDROM.
Pulsamos en {{< gui "Agregar hardware" >}} y añadimos {{< gui "Almacenamiento" >}} de tipo de dispositivo CDROM y tipo de bus IDE.

{{< figure src="images/9.png" caption="Añadir una unidad de CDROM para los controladores VirtIO." >}}

Hay que indicar que use la imagen ISO con los controladores VirtIO.
La última versión se puede descargar desde [aquí](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/).

Finalmente pulsamos en iniciar la instalación.

Si el firmware UEFI no inicia la instalación sino que nos deja en una interfaz de línea de comandos como la siguiente:

{{< figure src="images/10.png" caption="Interfaz de línea de comandos de OVMF." >}}

tendremos que buscar y lanzar nosotros mismos el arranque del instalador, ubicado seguramente en 
`FS0:\EFI\BOOT\BOOTX64`:

{{< figure src="images/11.png" caption="Pasos para localizar el arranque del instalado de la ISO de Windows." >}}

Llegados a este punto la instalación debería proceder con normalidad.
Cuando nos pregunte dónde instalar Windows, pulsamos en la opción de {{< gui "Cargar controlador" >}}, buscamos la unidad de CDROM con los controladores VirtIO y navegamos por las carpetas hasta `viosci\w10\amd64`, para instalar los controladores de 64 bits para Windows 10.

Una vez instalado el controlador, el instalador nos dejará seleccionar el disco duro virtual como unidad de destino y completar la instalación.

___

_En la [siguiente parte]({{< ref "/posts/2020-06-14_escritorio-virtual-de-windows-10-parte-2" >}}) veremos algunos ajustes interesantes para optimizar la máquina virtual y detalles adicionales para trabajar con el escritorio virtual de forma más cómoda._