---
title: "Make install con qmake"
author: "Jesús Torres"
date: 2013-04-22T00:00:00.000Z

description: ""

subtitle: ""

image: "/posts/2013-04-22_make-install-con-qmake/images/1.png" 
images:
 - "/posts/2013-04-22_make-install-con-qmake/images/1.png" 
 - "/posts/2013-04-22_make-install-con-qmake/images/2.png" 


aliases:
    - "/make-install-con-qmake-6a49a2d40f94"
---

Cada entorno de desarrollo y/o lenguaje de programación maneja por sus propios medios la manera de definir un proyecto de software y el proceso de construcción del mismo.
Sin embargo [make](http://es.wikipedia.org/wiki/Make) sigue siendo ampliamente utilizado para este propósito, especialmente en los sistemas UNIX y derivados.

## Make

Para usar [make](http://es.wikipedia.org/wiki/Make) cada proyecto debe ir acompañado de un fichero `Makefile` donde se incluyen las reglas para la compilación y enlazado de las librerías y ejecutables del mismo.
Estas reglas fijan que es lo que hay que hacer ---que comandos ejecutar y como hacerlo--- para obtener cada producto del proceso de construcción, así como las dependencias de estos con respecto a otros productos o a los distintos archivos de código fuente del proyecto.
Además se pueden incluir reglas para automatizar tareas tales como generar la documentación; instalar o desplegar los programas, las librerías, la documentación y otros productos generados; o limpiar el proyecto, borrando archivos temporales y subproductos de la compilación.

Cuando la construcción de un proyecto ha sido automatizada adecuadamente con `make`, la compilación del mismo se reduce a ejecutar el comando:
``# make``

en el directorio del proyecto.
Siendo su instalación igual de sencilla:
``# sudo make install``

Obviamente entornos integrados de desarrollo como Eclise, KDevelop, Code::Blocks o Visual Studio incorporan sus propias herramientas para automatizar la compilación de proyectos, que además se integran perfectamente con estos entornos gráficos.
Sin embargo [make](http://es.wikipedia.org/wiki/Make) suele estar disponible en cualquier sistema y puede ser utilizado independientemente de las preferencias de cada desarrollador acerca del entorno integrado con el que trabajar.

Además [make](http://es.wikipedia.org/wiki/Make) es una herramienta que fácilmente puede ser utilizada desde otras de más alto nivel.
Por ejemplo, un sistema de construcción de paquetes como el que utilizan las distribuciones basadas en Debian automatiza todos los pasos, desde la descarga del código fuente hasta la generación del archivo `.deb`, pasando por invocar a `make` para compilar y a `make install` para que los productos de dicha construcción se instalen en su ubicación definitiva, de donde son tomados para conformar el contenido del paquete del proyecto.

En realidad, durante el proceso de construcción de un paquete `.deb`, el proyecto, una vez compilado, se instala, pero no en la raíz del sistema donde está teniendo lugar la compilación, sino que se confina el comando `make install` a un subdirectorio temporal.
Así [make](http://es.wikipedia.org/wiki/Make) deposita los archivos en sus ubicaciones predefinidas --- por ejemplo `/usr/bin`, `/usr/lib`, `/etc`, `/var/lib`, etc. --- solo que relativas a dicho subdirectorio --- por ejemplo `/ruta/al/subdirectorio/usr/bin`, `/ruta/al/subdirectorio/etc`, `/ruta/al/subdirectorio/usr/lib`, `/ruta/al/subdirectorio/var/lib`, etc. --- .
Para obtener el contenido del paquete sólo hace falta tomar el contenido del subdirectorio temporal, evitando que el proceso de construcción ensucie el sistema donde se está ejecutando.

De forma muy similar funciona [Bitbake](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/), la herramienta de construcción que utiliza el proyecto [Yocto](https://jmtorres.webs.ull.es/me/2013/01/yocto-poky-y-bitbake/) para generar distribuciones de Linux para sistemas empotrados, y así una larga lista de herramientas similares.
Para todas ellas el poder automatizar la construcción de proyectos de software es fundamental, siendo éste un campo donde la solución orientada a línea de comandos de [make](http://es.wikipedia.org/wiki/Make) se muestra mucho más flexible que las soluciones de interfaz gráfica integradas de los distintos entornos de desarrollo.

## Qmake

Aunque [make](http://es.wikipedia.org/wiki/Make) es una herramienta muy flexible, resulta muy compleja de utilizar, si no imposible, cuando se quiere crear software portable.
Diferentes sistemas operativos pueden tener distintos compiladores, ya sean de diferentes fabricantes o en distintas versiones, u ofrecer a las aplicaciones diferentes funcionalidades --- o las mismas pero de manera distintas --- .
Además un proyecto de software puede depender de otras librerías o programas, que nuevamente pueden ser de versiones diferentes o distintos desarrolladores.
Y a todo eso hay que unir que según el sistema operativo la ubicación de librerías, programas y herramientas de desarrollo puede diferir.




{{< figure src="/posts/2013-04-22_make-install-con-qmake/images/1.png" >}}



Enfrentar estas situaciones con [make](http://es.wikipedia.org/wiki/Make) es extremadamente difícil, por lo que los desarrolladores suelen utilizar otras utilidades que se encarguen de buscar las herramientas de desarrollo y las dependencias del programa, detectar las funcionalidades del sistema y generar un archivo `Makefile` ajustado al sistema concreto donde se va a compilar.

Herramientas de este tipo existen muchas.
Por ejemplo Autotools, CMake, SCons y [qmake](http://en.wikipedia.org/wiki/Qmake).
Siendo esta última la que se usa preferentemente con las aplicaciones desarrolladas en [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/), ya que sabe manejar perfectamente las singularidades de este _framework_.
GNU Autotools, por ejemplo, es la herramienta que está detrás de tener que ejecutar `./configure` antes de compilar con [make](http://es.wikipedia.org/wiki/Make) muchos programas y librerías libres.

Con [qmake](http://en.wikipedia.org/wiki/Qmake) las información requerida para construir un proyecto se define en un [archivo de proyecto](http://qt-project.org/doc/qt-5.0/qtdoc/qmake-project-files.html) que generalmente tienen extensión `.pro`.
Al ejecutar `qmake` dentro del directorio de un proyecto, éste interpreta los archivos de proyecto y genera el `Makefile` correspondiente.
Después sólo es necesario ejecutar el comando `make` para iniciar la compilación del mismo:
``# qmake  
make  
sudo make install``

## Reglas para make install

Realmente el último `make install` no sirve de mucho porque [qmake](http://en.wikipedia.org/wiki/Qmake) por defecto no añade tareas a dicha regla en el archivo `Makefile`.

Si queremos que al ejecutar `make install` se instalen los archivos de nuestra aplicación en las ubicaciones adecuadas, debemos instruir a [qmake](http://en.wikipedia.org/wiki/Qmake) a través del [archivo de proyecto](http://qt-project.org/doc/qt-5.0/qtdoc/qmake-project-files.html) acerca de como se hace:




La variable `INSTALLS` debe contener una lista de los recursos que queremos que sean instalados con `make install`.
De tal forma que cada elemento de la lista incorpora atributos que proporcionan información sobre dónde van a ser instalados.

Por ejemplo, el elemento `target` en la línea 16 representa a los ficheros resultado de la construcción del proyecto.
Asignando una ruta a `target.path` ---línea 19--- estamos indicando donde queremos que sean instalados.
De forma similar, el elemento `icon32` representa al archivo del icono de la aplicación en el escritorio.
Asignando un valor a `icon32.path` en la línea 30 estamos diciendo donde queremos que sea instalado, mientras que el valor del atributo `icon32.files` en la línea 31 indica donde podemos encontrar el archivo o archivos del icono respecto al directorio del proyecto.
En el caso del recurso `target` no hace falta usar `target.files` porque se sobreentiende que se sabe dónde el compilador ha dejado los ejecutables que deben ser copiados a `target.path`.

En teoría podemos especificar cualquier ubicación como destino de nuestros archivos, aunque es muy recomendable seguir el [Filesystem Hierarchy Standard](http://es.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) de los sistemas Linux, UNIX y derivados.



{{< figure src="/posts/2013-04-22_make-install-con-qmake/images/2.png" >}}

## Extras y commands

En las líneas de la 33 a las 35 se puede observar como hacer para crear un directorio en la ruta almacenada en `$$VARDIR`.
Asignando un valor a `vardir.commands` le estamos diciendo el comando que debe ejecutar `make` para construir esa parte del proyecto.
Por lo tanto lo que va a ocurrir es lo siguiente:

1.  Durante la construcción del proyecto `make` ejecutará el comando `true`, que no hace nada y siempre termina con éxito.
2.  Durante la instalación, `make install` creará la ruta indicada en `vardir.path` si no existe.
Posteriormente, intentará copiar los archivos indicados en `vardir.files` en `vardir.path` pero como `vardir.files` no contiene nada, no se copiará nada.

Por eso esta es una manera sencilla de crear directorios durante la instalación.
Sin embargo no es la única.
Una forma alternativa es la siguiente:
``## Crear directorio de archivos variables  
vardir.extra = mkdir -p $$VARDIR``

puesto que por medio de `.extra` podemos indicar comandos personalizados que serán invocados durante la ejecución de `make install`.

## Definición de macros del preprocesador

Las variables que hemos definido dentro del [archivo de proyecto](http://qt-project.org/doc/qt-5.0/qtdoc/qmake-project-files.html) establecen la ubicación de los recursos del programa tras su instalación.
Sería más complicado cometer errores si en nuestro código fuente usáramos directamente las rutas tal y como se definen en el [archivo de proyecto](http://qt-project.org/doc/qt-5.0/qtdoc/qmake-project-files.html), sin tener que volver a definirlas en C++.
Además eso daría pie a modificar la ruta de los archivos mediante la redefinición de variables en la línea de comandos de [qmake](http://en.wikipedia.org/wiki/Qmake), sin tener por ello que modificar el código fuente.
Por ejemplo:
``# qmake PREFIX=/usr``

ejecuta [qmake](http://en.wikipedia.org/wiki/Qmake) usando el valor indicado para la variable `PREFIX`.

Para conseguir esto sólo tenemos que utilizar la variable `DEFINES`, que nos permite listar un conjunto de macros del preprocesador que queremos que sean pasadas al compilador.
Las macros del preprocesador son aquellas que generalmente se definen en C/C++ mediante la directiva `#define`.




Así, por ejemplo, dentro del código fuente se puede usar la macro `APP_CONFFILE` con la ruta al archivo de configuración de la aplicación para acceder a él mediante [QSettings](http://qt-project.org/doc/qt-5.0/qtcore/qsettings.html):
``QSettings settings(APP_CONFFILE, QSettings::IniFormat);``

## Referencias

1.  [qmake Project Files](http://qt-project.org/doc/qt-5.0/qtdoc/qmake-project-files.html)
2.  Wikipedia --- [Filesystem Hierarchy Standard](http://es.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)
