---
title: "SnapRAID y MergerFS para almacenar archivos de forma fiable (I)"
author: "Jesús Torres"
#date: 2019-02-18T18:20:11.676Z

summary: "SnapRAID es una alternativa a los sistemas RAID convencionales para configurar un almacenamiento fiable. Mientras que MergerFS permite combinar fácilmente varios discos en un único espacio del almacenamiento. Vamos a utilizar ambos para preparar un espacio donde guardar de forma fiable todo tipo de contenidos."

tags:
 - Linux
 - Almacenamiento

featuredImage: "images/featured.jpeg" 
images:
 - "images/1.jpeg" 
 - "images/2.jpeg" 

aliases:
    - "/snapraid-y-mergerfs-para-almacenar-archivos-de-forma-fiable-i-24f4b0d616c2"
---

Hace años que vengo pensando en adquirir una NAS para almacenar copias de seguridad de las cosas más importantes ---las fotos de fiestas y viajes, algunos libros electrónicos, la tesis doctoral que nadie más leerá jamás y otros documentos---.
Quizás incluso usarlo como _media server_ para distribuir algunos de esos contenidos en la red de mi casa.

El asunto es que me gustaría preservar la información pero al mismo tiempo que sea accesible.
Si por ejemplo me dedico a hacer copias de seguridad en DVD o a copiarla en discos externos, seguramente cogerán polvo en el estante de los cacharros electrónicos, por los siglos de los siglos.
Y eso si me acuerdo de hacer la copia.
Lo más probable es que no sea así y acabe perdiendo los datos igual.

Las NAS para almacenar varios TB siguen siendo un poco caras para mi presupuesto y, además, yo tengo un ordenador de sobremesa que me gustaría aprovechar.
Una de esas torres con hueco suficiente para 8 discos duros, donde almacenar de sobra toda la información importante.
Además, no tengo ninguna necesidad de tenerlo dando servicio constantemente.
No me importa encenderlo solo cuando lo necesite.

Así que la cuestión es cómo almacenar gran cantidad de datos en varios discos duros de una manera que se accesible, fiable y sencilla.
La primera respuesta que se nos puede ocurrir es usar algún tipo de RAID.
Pero si los datos no tienen mucho movimiento, no hace falta protegerlos en tiempo real.
De hecho, hacer una copia de seguridad periódica cada cierto tiempo sería suficiente.
Solo que no quiero almacenar los datos por duplicado porque me parece tirar espacio de almacenamiento.

Es entonces cuando SnapRAID y MergerFS llegaron en mi ayuda.

## RAID

En Linux tenemos muchas maneras de configurar un almacenamiento fiable para cubrir nuestras necesidades personales.
Obviamente, si queremos lo mejor, podemos adquirir una controladora [RAID](https://es.wikipedia.org/wiki/RAID) por hardware ---incluso con batería propia, para mantener la información de la memoria caché de la controladora en caso de un fallo de alimentación---.
Esta solución es muy eficiente y es transparente respecto al sistema operativo, porque la controladora se hace cargo de todos los detalles, pero suele ser excesiva para uso doméstico.

{{< figure src="images/2.jpeg" caption="Controladora RAID SATA Adaptec 2020SA --- Dmitry Nosachev, [CC-BY-SA-4.0](https://commons.wikimedia.org/wiki/File:Adaptec_2020SA_SATA_RAID_controller.jpg)" >}}

Por mucho menos están las controladoras FakeRAID.
De hecho es muy probable que la placa madre de nuestro ordenador ya venga con alguna funcionalidad de este tipo.
En ese caso solo se implementa en el hardware y en el firmware de la controladora lo necesario para configurar los discos y para dar soporte al uso de volúmenes en RAID durante el arranque.
Posteriormente el sistema operativo se hace cargo de la gestión de los volúmenes RAID usando su propia implementación basada en software.
Las controladoras FakeRAID, a diferencia de las soluciones en Linux basadas al 100% en software, dan soporte a todo el arranque del sistema y permiten disponer de distintos sistemas operativos en el mismo almacenamiento RAID.
Por lo demás, tienen las mismas prestaciones que cualquier otra solución basada al 100% en software.

Linux dispone de una amplia variedad de soluciones con RAID basado en software.
Las más clásicas son las independientes del sistema de archivos, como [LVM](https://es.wikipedia.org/wiki/Logical_Volume_Manager) o [MD](https://en.wikipedia.org/wiki/Mdadm).
Ambas permiten configurar varios dispositivos ---o incluso particiones individuales, en el caso de LVM--- como un único volumen que podemos formatear con el sistema de archivos que más nos guste.
Sin embargo, Linux también soporta algunos sistemas de archivos que integran la funcionalidad del RAID por software, como ZFS o Btrfs, lo que siempre es más cómodo de gestionar que cuando tenemos que lidiar con dos componentes independientes.

### Inconvenientes

La verdad es que optar por ZFS o Btrfs y hacer instantáneas ---o _snapshots_ --- de los datos sería de lo más sencillo.
El problema es que parece que ZFS necesita bastante memoria para funcionar adecuadamente ---desde que ZFS apareció para Solaris han surgido diversas versiones para Linux, con limitaciones y requisitos diferentes que han variado con el tiempo, así que esto puede que ya no sea cierto, pero no me he parado a comprobarlo---.
Mientras que Btrfs sigue sin ofrecer el rendimiento y la fiabilidad de EXT4.

Además, muchas de las soluciones comentadas evitan la perdida de datos, en caso del fallo de unos de los discos, manteniendo una segunda copia de estos.
Es lo que se llama RAID-1.
Pero como he dicho, no estoy interesado en desperdiciar almacenamiento manteniendo dos copias de los datos.
Prefiero otras soluciones más eficientes en almacenamiento, como RAID-5, que solamente guardan información de paridad con la que recuperar los datos en caso de que sea necesario.
Es decir, esto se traduce en que si tengo 4 discos de 3TB:

* Con RAID-1, tendría 6TB de almacenamiento real y 6TB de datos redundantes.
* Con RAID-5, tendría 9TB de almacenamiento real y 3TB de datos redundantes.

RAID-5 puede consumir algo más de CPU y por eso las soluciones basadas en controladoras por hardware son las más atractivas cuando se necesita rendimiento, ya que la propia controladora se puede hacer cargo de ese trabajo extra, descargando a la CPU.
Estas controladoras suelen tener su propia batería para mantener la memoria interna, lo que evita un problema llamado _agujero de escritura_ ---o _write hole_---.
Un problema que, si no es tratado adecuadamente, puede llevar a la corrupción de los datos cuando ocurren fallos de alimentación ---por eso la necesidad de la batería en la controladora---.

Pero las controladoras RAID por hardware son bastante caras.
Mientras que la soluciones por software no siempre soportan RAID-5 o no tienen un soporte lo bastante maduro.
Por ejemplo, el soporte de RAID-5 en MD existe desde 2001 pero hasta 2017 ---Linux 4.11--- no se ha introducido [un mecanismo para cerrar el _write hole_](https://lwn.net/Articles/665299/) con ayuda de un disco adicional SSD que se usa como registro de transacciones.
En LVM el soporte de RAID-5 es de 2013 pero, aparte de imponer varias limitaciones a la hora de gestionar los volúmenes, aún no se ha incluido una solución similar a la de MD para cerrar el _write hole_.
Y como LVM comparte código con el soporte de las controladoras FakeRAID, es posible que estas últimas tenga el mismo problema.
Por su parte, Btrfs aún no soporta RAID 5 de forma fiable y tampoco resuelve el problema del _write hole_.
Mientras que ZFS ofrece una solución alternativas similar llamada RAID-Z.
El problema, como hemos comentado, es que ZFS puede consumir una cantidad importante de memoria para funcionar adecuadamente.

## SnapRAID

[_SnapRAID_](https://www.snapraid.it/) es una alternativa a las soluciones anteriores, siempre que no necesitamos fiabilidad en tiempo real.
Por ejemplo, es una buena opción si es razonable generar la información de recuperación periódicamente, sabiendo que los cambios entre esos intervalos de tiempo podrían perderse si fallara uno de los discos.
Esto tiene todo el sentido cuando los archivos no se modifican con frecuencia.

Además, _SnapRAID_ funciona sobre cualquier sistema de archivos y gestor de volúmenes, sin necesidad de formatear ni hacer cambios de formato.
Simplemente le indicamos las particiones que queremos proteger y él se encarga.
Estas particiones ya pueden contener datos y pueden tener tamaños diferentes.

En gran medida se parece a una solución tradicional de copias de seguridad, solo que no necesitamos duplicar el espacio disponible para hacer la copia.
_SnapRAID_ solo necesita un disco adicional para datos de paridad, como ocurre con RAID-5.

En cada ejecución, aparte de actualizar la información de recuperación, _SnapRAID_ refresca algunos bloques de datos para evitar la degradación de los datos con el paso del tiempo.
Muchos sistemas de archivos ignoran este fenómeno porque los datos se suelen manipular con cierta frecuencia.
Pero si vamos a tener un almacenamiento de larga duración, no está de más comprobar los datos y refrescarlos periódicamente para evitar pérdidas.

### Configuración de mi sistema

En mi caso tengo 4 discos duros vacíos de 3TB, aproximadamente.
De esos discos, 3 son para el almacenamiento de datos ---`/dev/sdc`, `/dev/sdd` y `/dev/sde`--- y el que queda para el archivo de paridad ---`/dev/sdb`---.

Hay que tener en cuenta que el archivo de paridad puede crecer tanto como el mayor de los discos de datos.
Por lo tanto, no buena idea utilizar un disco de paridad pequeño.

### Preparación del almacenamiento

Para empezar desde cero creé una tabla de particiones GPT en cada disco, con una única partición EXT4 que ocupa todo el espacio, tanto para los discos de datos:

{{< highlight bash >}}
sudo mkfs.ext4 -m2 -Eresize=3T -LSTOR-DATA1 /dev/sdc1  
sudo mkfs.ext4 -m2 -Eresize=3T -LSTOR-DATA2 /dev/sdd1  
sudo mkfs.ext4 -m2 -Eresize=3T -LSTOR-DATA3 /dev/sde1
{{< / highlight >}}

como para el de paridad:

{{< highlight bash >}}
sudo mkfs.ext4 -m0 -Eresize=3T -Tlargefile4 -LSTOR-PAR1 /dev/sdb1
{{< / highlight >}}

Respecto a las opciones de `mkfs.ext4` utilizadas:

* `-m2`. Por lo general el 5% del espacio en disco se reserva para el superusuario.
Esto permite evitar la fragmentación y garantiza que los procesos del root sigan funcionado, aunque un proceso no privilegiado haya llenado todo el disco.
El asunto es que un 5% en 3TB son 150GB de almacenamiento reservado que nunca podrán utilizarse para datos.
Esta opción permite rebajar el espacio reservado hasta el 2%, es decir, a 60GB.
* `-m0`. En el disco de paridad la fragmentación de archivos no es un problema porque solo va a estar ocupado por un único archivo de paridad.
Por otro lado, no está de más que el archivo de paridad tenga un poco más de espacio para crecer que el total del disco de datos más grande.
Como todos los discos son de igual tamaño, para tener algo más de espacio en el disco de paridad, se puede indicar durante el formateo esta opción y así no se reserva nada al superusuario.
Adicionalmente, se puede indicar también la opción `-Tlargefile4`.
* `-Tlargefile4`. Esta opción optimiza el espacio usado por el propio sistema de archivos bajo la premisa de que en general se van a almacenar archivos de gran tamaño.
Este es el caso del disco de paridad, por lo que es una buena idea usarlo al formatear, ganando así algo más de espacio libre.
Sin embargo, antes de utilizarlo con los discos de datos es importante estar seguro del tamaño de los archivos que vamos a almacenar.
En mi caso comprobé que el tamaño medio de los archivos que quería almacenar era de 2MB, así que no utilicé esta opción al formatear esos discos.
* `-Eresize=3T`. EXT4 por defecto permite extender el sistema de archivos hasta 1000 veces el tamaño original sin tener que desmontar la unidad.
Para eso, durante el formateo, reserva espacio suficiente para sus estructuras internas.
El problema es que ya estamos usando todo el espacio disponible en el disco para el sistema de archivos.
Es imposible extender el sistema de archivos sin cambiar de dispositivo.
Así que se puede ganar algo de espacio libre indicando que el sistema de archivos nunca crecerá por encima de los 3TB.
* `-LSTOR-DATA1`. Una etiqueta para nombrar cada partición de una forma fácil de recordar.

Una vez formateados, ya solo queda crear los puntos de montaje para los discos:

{{< highlight bash >}}
sudo mkdir -p /media/storage/{data1,data2,data3,parity1}
{{< / highlight >}}

y editar `/etc/fstab` para asegurarnos que se montan automáticamente durante el arranque del sistema.
Con añadir las siguientes líneas es suficiente:

{{< highlight bash >}}
# BIBLIOTECA: disco de paridad de SnapRAID  
LABEL=STOR-PAR1 /media/storage/parity1  ext4 defaults 0 2  
# BIBLIOTECA: discos de datos  
LABEL=STOR-DATA1 /media/storage/data1   ext4 defaults 0 2  
LABEL=STOR-DATA2 /media/storage/data2   ext4 defaults 0 2  
LABEL=STOR-DATA3 /media/storage/data3   ext4 defaults 0 2
{{< / highlight >}}

En lugar de reiniciar podemos ejecutar `mount -a` para comprobar que el montaje de los discos funciona correctamente.

{{< highlight bash >}}
sudo mount -a
{{< / highlight >}}

### Instalación y configuración de SnapRAID

Para instalar SnapRAID en Ubuntu lo más sencillo es añadir el [PPA de Maxim Tikhonov](https://launchpad.net/~tikhonov/+archive/ubuntu/snapraid):

{{< highlight bash >}}
sudo add-apt-repository ppa:tikhonov/snapraid  
sudo apt-get update
{{< / highlight >}}

y así poder instalarlo a través del gestor de paquetes de la distribución:

{{< highlight bash >}}
sudo apt-get install snapraid
{{< / highlight >}}

para luego editar el archivo de configuración `/etc/snapraid.conf`:

{{< highlight bash >}}
sudo nano /etc/snapraid.conf
{{< / highlight >}}

En dicho archivo, primero se indica la ruta al archivo de paridad en el directorio donde está montando el disco de paridad:

{{< highlight bash >}}
# Defines the file to use as parity storage  
# It must NOT be in a data disk  
# Format: "parity FILE_PATH"  
parity /media/storage/parity1/snapraid.parity
{{< / highlight >}}

Después las rutas a los archivos de contenidos.
Estos archivos almacenan las rutas de todos los archivos de datos protegidos por _SnapRAID_.

Al menos debe haber un archivo de contenido por archivo de paridad más uno adicional.
Y cada archivo debe estar en un disco duro diferente.
En mi caso guardo el archivo de contenidos en el sistema de archivos raíz en `/var/lib/snapraid/snapraid.content` y dos copias adicionales ---aunque solo estoy obligado a tener una más--- en los discos de datos `STORAGE-DATA2` y `STORAGE-DATA3`.

{{< highlight bash >}}
# Defines the files to use as content list  
# You can use multiple specification to store more copies  
# You must have least one copy for each parity file plus one.
 
# Some more don’t hurt  
# They can be in the disks used for data, parity or boot,  
# but each file must be in a different disk  
# Format: "content FILE_PATH"  
content /var/lib/snapraid/snapraid.content  
content /media/storage/data2/snapraid.content  
content /media/storage/data3/snapraid.content
{{< / highlight >}}

Ojo porque, si se configura igual, el directorio `/var/lib/snapraid/` debe existir antes de usar _SnapRAID_ por primera vez.

Luego se indican las rutas a los puntos de montaje de los discos de datos:

{{< highlight bash >}}
# Defines the data disks to use  
# The name and mount point association is relevant for parity, do  
# not change it  
# WARNING: Adding here your /home, /var or /tmp disks is NOT a good   
# idea!  
# SnapRAID is better suited for files that rarely changes!  
# Format: "disk DISK_NAME DISK_MOUNT_POINT"  
data d1 /media/storage/data1  
data d2 /media/storage/data2  
data d3 /media/storage/data3
{{< / highlight >}}

Y finamente las rutas dentro de los puntos de montaje de los discos de datos de archivos que serán excluidos de la sincronización:

{{< highlight bash >}}
# Defines files and directories to exclude  
# Remember that all the paths are relative at the mount points  
# Format: "exclude FILE"  
# Format: "exclude DIR/"  
# Format: "exclude /PATH/FILE"  
# Format: "exclude /PATH/DIR/"  
exclude *.unrecoverable  
exclude /tmp/  
exclude /lost+found/  
exclude .Trash-*/  
exclude .Thumbs.db  
exclude /Descargas/
{{< / highlight >}}

Como se puede ver, he decidido ignorar los archivos de miniaturas y el directorio donde se guarda el contenido de la papelera del escritorio.
Tampoco interesan archivos temporales ni aquellos recuperados durante reparaciones del sistema de archivos ---que se almacenan en `/lost+found/`---.
Además tengo una carpeta para descargas cuyo contenido tampoco quiero proteger.
Si finalmente decido preservar alguno de esos archivos, ya lo moveré a otra carpeta no excluida.

Una vez hecho todo esto podemos sincronizar el array de discos, protegiendo su contenido:

{{< highlight bash >}}
sudo snapraid sync
{{< / highlight >}}

### Usar SnapRAID

`SnapRAID` soporta una lista bastante completa de subcomandos con los que gestionar nuestro array de discos.
Entre muchos otros:

* `snapraid sync`, actualiza la información de paridad leyendo todos los archivos modificados en los discos de datos y guardando la información de paridad corresponde.
* `snapraid scrub`, permite hacer comprobaciones periódicas de los datos y de la información de paridad.
Usando las opciones `-p` y `-o` se pueden indicar los criterios para seleccionar los bloques de datos que serán verificados.
Por ejemplo, con el comando`snapraid -p 5 -o 20 scrub` se indica que se quiere comprobar el 5% de los datos del array, siempre que se hayan verificado por última vez hace más de 20 días.
* `snapraid status`, muestra información sobre el estado del array de discos.
* `snapraid fix`, repara archivos perdidos o dañados.
Básicamente verifica los datos con la información de paridad y si se encuentra alguna diferencia devuelve los archivos al estado en el que estaban cuando se hizo la sincronización.
Usando `snapraid -f file fix` o `snapraid -f dir fix` se puede recuperar un archivo `file` o un directorio `dir` en particular.
* `snapraid smart`, muestra el informe [SMART](https://es.wikipedia.org/wiki/S.M.A.R.T.) de todos los discos en el array.
* `snapraid check`, verificar todos los archivos y la información de paridad.
Básicamente se utiliza si queremos hacer una verificación manual de los datos, por ejemplo, después de haber recuperado algún archivo.

Sin embargo, no es muy realista pensar que cada día nos acordaremos de sincronizar los discos con los últimos cambios.
Es mucho mejor automatizar la ejecución del SnapRAID, como veremos en el siguiente artículo.

Si al final te animas a probar [_SnapRAID_](https://www.snapraid.it/) y te resulta útil, no olvides que el proyecto [admite donaciones](https://www.snapraid.it/) para ayudar a mantener su desarrollo.

_(Parte 2, [aquí]({{< ref "posts/2019-02-27_snapraid-y-mergerfs-para-almacenar-archivos-de-forma-fiable-parte-2" >}}))_
