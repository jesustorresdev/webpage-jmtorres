---
title: "Monitoriza tu sistema con estilo usando Conky"
author: "Jesús Torres"
date: 2015-09-28T11:00:49.000Z

description: ""

subtitle: ""

image: "/posts/2015-09-28_monitoriza-tu-sistema-con-estilo-usando-conky/images/1.png" 
images:
 - "/posts/2015-09-28_monitoriza-tu-sistema-con-estilo-usando-conky/images/1.png" 
 - "/posts/2015-09-28_monitoriza-tu-sistema-con-estilo-usando-conky/images/2.png" 
 - "/posts/2015-09-28_monitoriza-tu-sistema-con-estilo-usando-conky/images/3.png" 
 - "/posts/2015-09-28_monitoriza-tu-sistema-con-estilo-usando-conky/images/4.png" 


aliases:
    - "/monitoriza-tu-sistema-con-estilo-usando-conky-c68caffa6ec0"
---

Ordenador recién instalado con Kubuntu 15.04, shell y terminal bien configurada, llega la hora de buscar una herramienta para monitorizar el sistema y estar, en lo posible, al tanto de cuando le estoy pidiendo demasiado.
Hasta ahora esto lo hacía con un sencillo control de KDE 4 que no está disponible para KDE Plasma 5.2, aunque todo parece apuntar que estará de vuelta en la 5.3.




![Nuevos controles del monitor del sistema en KDE Plasma 5.3.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/sysmon.png)

Nuevos controles del monitor del sistema en KDE Plasma 5.3



En cualquier caso me enteré demasiado tarde de la noticia y algunos de los que la han probado tienen sus reservas sobre el consumo de CPU del nuevo _widget_.
Por lo que he estado probado [Conky](http://conky.sourceforge.net/), un monitor del sistema capaz de mostrar todo la información que se quiera en el fondo del escritorio.

Como prueba de lo que se puede hacer con tiempo, buen gusto y un poco de habilidad, nada mejor que:

*   Visitar esta lista de los [12 mejores temas para Conky](http://devmadness.com/os-software/conky-themes-scripts-configs/).
*   [Buscar Conky](http://www.deviantart.com/browse/all/?q=conky) en DevianArt.
*   Visitar el [subreddit Conkyporn](https://www.reddit.com/r/Conkyporn/).
*   Visitar la [categoría Conky](https://plus.google.com/u/0/communities/104794997718869399105/stream/c411c91a-2e51-4666-b3cc-13caf1c2dfc9) de la comunidad Eye Candy Linux de Google+.



{{< figure src="https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/conky-conky-conky-de-yesthisisme-1024x600.png" >}}

Tema [Conky, Conky, Conky](http://yesthisisme.deviantart.com/art/Conky-Conky-Conky-174343321) de YesThisIsMe

El único problema es que hacer estas verdaderas obras de arte no es tan sencillo.

Es el archivo de configuración de [Conky](http://conky.sourceforge.net/) --- por defecto `~/.conkyrc`--- en el que se indica qué se debe mostrar y cómo.
Todo en él son variables.
Algunas dan acceso a estadísticas del sistema operativo ---uso de la CPU, la memoria, el disco o la red, estadísticas de ejecución de los procesos en ejecución y [uptime](http://linux.die.net/man/1/uptime), entre otras variables--- otras dan información sobre las cuentas de IMAP e POP configuradas o sobre el estado de la reproducción en alguno de los reproductores multimedia soportados ---para por ejemplo conocer la canción que está sonando en MPD, XMMS2, BMPx o Audacious) y, por último, algunas facilitan cambiar la forma en la que se muestra esta información.

Por ejemplo, para mostraren gris claro la cantidad de memoria usada respecto a la cantidad total:
``${color lightgrey}RAM:$color $mem/$memmax - $memperc%``

Aunque también podemos mostrar la misma información usando un gráfico de barras:
``${membar}``

[Conky](http://conky.sourceforge.net/) también permite ejecutar nuestros propios scripts y usar su salida como un valor, si encontramos con que hay alguna estadística del sistema operativo o del hardware que no soporte por defecto.
Sin embargo, muchos de los que hacen los fantásticos temas que he enlazado antes optan por una solución bastante más flexible.
Usan [Lua](https://es.wikipedia.org/wiki/Lua), un lenguaje muy sencillo de empotrar en otros programas.
[Lua](https://es.wikipedia.org/wiki/Lua) nos permite obtener cualquier valor que nos interese y representarlo como nos venga en gana, ya que [Conky](http://conky.sourceforge.net/) exporta hacia [Lua](https://es.wikipedia.org/wiki/Lua) el API de Imlib2 y Cairo.
Las mismas librerías que él utiliza para generar su salida gráfica en el escritorio.

Así que si queremos poner algo bonito en marcha lo más rápido posible, mejor optamos por alguno de los temas desarrollados por la comunidad.

## Puesta en marcha

Obviamente lo primero es instalar [Conky](http://conky.sourceforge.net/).
En Debian, Ubuntu y otras distribuciones derivadas existen dos paquetes:
``# conky-std``

Es la versión que soporta las características más comunes.

{{< highlight >}}
conky-all
{{< / highlight >}}

Es la versión que soporta todas las características ---entre otras cosas incluye todo el soporte de [Lua](https://es.wikipedia.org/wiki/Lua)--- por lo que es la que recomiendan muchos desarrolladores de temas.

Por lo que si hacemos:
``# sudo apt-get install conky-all  
conky``

deberíamos ver como actualiza automáticamente nuestro fondo de escritorio.

Si observamos cierto parpadeo es porque debemos indicar a [Conky](http://conky.sourceforge.net/) que utilice doble búfer.
Esto se puede hacer ejecutando el programa con la opción `-b` o asegurándonos de que el archivo de configuración contiene la línea:
``double_buffer yes``

Como acabamos de instalar el programa está usando la configuración por defecto pero eso no es problema porque podemos volcarla:
``# conky -C > ~/.conkyrc``

y añadir la línea sobre el doble búfer al archivo.

## Si usas Plasma 5 y se ve feo de espanto

Si utilizas KDE lo más probable es que ahora mismo [Conky](http://conky.sourceforge.net/) te parezca feo de narices.
En tu caso el problema es que cualquiera que sea el tema que utilices debes comprobar que el archivo de configuración incluye las siguientes líneas:
``own_window yes  
own_window_type normal  
own_window_argb_visual yes  
own_window_argb_value 0  
own_window_transparent yes  
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager``

Además, se supone que si [Conky](http://conky.sourceforge.net/) está en ejecución cuando salgas de la sesión, volverá a ser iniciado automáticamente cuando vuelvas a entrar.
Si eso no ocurre lo mejor es indicarle a KDE que siempre intente iniciarlo automáticamente.
``# ln -s /usr/bin/conky ~/.kde4/Autostart/conky``

## Conky Manager

Cada tema tiene su propia forma de instarlarse.
Por ejemplo, en algunos casos tendremos que instalar paquetes adicionales, como `lm-sensors` o `hddtemp`.
Así que mejor seguir en cada caso las instrucciones del desarrollador paso a paso.

Sin embargo hay una forma más sencilla de hacer las cosas y es usando [Conky Manager](http://www.teejeetech.in/p/conky-manager.html).
Este programa es una interfaz gráfica para configurar [Conky](http://conky.sourceforge.net/) y los temas que más nos interesen.
También se hacer cargo de iniciar [Conky](http://conky.sourceforge.net/) durante el arranque del sistema, por lo que no tendremos que preocuparnos de nada.




![Ventana principal de Conky Manager.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/conky_manager_main_window.png)

Ventana principal de Conky Manager.



Para usarlo primero instalamos el PPA del proyecto y después el programa propiamente dicho.
``# sudo apt-add-repository -y ppa:teejee2008/ppa  
sudo apt-get update  
sudo apt-get install conky-manager``

Al ejecutarlo veremos un listado con todos los controles --- o _widgets_ --- disponibles.
Al seleccionar cualquier de ellos veremos una previsualización en la parte inferior.
Mientras que usando el icono del lápiz podemos configurar parámetros tales como la posición del control, el tamaño o el color de fondo.

Cuando lo tenemos claro marcamos en el _cuadro de verificación_ de la izquierda aquellos controles que nos interesen.
Así, cuando pulsemos el botón de _play,_ [Conky](http://conky.sourceforge.net/) se ejecutará mostrándolos tal y como los hemos configurado.

[Conky Manager](http://www.teejeetech.in/p/conky-manager.html) trae por defecto muy pocos temas pero eso se puede arreglar fácilmente.
Primero tenemos el [paquete de temas oficiales del proyecto](http://www.mediafire.com/download/icvmpzhlk7vgejt/default-themes-extra-1.cmtp.7z) y además Jesse Avalos hace su propio [Delux Conky Pack](http://www.mediafire.com/download/5yb5ambg6h4jack/Deluxe_Conky_Theme_Pack.cmtp.7z) que actualiza y anuncia regularmente en la comunidad [Eye Candy Linux de Google+](https://plus.google.com/u/0/communities/104794997718869399105/stream/c411c91a-2e51-4666-b3cc-13caf1c2dfc9), de la que es el propietario.
Para usarlos sólo es necesario descargar estos paquetes e importarlos en [Conky Manager](http://www.teejeetech.in/p/conky-manager.html) utilizando el botón correspondiente.




![Importar temas en Conky Manager.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/import_themes.png)

Importar temas en Conky Manager.



Ahora sólo nos queda probar los nuevos controles y elegir los que más nos gusten.
Y si no hay ninguno, echarle ganas y crear nuestro propio tema para [Conky](http://conky.sourceforge.net/).
