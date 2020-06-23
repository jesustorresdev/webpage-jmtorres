---
title: "IOMMU: Primer asalto"
author: "Jesús Torres"
date: 2015-10-06T08:00:49.000Z

license: "CC-BY-4.0"

tags:
 - Linux
 - Virtualización

series:
 - virtual-desktop

featuredImage: "/posts/iommu-primer-asalto/images/featured.png" 
images:
 - "/posts/iommu-primer-asalto/images/1.png" 
 - "/posts/iommu-primer-asalto/images/2.png" 
 - "/posts/iommu-primer-asalto/images/3.png" 


aliases:
 - "/iommu-primer-asalto-7d342f7e77e5"
---

La IOMMU es una unidad de algunas CPU modernas que, entre otras cosas, permite que una máquina virtual pueda tener acceso directo y exclusivo a ciertos dispositivos del sistema.
Es decir, sin que el dispositivo tenga que ser emulador o virtualizado y prácticamente sin ninguna intervención del sistema que la hospeda.
Como así se puede acceder con el máximo rendimiento a dicho dispositivo desde una máquina virtual, la primera vez que oí hablar de esta tecnología fue con la intención de dar acceso a conjuntos de GPU a aplicaciones que corría en máquinas virtuales en la nube ---concretamente usando el [hipervisor Xen](http://en.wikipedia.org/wiki/Xen)--- con el objeto de que pudieran acelerar ciertas operaciones intensivas de cálculo.

Desde un punto de vista personal, hace 6 meses que decidí reinstalar mi ordenador después de tenerlo guardado un año a causa de una mudanza que parecía que nunca iba a terminar.
En aquel momento tuve la idea de aprovechar la ocasión para intentar utilizar esta tecnología con el objeto de crear un sistema de escritorio virtualizado.
Pero, como suele ocurrir con la tecnología recién llegada, las cosas suelen ser más sencillas de decir que de hacer.

## IOMMU

Todas CPU modernas de propósito general disponen de una unidad de gestión de la memoria principal (MMU).
Una de sus funciones es traducir las direcciones de memoria manejadas por la CPU ---generalmente llamadas direcciones virtuales--- en las direcciones físicas que verán los módulos de la memoria principal cuando sean accedidos.
Esto permite a los sistemas operativos modernos aislar a unos procesos de otros, como si para cada uno crearan la ilusión de que están solos en el sistema y que toda la memoria es sólo para ellos.

{{< figure src="/posts/iommu-primer-asalto/images/1.png" caption="Relación entre espacio de dirección virtual y espacio de direcciones físico --- [Dysprosia](https://en.wikipedia.org/wiki/User:Dysprosia), [License BSD](https://commons.wikimedia.org/wiki/File:Virtual_address_space_and_physical_address_space_relationship.png)" >}}


Por otro lado la memoria RAM no es lo único que puede ser accedido mediante el direccionamiento de la memoria principal.
Muchos dispositivos de E/S ocupan rangos de direcciones de memoria, de tal forma que cuando se accede a dichas zonas realmente se está accediendo a los dispositivos en cuestión.
Es decir, que haciendo uso de la MMU es perfectamente posible que un proceso tenga acceso directo a un dispositivo.
De hecho este es uno de los aspectos sobre los que se sustenta [DRI](http://es.wikipedia.org/wiki/Direct_Rendering_Infrastructure) ---acrónimo de [Direct Rendering Infrastructure](http://es.wikipedia.org/wiki/Direct_Rendering_Infrastructure)--- una tecnología clave para que las aplicaciones gráficas en sistemas basados en [_X.Org_](http://es.wikipedia.org/wiki/X.Org_Server) puedan acceder de forma directa al hardware de vídeo, mejorando así el rendimiento de dichas aplicaciones.

Sin embargo las facilidades ofrecidas por la MMU no son suficientes para todos los dispositivos.
Algunos buses de E/S ---como PCI, PCIe, FireWire y Thunderbolt, entre otros--- soportan algún tipo de acceso directo a memoria ([DMA](http://es.wikipedia.org/wiki/Acceso_directo_a_memoria)).
Es decir, que los dispositivos pueden enviar o recibir datos desde la memoria principal sin intervención de la CPU.
Esta es una característica muy interesante porque permite a la CPU ocuparse de otras tareas mientras tienen lugar las operaciones de E/S programadas.
El problema es que se debe indicar a los dispositivos en qué direcciones físicas de la memoria principal deben depositar los datos, algo imposible para cualquier proceso ya que estos sólo conocen y manipulan direcciones virtuales.
Sin saber en qué direcciones físicas las transformará la MMU, es imposible que un proceso le indique a un dispositivo de E/S que haga una operación con acceso directo a memoria.
Es aquí donde entra en juego la IOMMU, que fue introducida en 2011 en los procesadores de la familia x86.

{{< figure src="/posts/iommu-primer-asalto/images/2.png" caption="MMU e IOMMU --- [DTR](https://commons.wikimedia.org/wiki/User:DTR), Dominio público" >}}

La IOMMU es una unidad de gestión de la memoria, similar a la MMU, que se sitúa entre un bus de E/S y la memoria.
Al igual que la MMU mapea las direcciones virtuales visibles para la CPU en las direcciones físicas visibles para la memoria, la IOMMU traduce las direcciones virtuales visibles para los dispositivos de E/S en direcciones físicas de la memoria.
Lo que permite, entre otras cosas:

* Proteger la memoria de dispositivos defectuosos y de ataques de DMA.
En un sistema sin IOMMU un dispositivo defectuoso, malicioso o mal programado ---ya sea por el firmware interno o por el software del sistema--- que se conecte a través de un bus que soporte DMA puede acabar leyendo o escribiendo zonas vitales de la memoria; provocando la corrupción de la información o comprometiendo el sistema.
Por el contrario, en sistemas con IOMMU el sistema operativo tiene control exclusivo sobre la MMU y la IOMMU, pudiendo confinar así a cada proceso y cada dispositivo a su propio espacio de memoria.
* En sistemas virtualizados, ofrecer acceso directo a dispositivos físicos desde las máquinas virtuales ---lo que se denomina _device passthrough_---.
Gracias al uso de la MMU el sistema operativo del anfitrión puede hacer que dispositivos físicos concretos aparezcan en el espacio de memoria virtual que hace de memoria física de la máquina virtual.
Si estas direcciones son comunicadas por el sistema operativo de la maquina virtual a un dispositivo con DMA como origen o destino de una transferencia, sin IOMMU habrán problemas porque no son auténticas direcciones físicas que dicho dispositivo pueda usar para acceder a la memoria.
Sin embargo, con IOMMU las direcciones de memoria utilizadas por el dispositivo durante la transferencia se mapearán a las direcciones físicas correctas.

Es esta última ventaja de la IOMMU la que me interesa.
Ya antes de este proyecto personal, la IOMMU me facilitó utilizar [_Vagrant_](https://www.vagrantup.com/) para crear un entorno reproducible para desarrollar software que hacia uso de dispositivos hardware específicos ---una capturadora BlackMagick---.
Y ahora me permite plantearme el compartir la GPU con una máquina virtual con el fin de crear un sistema de escritorio virtualizado, con una mínima pérdida de rendimiento respecto al sistema anfitrión.

## El golpe con la realidad

Y menudo golpe.
Las piezas del ordenador las escogí en 2011, justo cuando empezaba a surgir esta tecnología.
Así que si bien he descubierto posteriormente que muchos de los componentes que elegí no eran lo mejor para este propósito, también es verdad que las circunstancias no me hubieran permitido hacerlo mucho mejor.

### CPU

El soporte de IOMMU lo ofrece la CPU y --- excepto por unos pocos modelos anteriores de Intel ---en la familiar x86 surge masivamente con los procesadores [Sandy Bridge](https://es.wikipedia.org/wiki/Sandy_Bridge), bajo la denominación de VT-d (Intel Virtualization Technology for Directed I/O).
Lamentablemente no todos los modelos tienen soporte.
Por ejemplo, prácticamente ningún procesador Intel Core i3 lo tiene.
Además, dentro de una misma familia es posible que modelos concretos tampoco lo tengan.
Ese fue mi caso, que adquirí un Intel Core i7 2600K con la absurda esperanza de jugar un poco a _overclockearlo_, con un tiempo del no disponía ---la letra K indica que el multiplicador de frecuencia de la CPU está desbloqueado, lo que los hace ideales para el _overclocking_--- .
Lamentablemente ninguno de los modelos desbloqueados de la familia Sandy Bridge en aquel entonces soportaban VT-d.
Esto, aunque común, no es una norma, pues posteriormente ha ido apareciendo algunos procesadores K con soporte VT-d tanto en Sandy Bridge como en familias posteriores.

{{< figure src="/posts/iommu-primer-asalto/images/3.png" >}}

Incluso teniendo una CPU con soporte hay que tener presente que algunos modelos tienen sus singularidades.
Por ejemplo, activar IOMMU en un procesador Sandy Bridge puede ocasionar una [caída importante del rendimiento que no se aprecia en otras familias de procesadores Intel](http://permalink.gmane.org/gmane.comp.networking.dpdk.devel/7409).
Por mi parte, acabé sustituyendo la CPU por otra Intel Core i7 3770 ---que es un procesador de la familia Ivy Bridge---.

### Placa madre

Lo siguiente es tener una placa madre con el chipset adecuado de un fabricante que no haya desactivado esta funcionalidad.
[Wikipedia indica](https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware) que chipsets como Q87, Q77, Q35, X38, X48 Q45, etc. lo soportan oficialmente, pero también placas madre que tienen chipsets diferentes, como: Z68, Z77, Z87, Z97, X58 o Q67.
Para complicar un poco más el asunto, el soporte de VT-d puede ser desactivado voluntariamente por el fabricante.
Esto hace que sea posible comprar una CPU y una placa madre con un chipset que soporte VT-d pero que no nos funcione, que funcione a medias porque el fabricante sólo ha hecho parte de su trabajo o que empiece a funcionar meses más tarde, cuando nos acordemos de actualizar la BIOS.

Ante esta situación, el comentado más escuchado en los foros era intentarlo y dejar constancia de cara a la comunidad de si había funcionado o no y en qué condiciones.
Así los que lleguen después sabrán qué hardware comprar con la seguridad de que a alguien le ha funcionado.
En mi caso había comprado una ASUS P8Z68-V cuyo chipset ---el Z68--- supuestamente no soporta IOMMU.
Pero un día actualicé la BIOS a la última versión después de haber leído un comentario en sentido positivo y comenzó a funcionar.
A diferencia de otras BIOS, no puedo activar VT-x ---el soporte de virtualización estándar--- sin activar VT-d, pero tampoco me voy a quejar por eso.

### Dispositivo

En principio podemos hacer _passthrough_ de cualquier dispositivo PCI o PCIe.
De hecho mis primeros intentos fueron con una pareja de tarjetas capturadoras BlackMagick DeckLink y no tuve ningún problema.
Pero el asunto se complica cuando queremos hacer lo mismo con tarjetas gráficas porque en ellas tenemos que cargar con el legado de las viejas VGA.
Tal es así que a este tipo de _passthrough_ se le ha dado su propio nombre: _VGA passthrough_.
Y hay software de virtualización como VirtualBox que si bien soportan el _PCI passthrough_ no soportan el caso particular de hacerlo con tarjetas gráficas.
En todo caso, dejaré la problemática particular de las tarjetas gráficas para un artículo posterior.

Sólo adelantaré que el _passthrough_ de las gráficas integradas de Intel (IGD) no es una posibilidad ---las gráficas incluidas en las [APU](https://es.wikipedia.org/wiki/AMD_Accelerated_Processing_Unit) de AMD se parecen más a las gráficas discretas, pero actualmente tampoco está muy claro si se puede hacer con ellas--- .
Además, no quitaremos muchos problemas si optamos por no usar la IGD ni para mostrar el escritorio del ordenador anfitrión.

Si necesitamos usar la IGD en el ordenador anfitrión, nuestra vida será algo más fácil si nos aseguramos de que las gráficas discretas que vamos a utilizar tienen una ROM que soporta UEFI ---es decir, pueden usarse en el arranque si recurrir a la vieja interfaz VGA---.
En mi caso me vi obligado a cambiar ---sintiéndolo mucho, porque mi vieja gráfica aun me servía perfectamente --- una GeForge GTX 560 Ti por una GTX 950, dado que el fabricante decidió en su momento no actualizar a UEFI toda la serie 500.

### Sistema operativo

Voy a usar Linux.
_KVM_ o _Xen_, VFIO, _QEMU_, _libvirt_ y _virt-manager_.
Muchas son las tecnologías del ecosistema Linux que se ven involucradas en este proyecto.
Algunas de ellas carecían de cierta madurez respecto al soporte IOMMU cuando comencé pero hoy ya no es así.
Funcionan perfectamente y existen decenas de foros y blogs en la red donde se explica cómo utilizarlas.
Lo único es que aun no se puede hacer en tan sólo un par de clics.

_(Parte 2, [aquí](/posts/iommu-la-maldición-de-la-vga))_

## Referencias

* [IOMMU --- Wikipedia](https://en.wikipedia.org/wiki/IOMMU)
* [List of IOMMU-supporting hardware --- Wikipedia](https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware)
