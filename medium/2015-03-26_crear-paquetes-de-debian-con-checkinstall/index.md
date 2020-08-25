---
title: "Crear paquetes de Debian con checkinstall"
author: "Jesús Torres"
date: 2015-03-26T18:16:00.000Z

description: ""

subtitle: ""

image: "/posts/2015-03-26_crear-paquetes-de-debian-con-checkinstall/images/1.gif" 
images:
 - "/posts/2015-03-26_crear-paquetes-de-debian-con-checkinstall/images/1.gif" 


aliases:
    - "/crear-paquetes-de-debian-con-checkinstall-f30f31fd65e1"
---

{{< figure src="/posts/2015-03-26_crear-paquetes-de-debian-con-checkinstall/images/1.gif" >}}

Ya hablamos de cómo modificar nuestro archivo de proyecto `.pro` para [preparar las reglas para make install](https://jmtorres.webs.ull.es/me/2013/04/make-install-con-qmake/).
De tal forma que si lo hemos hecho bien podemos compilar e instalar nuestra aplicación en el sistema simplemente ejecutando los siguientes comandos:

{{< highlight >}}
qmake  
make  
make install
{{< / highlight >}}

## Sistemas de gestión de paquetes

Sin embargo esta no es la forma más conveniente de distribuir software destinado a sistemas Linux.

Por lo general las distribuciones de Linux usan algún [sistema de gestión de paquetes](http://es.wikipedia.org/wiki/Sistema_de_gesti%C3%B3n_de_paquetes).
Estos están formados por una colección de herramientas diseñadas para automatizar la instalación, actualización, configuración y desinstalación de paquetes de software de forma consistente.
Por lo general estos paquetes contienen programas, librerías y datos.
Además de algunos metadatos relevalentes para el funcionamiento del sistema de gestión de paquetes como: nombre, descripción fabricante, suma de comprobación, versión y una lista de dependencias necesarias para que el software funcione convenientemente.

En sistemas [Debian](https://www.debian.org) y derivados [.deb](http://en.wikipedia.org/wiki/Deb_%28file_format%29) es la extensión de los paquetes de software.
Mientras que `dpkg` es el programa diseñado para manejarlos.
Aunque generalmente no se usa directamente sino a través de otros programas como `apt`/`aptitude`, Ubuntu Software Center, Synaptic o Gdebi.

Los paquetes .deb pueden ser creados a partir del código fuente del proyecto usando checkinstall o Debian Package Maker.
Y pueden convertirse a los formatos utilizados por otras distribuciones usando el comando `alien`.

## CheckInstall

[checkinstall](http://en.wikipedia.org/wiki/CheckInstall) es uno de esos programas que permiten crear paquetes .rpm o .deb a partir del código fuente.

Para usarlo primero generamos el archivo `Makefile` en el directorio del proyecto y después compilamos el programa:

{{< highlight >}}
qmake  
make
{{< / highlight >}}

Finalmente sólo tendremos que invocar el programa checkinstall desde el mismo directorio:

{{< highlight >}}
$ checkinstall --install=no
{{< / highlight >}}

Lo único que tenemos que tener en cuenta es que:

*   Si no indicamos la opción `--install=no` el paquete se instalará en el sistema tras ser creado.
Aparte de que seguramente eso no es lo que queremos, debemos tener en cuenta que checkinstall debe ser invocado con permisos de administrador para que pueda hacerse dicha instalación.
*   El nombre del paquete será el mismo que el del directorio que contiene el proyecto.
Si queremos cambiarlo podemos invocar a checkinstall con la opción `--pkgname`.

### Directorio de documentación

Lo primero que hará checkinstall es comprobar si existe el directorio `./doc-pak`.
Este directorio debe contener la documentación que el paquete instalará en `/usr/doc/<nombre_del_paquete>`.
Buenos candidatos para colocar allí son archivos tales como:

*   `README`
Suele contener información de relevancia para el programa en cuanto a su uso, características, errores y requisitos.
*   `INSTALL`:
Suele indicar las instrucciones para la instalación del programa.
*   `COPYING` o `LICENSE`:
Documento con la licencia del programa.
*   `Changelog`
Archivo de registro de cambios donde se listan los cambios hechos en el proyecto desde su última versión.
*   `TODO`:
Listado de tareas pendientes por hacer en el desarrollo del proyecto.
*   `CREDITS`:
Créditos de los autores del programa.

Si dicho directorio no existe, checkinstall nos preguntará si queremos crear uno.
Para ello buscará en el proyecto aquellos archivos que tengan nombres como los anteriores y los incluirá en el nuevo directorio de documentación.

{{< highlight >}}
checkinstall 1.6.2, Copyright 2009 Felipe Eduardo Sanchez Diaz Duran   
Este software es distribuído de acuerdo a la GNU GPL  

The package documentation directory ./doc-pak does not exist.   
Should I create a default set of package docs? [y]:
{{< / highlight >}}

### Descripción del paquete

A continuación checkinstall buscará el archivo `description-pak` para utilizar su contenido como descripción del paquete.
En caso de no encontrarlo nos pedirá que se la proporcionemos:

{{< highlight >}}
checkinstall 1.6.2, Copyright 2009 Felipe Eduardo Sanchez Diaz Duran  
Este software es distribuído de acuerdo a la GNU GPL  

The package documentation directory ./doc-pak does not exist.   
Should I create a default set of package docs? [y]: n  

Por favor escribe una descripción para el paquete.  
Termina tu descripcion con una linea vacia o con EOF.  
>> 
{{< / highlight >}}

### Menú de propiedades del paquete

Finalmente checkinstall nos mostrará las propiedades configuradas para el paquete y nos dará la opción de modificarlas a través de un menú:

{{< highlight >}}
checkinstall 1.6.2, Copyright 2009 Felipe Eduardo Sanchez Diaz Duran  
Este software es distribuído de acuerdo a la GNU GPL  

The package documentation directory ./doc-pak does not exist.   
Should I create a default set of package docs? [y]: n  

Por favor escribe una descripción para el paquete.  
Termina tu descripcion con una linea vacia o con EOF.  
>> Este es mi primer paquete basado en un proyecto de Qt.  
>>  

*****************************************  
**** Debian package creation selected ***  
*****************************************  

Este paquete será creado de acuerdo a estos valores:  

0 --- Maintainer: [ jesus@tatooine ]  
1 --- Summary: [ Este es mi primer paquete basado en un proyecto de Qt. ]  
2 --- Name: [ capturer-project ]  
3 --- Version: [ Debug ]  
4 --- Release: [ 1 ]  
5 --- License: [ GPL ]  
6 --- Group: [ checkinstall ]  
7 --- Architecture: [ amd64 ]  
8 --- Source location: [ capturer-project ]  
9 --- Alternate source location: [ ]  
10 --- Requires: [ ]  
11 --- Provides: [ capturer-project ]  
12 --- Conflicts: [ ]  
13 --- Replaces: [ ]  

Introduce un número para cambiar algún dato u oprime ENTER para continuar:
{{< / highlight >}}

Así que ahora podemos indicar el número de la opción que queremos modificar o pulsar ENTER para terminar.

Sí todo sale bien, el paquete es creado y se nos sugiere como instalarlo:

{{< highlight >}}
********************************************************************  

Done. The new package has been saved to  
/home/jesus/capturer-project/capturer-project_20150326–1_amd64.deb
`You can install it in your system anytime using:``dpkg -i capturer-project_20150326–1_amd64.deb``********************************************************************`
{{< / highlight >}}

mientras que en caso contrario checkinstall nos preguntará si queremos ver el registro de ejecución para obtener más detalles sobre lo que falló durante el proceso:

{{< highlight >}}
*** La instalación del paquete falló
{{< / highlight >}}`¿Quieres ver el archivo de bitácora? [y]: y`

## Referencias

1.  [Make install con qmake](https://jmtorres.webs.ull.es/me/2013/04/make-install-con-qmake/)
2.  Wikipedia --- [Sistema de gestión de paquetes](http://es.wikipedia.org/wiki/Sistema_de_gesti%C3%B3n_de_paquetes)
3.  Wikipedia --- [deb (file format)](http://en.wikipedia.org/wiki/Deb_%28file_format%29)
4.  Wikipedia --- [CheckInstall](http://en.wikipedia.org/wiki/CheckInstall)
5.  [Checkinstall para crear nuestros propios paquetes DEB](http://linuxgnublog.org/checkinstall-para-crear-nuestros-propios-paquetes-deb)
