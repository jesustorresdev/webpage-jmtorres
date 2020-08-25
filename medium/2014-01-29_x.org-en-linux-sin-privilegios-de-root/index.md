---
title: "X.Org en Linux sin privilegios de root"
author: "Jesús Torres"
date: 2014-01-29T14:31:53.000Z

description: ""

subtitle: ""

image: "/posts/2014-01-29_x.org-en-linux-sin-privilegios-de-root/images/1.png" 
images:
 - "/posts/2014-01-29_x.org-en-linux-sin-privilegios-de-root/images/1.png" 
 - "/posts/2014-01-29_x.org-en-linux-sin-privilegios-de-root/images/2.png" 


aliases:
    - "/x-org-en-linux-sin-privilegios-de-root-1475423e2c9c"
---

A través de G+ me he enterado del [trabajo de Hans Goede](https://plus.google.com/u/0/100910335823350190167/posts/2CsZ4XvHATz) para hacer que el servidor X Window/X.Org se pueda ejecutar sin privilegios de root.
La importancia de este paso deriva de que cualquier programa que se ejecuta con estos privilegios es un caramelo para los posibles atacantes; ya que aprovechando algún agujero de seguridad del programa podrían ser capaces de ejecutar código propio como root, ganando así privilegios en el sistema.

## Arquitectura de X.Org




![Arquitectura del sistema X Window --- Wikimedia Commons (https://goo.gl/ivvOAM)](https://jmtorres.webs.ull.es/me/wp-content/uploads/2014/01/arquitectura-del-sistema-x-window.png)

Arquitectura del sistema X Window --- vía [Wikimedia Commons](https://goo.gl/ivvOAM)



El sistema X Window es --- desde sus orígenes en 1984 --- un sistema con arquitectura cliente/servidor.
Es decir, las aplicaciones con interfaz gráfica son clientes que solicitan operaciones al servidor X, el único que realmente tiene acceso a los recursos del hardware.
La cuestión es que para que el sistema operativo le proporcione acceso a los dispositivos correspondientes, el servidor X tiene que ejecutarse como root.
Eso significa que los desarrolladores deben tener especial cuidado en la interacción con los clientes, ya que alguno podría ser un atacante que de forma intencionada esté buscando algún bug en el servidor que permita ejecutar código de forma arbitraria.

## La nueva gestión de sesiones

Por fortuna el arranque del sistema y la gestión de sesiones está cambiando muy rápidamente gracias al desarrollo de [Systemd](http://en.wikipedia.org/wiki/Systemd) impulsado por Red Hat.
Este programa está llamado a convertirse en el sustituto de SysVinit --- un [init](http://en.wikipedia.org/wiki/Init) que toma las características del init original de los sistemas Unix System V --- que hasta hace bien poco seguían utilizando la mayor parte de las distribuciones de Linux.
El nuevo _Systemd_ se encarga tanto de realizar de forma ordenada el inicio de sistema como de centralizar las tareas relativas a la gestión de las sesiones.
Para ello ha ido asumiendo funcionalidades que hasta el momento estaban dispersas en diferentes demonios.
Incluso se ha iniciado un camino que llevará a que el núcleo delegue en él ciertas funcionalidades actuales, lo que ha provocado [encendidos debates en la comunidad](https://plus.google.com/u/0/+Jes%C3%BAsTorresJorge/posts/HT7J4CLE5QD).

Por ejemplo, _Systemd_ ha introducido el concepto de puesto (_seat_) como un objeto virtual que describe una interfaz interactiva física del sistema.
Por lo general estamos hablando de una combinación de monitor, teclado y ratón, aunque también es posible incorporar otros dispositivos.
En cualquier caso la clave de este concepto es que los usuarios interactuan con el sistema a través de uno de esos puestos.
Además, en un mismo puesto se puedan iniciar múltiples sesiones, permitiendo que el usuario se autentique varias veces para tener diferentes sesiones abiertas al mismo tiempo, aunque en cada instante sólo una de dichas sesiones sea la activa.
Esta distinción es importante porque únicamente los procesos en la sesión activa tendrán acceso a los dispositivos que configuran el puesto.
Es decir, que sólo ellos recibirán la entrada del usuario --- por ejemplo, a través del teclado o el ratón --- y podrán mostrarle una salida --- por ejemplo, por medio del monitor --- .

## El demonio Systemd-logind

La mayor parte de toda esta magia la hace _systemd-logind_, uno de los múltiples demonios que componen _Systemd_.
Básicamente gestiona los puestos, estableciendo a cuál pertenece cada dispositivo y controlando el acceso a los mismos, ya que cada uno de estos dispositivos sólo puede pertenecer a un puesto.
De igual manera permite gestionar las sesiones de los usuarios, siguiendo la pista de la sesión activa y controlando el acceso a los dispositivos por parte de los procesos en las distintas sesiones.



![Gestión de sesiones con systemd --- David Herrmann (https://goo.gl/qdwFPf)](https://jmtorres.webs.ull.es/me/wp-content/uploads/2014/01/gestion-de-sesiones-con-systemd.png)

Gestión de sesiones con systemd --- por [David Herrmann](https://goo.gl/qdwFPf)

Para hacer todo esto posible, realmente _systemd-logind_ es el único proceso con acceso a los dispositivos.
Cuando el controlador de sesión quiere ganar acceso a alguno de los dispositivos del puesto, debe solicitarlo a _systemd-logind_, que simplemente le proporcionará un descriptor de archivos para ese dispositivo concreto.
Lo interesante es que como es _systemd-logind_ el encargado de abrir el dispositivo, el controlador de sesión no tiene que pertenecer a ningún usuario o grupo en especial.
Es así como un servidor X en un sistema con _Systemd_ puede ganar acceso a los dispositivos de E/S sin necesidad de ejecutarse con privilegios de root.

Además, a través de la interfaz [cgroups](http://en.wikipedia.org/wiki/Cgroups) del núcleo, _systemd-logind_ puede seguir la pista de los procesos y sus hijos para saber a qué sesión pertenece cada uno.
Esta interfaz también permite priorizar y establecer límites en los recursos que utilizan los diferentes procesos del sistema --- CPU, memoria, E/S, etc. --- .
Así que _systemd-logind_ la utiliza para enmudecer los dispositivos de un puesto de cara a los procesos de una sesión cuándo ésta deja de ser la sesión activa; incluso aunque parezca que tienen acceso a dichos dispositivos a través de los descriptores de archivo correspondientes.

## Más detalles

Todo este asunto de las nuevas posibilidades que ofrece _Systemd_ resulta apasionante, pero no es sencillo encontrar artículos donde las cosas estén bien explicadas.
En ese sentido hay reconocer la labor de [David Herrmann](http://dvdhrm.wordpress.com/about-me/), que cuenta perfectamente lo relacionado con la nueva gestión de sesiones en tres artículos muy interesantes:

*   [Sane Session-Switching](http://dvdhrm.wordpress.com/about-me/)
*   [How VT-switching works](http://dvdhrm.wordpress.com/2013/08/24/how-vt-switching-works/)
*   [Session-Management on Linux](https://dvdhrm.wordpress.com/2013/08/24/session-management-on-linux/)
