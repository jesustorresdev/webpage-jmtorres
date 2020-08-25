---
title: "Compartir un proyecto de Vagrant entre diferentes equipos"
author: "Jesús Torres"
date: 2014-10-22T14:32:07.000Z

description: ""

subtitle: ""

image: "/posts/2014-10-22_compartir-un-proyecto-de-vagrant-entre-diferentes-equipos/images/1.png" 
images:
 - "/posts/2014-10-22_compartir-un-proyecto-de-vagrant-entre-diferentes-equipos/images/1.png" 


aliases:
    - "/compartir-un-proyecto-de-vagrant-entre-diferentes-equipos-bceadb91148a"
---

{{< figure src="/posts/2014-10-22_compartir-un-proyecto-de-vagrant-entre-diferentes-equipos/images/1.png" >}}



Desde que comencé a usar [Vagrant](https://www.vagrantup.com/) para facilitarme el colaborar en el proyecto de [robótica móvil](http://verdino.webs.ull.es/) en el que participo en mi departamento, no he dejado de emplearlo.
Ya sea para desarrollar en [ROS](https://github.com/ull-isaatc/grull_vagrant), [Apache Cordova](https://github.com/driftyco/ionic-box) --- antes Phonegap --- , [Wordpress](https://atlas.hashicorp.com/70kft/boxes/lamp) o [Qt](https://github.com/ull-etsii-sistemas-operativos/videovigilancia-vagrant); se está convirtiendo en una costumbre comenzar siempre preparando mi entorno de trabajo con Vagrant.
Para quien no lo conozca y quiera un introducción rápida a su uso, me limitaré a recomendar el [fantástico artículo de Elías R.M](http://linuxgnublog.org/entorno-de-desarrollo-basado-en-maquina-virtual) al respecto.

La única cuestión con la que no terminaba de estar conforme es con lo que ocurre cuando se comparte un mismo proyecto entre diferentes equipos.
Por ejemplo porque quiero trabajar tanto en el despacho como en casa.
Para que se me entienda, el código fuente obviamente suelo tenerlo controlado con Git pero no el resto de los archivos del proyecto, incluidos los relacionados con Vagrant.
Y aunque así fuera y estuviera usando un repositorio centralizado para compartir el código, no sería razonable subir trabajo a medias sólo porque ha llegado la hora de irme a casa.

Para compartir el entorno de trabajo sin duda son mejores otras herramientas, como Dropbox, Drive, [ownCloud](http://owncloud.org/) o, el que uso yo, [SeaFile](http://seafile.com/en/home/).
Lamentablemente Vagrant asigna a cada máquina virtual creada un identificador único que almacena en el directorio `.vagrant` del directorio del proyecto.
Si sincronizas, llevándote los archivos del proyecto a otro equipo y haces `vagrant up`, se crea una nueva máquina virtual con un nuevo identificador al no encontrar Vagrant la que estabas usando en el VirtualBox del otro equipo.
Obviamente volverá a pasar lo mismo al volver al equipo inicial, repitiéndose una y otra vez, de forma bastante incómoda, y acumulando en los equipos máquinas virtuales que no volverán a ser utilizadas por Vagrant.

La brillante solución a este problema ha llegado siguiendo las indicaciones de [un comentario](https://github.com/mitchellh/vagrant/issues/3362#issuecomment-39110895) en una incidencia en el proyecto de Vagrant en GitHub.
Concretamente me he limitado a añadir lo siguiente a mi archivo `~/.bashrc`:
``# Vagrant  
export VAGRANT_DOTFILE_PATH=".vagrant-$(hostname)";``

El resultado es que ahora Vagrant no utiliza `.vagrant` para guardar sus archivos sino `.vagrant-NOMBRE_DE_MÁQUINA`.
Por lo que en cada equipo utiliza un directorio diferente que mantiene adecuadamente la referencia correcta a la máquina virtual en ese equipo.

El único pero que se me ocurre a esta solución es que a fecha de hoy, 24 de octubre de 2014, la ruta indicada con `VAGRANT_DOTFILE_PATH` se expande en relación al directorio de trabajo, no al directorio raíz del proyecto, tal y como indica el siguiente comentario en el código fuente del proyecto:
> Setup the local data directory. If a configuration path is given, then it is expanded relative to the working directory.
Otherwise, we use the default which is expanded relative to the root path. --- [lib/vagrant/environment.rb:158](https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/environment.rb#L158)

Luego, si no queremos acabar con un montón de directorios `.vagrant-*` repartidos por el árbol de directorios de nuestros proyecto, conviene recordar ejecutar el comando vagrant siempre en la raíz del mismo.
Por el momento no he podido dar con una solución para este pequeño inconveniente.

Resuelto el problema, va siendo hora de volver al trabajo ;)
