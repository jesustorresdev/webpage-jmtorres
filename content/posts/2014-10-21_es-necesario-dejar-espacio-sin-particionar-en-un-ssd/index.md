---
title: "¿Es necesario dejar espacio sin particionar en un SSD?"
author: "Jesús Torres"
date: 2014-10-21T01:49:54.000Z
lastmod: 2020-06-03T11:41:54+01:00

description: ""

subtitle: ""

image: "/posts/2014-10-21_es-necesario-dejar-espacio-sin-particionar-en-un-ssd/images/1.JPG" 
images:
 - "/posts/2014-10-21_es-necesario-dejar-espacio-sin-particionar-en-un-ssd/images/1.JPG" 


aliases:
    - "/es-necesario-dejar-espacio-sin-particionar-en-un-ssd-ef8d44821bf7"
---

![image](/posts/2014-10-21_es-necesario-dejar-espacio-sin-particionar-en-un-ssd/images/1.JPG)

Kingston HyperX 120GB 3K SSD —[Zunter](https://commons.wikimedia.org/wiki/User:Zunter), License [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/deed.en)

Hace unas semanas recibí un correo donde me preguntaban si una forma concreta de particionar un nuevo disco duro SSD era la más conveniente. Lo que me llamó la atención fue que se pretendía dejar 8GB de espacio sin particionar para alargar la vida del disco. Conociendo algo sobre como funcionan los disco SSD y como interactuan con el sistema operativo instalado, no estaba seguro de que dicha medida fuera a tener un efecto relevante, por lo que lo dejé pasar. Pero hace unos días leí el artículo ¿Qué puedo instalar en mi SSD? de un amigo y eso me animó a volver a retomar la cuestión.

### El problema de los SSD

Los disco duros de estado sólido o SSD son dispositivos que se han ganado la reputación de ser muy rápidos y de fallar con bastante frecuencia. Lo primero surge de la ventaja de poder acceder de forma eficiente a cualquier sector del disco duro, sin tener que desplazar elementos móviles por procedimientos mecánicos de una zona a otra, como ocurre en los disco duros tradicionales. Lo segundo hoy en día se puede considerar un mito que ha quedado en la memoria colectiva debido a la aparente alta tasa de fallo que tuvieron los primeros dispositivos de esta tecnología.

Hay que tener en cuenta que los dispositivos SSD se basan en la tecnología de las memorias flash y que esta presenta el inconveniente de que el número máximo de borrados que admite cada sector está muy limitado. Si tenemos en cuenta que antes de sobrescribir un sector hay que borrarlo, podemos hacernos una idea de que esto plantea un problema para usar esta tecnología en dispositivos donde se modifican datos de forman intensiva — esta misma tecnología se utiliza en los _pendrive USB_ pero el uso que se hace de esos dispositivos no es el mismo — .

La solución a este problema sería muy sencilla si los sistemas de ficheros se diseñaran para escribir en sectores diferentes cuando modificaran el contenido de sectores ya usados. Sin embargo los sistemas de ficheros tradicionales, usados con los discos duros magnéticos de toda la vida, carecen de esta capacidad. Además todos deseamos seguir usando el mismo sistema de ficheros tanto si utilizamos un disco duro tradicional como si es SSD. Así que la industria ha incorporado a sus dispositivos SSD una capa de traducción denominada FLT — o Flash Translation Layer — cuya función es hacer lo que los sistemas de ficheros tradicionales no hacen por sí mismos. Es decir, la FLT se encarga de remapear cada sector en un sector libre diferente cuando van a ser sobrescrito.

Para hacerlo, la FLT gestiona una tabla que mapea los números de sectores lógicos utilizados por el sistema operativo, a través del sistema de ficheros, en los sectores físicos correspondientes donde realmente se almacenan los datos en el SSD. Cada vez que el sistema solicita una operación de lectura sobre un sector, la FLT busca en la tabla el sector físico correspondiente y la operación de lectura se realiza sobre él. Mientras que cuando se intenta hacer una operación de escritura, la FLT busca un sector físico libre y previamente vacío, realiza sobre él la operación de escritura indicada y actualiza la tabla para recodar el nuevo sector físico al que se mapea el sector lógico utilizado por el sistema operativo.

El resultado de este mecanismo es que la vida de los dispositivos SSD se alarga enormemente, así que ya no se pueden considerar dispositivos tan frágiles como antes. Aún así está claro que no durarán para siempre, por lo que puede ser interesante utilizar alguna [herramienta que nos ofrezca una estimación de su esperanza de vida](http://www.omicrono.com/2014/06/como-calcular-cuanto-tiempo-de-vida-tendra-tu-ssd/).

### Comando TRIM

Durante su funcionamiento, la FLT sigue la pista de los sectores físicos ocupados y de los que están libres. Así que cuando se escribe sobre un sector libre, éste es marcado como ocupado. Mientras que si esa escritura se debió al intento de sobrescribir un sector lógico por parte del sistema operativo, el sector físico donde antes se guardaban los datos es marcado para su borrado en algún momento posterior, quedando después de eso etiquetado como libre. Obviamente, cuantos más sectores libres hay en el disco SSD más se pueden rotar las operaciones de escritura y más tiempo tardará el dispositivo empezar a perder sectores.

Lamentablemente esto es una vía de un sólo sentido. Es decir, el disco sabe que sectores lógicos no han sido usados nunca — porque nunca han sido escritos por el sistema de ficheros — pero desconoce aquellos que han sido usados en algún momento pero ahora están libres. A fin de cuentas, durante el uso normal del sistema, se crean y se eliminan archivos en diferentes zonas del disco. Esto conlleva que a la larga el dispositivo SSD no disponga de suficientes sectores físicos libres para su uso por parte de la FLT, aunque para el sistema operativo aún queden muchos GB libres.

Para resolver esto la industria introdujo el comando TRIM. Este es enviado por el sistema operativo al dispositivo cada vez que libera un sector, de tal forma que ahora el disco SSD sabe que puede borrar y reutilizar el dispositivo físico correspondiente.

### ¿Entonces es necesario dejar espacio sin particionar?

En mi opinión, la mejor respuesta a la pregunta de si es necesario dejar espacio sin particionar en un dispositivo SSD es que dependen de las circunstancias. Si por ejemplo se usa un sistema de ficheros tradicional que no es capaz de hacer el trabajo de la FLT por si mismo — realmente sólo unos pocos como [JFFS](http://es.wikipedia.org/wiki/JFFS), [JFFS2](http://es.wikipedia.org/wiki/JFFS2) o [F2FS](http://es.wikipedia.org/wiki/F2FS) lo hacen — y el sistema operativo no soporta el comando TRIM, o no se quiere activar por algún motivo, sin duda hay que hacerlo. Hay que tener en cuenta que algunos sistemas pueden no soportar TRIM en determinadas configuraciones — por ejemplo, con sistemas de ficheros concretos o en configuraciones en RAID — . Además algunos fabricantes advierten que el uso del comando TRIM puede tener un pequeño efecto sobre el rendimiento. Aunque en mi opinión es conveniente activarlo, siempre que sea posible, para alargar la vida del dispositivo.

Si vamos a usar el comando TRIM, no hay motivo para reservar ese espacio sin particionar, siempre que no estemos pensando en mantener ocupado más del 75% del espacio durante grandes periodos de tiempo. Si esto último ocurre, podría ser interesante reservar cierto espacio sin particionar para asegurarnos de que siempre disponemos de un 25% de espacio libre. En todo caso debemos tener presente que el rendimiento de los sistemas de ficheros cae notablemente cuando el grado de ocupación del dispositivo es muy alto. Por lo que si es así, seguramente sería mejor conseguir un dispositivo de mayor tamaño.
