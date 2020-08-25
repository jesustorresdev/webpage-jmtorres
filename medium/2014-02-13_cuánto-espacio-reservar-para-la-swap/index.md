---
title: "¿Cuánto espacio reservar para la SWAP?"
author: "Jesús Torres"
date: 2014-02-13T10:19:45.000Z

description: ""

subtitle: ""

image: "/posts/2014-02-13_cuánto-espacio-reservar-para-la-swap/images/1.jpg" 
images:
 - "/posts/2014-02-13_cuánto-espacio-reservar-para-la-swap/images/1.jpg" 
 - "/posts/2014-02-13_cuánto-espacio-reservar-para-la-swap/images/2.png" 


aliases:
    - "/cu%C3%A1nto-espacio-reservar-para-la-swap-4da452241f33"
---

{{< figure src="/posts/2014-02-13_cuánto-espacio-reservar-para-la-swap/images/1.jpg" caption="Módulo RAM [--- Laserlicht](https://commons.wikimedia.org/w/index.php?title=User:Laserlicht&action=edit&redlink=1), License [CC-BY-SA-3.0](https://creativecommons.org/licenses/by-sa/3.0/deed.en)" >}}
_A finales de enero de 2008 publiqué un pequeño artículo en la web de_ [_GULIC_](http://www.gulic.org/‎) _con algunas recomendaciones acerca de la cantidad de espacio que era conveniente reservar para el espacio de intercambio durante la instalación de una distribución de Linux cualquiera.
Por un poco de nostalgia y dado que me gustaría conservarlo, ya que creo que no ha perdido vigencia, reproduzco a continuación su contenido._

_En 2019 actualicé el artículo original para contemplar que hoy en día los equipos suelen venir con mayores cantidades de RAM e incluir las recomendaciones de Canonical y de RedHat al respecto._### ¿Cuánto espacio reservar para la SWAP?

Esa es la eterna pregunta de todo el que se enfrenta a la instalación de sistema Linux.
Hoy en día algunas distribuciones vienen con instaladores que particionan nuestro disco de forma automática.
Pero si por cualquier motivo nos vemos obligados a hacerlo manualmente, seguramente nos haremos la gran pregunta.

Lo cierto es que pese a los años que han pasado sigue circulando el mito de que la _swap_ debe ser el doble de grande que la memoria RAM.
No se lo que pensarán otros, pero si yo tuviese un sistema de 16GB me rillaría bastante reservar 32GB.
Hace ya tiempo que [Russell Coker se enfrentó a este mito](http://etbe.coker.com.au/2007/09/28/swap-space/) e hizo la siguiente recomendación:

*   La _swap_ del mismo tamaño que la RAM para equipos con menos de 1GB.
*   La _swap_ de la mitad de RAM para equipos de entre 2GB y 4GB.
*   La _swap_ de 2GB para equipos con más de 4GB de RAM.

¿Y qué pasa si tengo 1.5? pues cualquier valor entre 1GB ---regla 2: la mitad de 2GB --- y 1.5GB ---regla 1: el mismo tamaño que la RAM para equipos con hasta 1GB --- parece razonable.
Yo suelo optar por lo segundo --- 1.5GB para la _swap_ --- porque hoy en día el espacio en disco es muy barato.

Equipos con 8GB o 16GB de RAM usando 2GB de _swap_ funcionan perfectamente.
Si las necesidades adicionales de memoria superan esos 2GB lo más conveniente es adquirir más RAM.
La _swap_ es mucho más lenta que la RAM, por lo que aumentando la _swap_ podemos conseguir que los programan obtengan la memoria que necesitan, pero a costa de empeorar el rendimiento global del sistema.

Como explicaré más adelante, tener "suficiente _swap_" es conveniente para que el sistema tenga libertad para intercambiar las regiones de la memoria más adecuadas.
Así que cuando hablamos de equipos con 64GB, 256GB o más de memoria RAM, surge la duda de si 2GB de _swap_ es suficiente para ese propósito o es casi lo mismo que no tener nada.

En ese sentido una buena regla, cuando la cantidad de RAM es mucha, es asignar a la _swap_ la raíz cuadrada de la RAM disponible: `round(sqrt(<tamaño de la RAM>))`.
Por ejemplo, [Canonical propone para la distribución Ubuntu](https://help.ubuntu.com/community/SwapFaq#Example_Scenarios), que a partir de 4GB se haga la raíz cuadrada del tamaño de la RAM redondeada al entero más cercano.
Así, a 6GB de RAM le corresponden 2GB de _swap_, mientras que a 8GB de RAM ya le corresponden 3GB de _swap_.

De forma parecida, Red Hat recomendaba hasta hace poco un cálculo similar solo que redondeando hacia arriba a la potencia de 2 más cercana.
Es decir, a entre 4GB y 16GB de RAM le corresponden 4GB de _swap_.
Como el almacenamiento es barato, no hay mucho perjuicio en redondear hacia arriba.

Sin embargo [Red Hat ha cambiado sus recomendaciones recientemente](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-disk-partitioning-setup-x86#idm140558470555584).
Ahora se parece a la de Russell Cocker, pero siendo mucho más generosos con la cantidad de _swap_ para equipos con menos de 8GB de RAM.

*   La _swap_ del doble de la RAM para equipos con menos de 2GB.
*   La _swap_ del mismo tamaño que la RAM para equipos de entre 2GB y 8GB.
*   La _swap_ de entre 4GB y la mitad de la RAM para equipos de entre 8GB y 64GB.
*   La _swap_ de al menos 4GB para equipos con más de 64GB de RAM.

## Hibernación

La hibernación permite suspender y recuperar el sistema rápidamente.
Básicamente consisten en almacenar en el disco el contenido de la RAM antes de apagar el ordenador.
Así el estado del sistema se puede volver a recuperar al volver a encenderlo, como si nunca hubiera sido apagado.

Esta funcionalidad no es muy interesante en servidores, que suelen estar encendidos constantemente.
pero sí lo es en equipos de escritorio, que se suelen apagar y encender con mucha frecuencia.

Para la hibernación el sistema vuelca en la _swap_ el contenido de la memoria RAM.
Por lo tanto la _swap_ debe ser lo suficientemente grande como para su uso normal más para albergar todo el contenido de la RAM.
Así que en sistemas donde se quiere hacer uso de la hibernación, a las cantidades recomendadas en el apartado anterior se les debe sumar el tamaño de la RAM instalada actualmente.

## ¿La swap ya no es necesaria?

Otro mito --- que confieso que en cierta medida yo mismo ayudé a difundir durante una época --- es aquel que dice que la _swap_ ya no es necesaria.
El motivo es que la perdida de rendimiento por utilizar la _swap_ es muy importante, por lo que en estos tiempos, y teniendo en cuenta al precio que se encuentra la RAM, puede ser mucho más rentable ir a la tienda de la esquina a comprar algunos módulos más.

Sin embargo no podríamos estar más equivocados.
En 2004 Martin Pool [comentaba en su blog que todas las páginas en Linux pueden clasificarse en una de las siguientes categorías](https://web.archive.org/web/20081022092522/http://sourcefrog.net/weblog/software/linux-kernel/swap.html).

*   Páginas del núcleo, que siempre están en memoria por lo que nunca son intercambiadas a la _swap_.
*   Código de programas, que son páginas de solo lectura, por lo que su contenido es siempre el mismo que el del archivo en disco que contiene al programa.
*   Páginas respaldadas en archivos, cuyo contenido es el mismo que el de alguna región de un archivo en disco que les sirve de respaldo.
Cuando estas páginas permiten el acceso de escritura, las modificaciones son escritas por el sistema operativo en el archivo mapeado.
*   Páginas anónimas, aquellas que no corresponden con ningún archivo en disco.
Eso incluye la pila, el montón o la memoria reservada dinámicamente con `malloc()`.

Cuando el sistema se empieza a quedar sin memoria, el núcleo debe escoger qué páginas pasan al disco para recuperar memoria libre.
Las páginas escogidas normalmente son las que se usan con menor frecuencia para evitar tener un impacto significativo en el rendimiento del sistema.
Si una página escogida es _no anónima_ siempre existe un archivo que sirve de respaldo al contenido de la página, por lo que puede ser recuperada fácilmente en el caso de que volvamos a necesitarla.
Pero las páginas anónimas carecen de dicho respaldo, por lo que solo pueden ser salvadas y copiadas en la _swap_.
¿Qué ocurre entonces cuando un sistema que carece de _swap_ se empieza a quedar sin memoria libre? Pues que el sistema, por más que quiera, no puede escoger nunca páginas anónimas para liberar memoria.
No importa que dichas páginas sean las utilizas con menos frecuencia, puesto que al no haber swap no tiene donde copiarlas.
Eso obliga al sistema a siempre ganar memoria a costa de páginas no anónimas, aunque estas estén siendo utilizadas en mayor medida que algunas de las anónimas.
Al no poder seleccionar las páginas más adecuadas para el reemplazo, el rendimiento del sistema se resiente.

Como acertadamente dice Martin Pool "Disk is cheap, so allocate a gigabyte or two for swap".

## Optimizar el uso de la memoria SWAP

Todo esto son reglas generales que por lo general funciona muy bien.
Sin embargo las necesidades reales de _swap_ dependen de los programas y el tipo de tareas para las que usemos el ordenador.
Así que hay quién prefiere analizar en detalle cuanto espacio va a necesitar, en lugar de seguir alguna de las recetas que hemos comentado.

Buscando en 2013 por Internet di en el blog Geekland [con un artículo en esta línea](https://web.archive.org/web/20140205203651/http://geekland.hol.es/optimizar-el-uso-de-la-memoria-swap/).
Entre las soluciones que comenta destaca la siguiente:

1.  Primero tenemos que saber la memoria RAM que tiene nuestro ordenador.
Por ejemplo, supongamos que tiene 1GB de RAM.
2.  A continuación tenemos que tener una idea del consumo máximo de RAM que tendremos con nuestros equipo en las peores circunstancias.
Por ejemplo, puedo considerar que el uso máximo de memoria RAM se dará cuando use simultáneamente el navegador, el procesador de texto, el gestor de correo y el reproductor de música.
Puedo ejecutas estas aplicaciones para ver cuanta memoria consume cada una y estimar que con todas estas aplicaciones abiertas mi consumo total será de 2GB.
3.  Considerando que tenemos un 1GB de RAM y en el peor de los casos vamos a llenar 2GB, tenemos que asignar al menos 1GB de _swap_, más un margen de seguridad de 512MB ---un 50% --- .
Por lo tanto, para este ejemplo, con 1.5GB de _swap_ sería suficiente.
4.  Para finalizar, hay que tener claro si tendremos la necesidad de poner nuestro equipo en hibernación.
En el momento que hibernamos nuestro equipo lo que estamos haciendo es volcar la totalidad de imágenes de procesos de nuestra memoria RAM a nuestra memoria _swap_.
Por tanto, en el caso de querer hibernar el equipo, como mínimo necesitaremos una _swap_ igual a nuestra RAM.
Así que en el ejemplo que hemos planteado, en el caso que quiera hibernar mi equipo, incrementaría la partición de memoria _swap_ de 1.5GB a 2.5GB.

Hay que tener en cuenta que lo complejo aquí es determinar ese consumo máximo en la peor de las situaciones.
Por lo pronto a mi la única forma que se me ocurre es hacerlo experimentalmente.
Es decir, aprovechar alguna instalación preexistente de Linux para lanzar programas que lleven al sistema a una de esas peores situaciones y usar algún programa, como [top](http://linux.die.net/man/1/top) o similar, para determinar la memoria total ocupada.
Como el sistema siempre intenta usar la memoria libre para bufferés y cachés, podemos restar el espacio que ocupan a ese total de memoria ocupada, para tener una buena estimación de la cantidad total de memoria que necesitamos.




![Comando top](https://jmtorres.webs.ull.es/me/wp-content/uploads/2014/02/captura-del-comando-top.png)

Captura de pantalla del comando top.



Por mi parte, como dudo que tenga tiempo y paciencia para hacer un análisis tan exhaustivo antes de realizar alguna nueva instalación de Linux, creo que me quedo con las sencillas reglas que vimos al principio.
A fin de cuentas ¿qué son dos o 4 gigas en un disco de un par de teras?
