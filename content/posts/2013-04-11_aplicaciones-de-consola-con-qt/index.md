---
title: "Aplicaciones de consola con Qt"
author: "Jesús Torres"
date: 2013-04-11T00:00:00.000Z
lastmod: 2020-06-03T11:41:25+01:00

description: ""

subtitle: ""

image: "/posts/2013-04-11_aplicaciones-de-consola-con-qt/images/1.jpeg" 
images:
 - "/posts/2013-04-11_aplicaciones-de-consola-con-qt/images/1.jpeg" 
 - "/posts/2013-04-11_aplicaciones-de-consola-con-qt/images/2." 


aliases:
    - "/aplicaciones-de-consola-con-qt-ab974881cdf5"
---

![image](/posts/2013-04-11_aplicaciones-de-consola-con-qt/images/1.jpeg)

KDE neon con Plasma 5.8 — [okubax](https://www.flickr.com/photos/okubax/), License [CC-BY-2.0](https://creativecommons.org/licenses/by/2.0/)

[Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) es un _framework_ utilizado fundamentalmente para desarrollar aplicaciones con interfaz gráfica. Sin embargo nada impide que también sea utilizado para crear aplicaciones de linea de comandos.

### QCoreApplication

Al crear un proyecto de aplicación para consola, el asistente de Qt Creator crea un archivo `main.cpp` con un contenido similar al siguiente:
``#include &lt;QCoreApplication&gt;````int main(int argc, char *argv[])  
{  
    QCoreApplication a(argc, argv);````    return a.exec();  
}``

`[QCoreApplication](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html)` es una clase que provee un bucle de mensaje para aplicaciones de consola, mientras que para aplicaciones gráficas lo adecuado es usar `[QApplication](http://qt-project.org/doc/qt-5.0/qtcore/qapplication.html)`. El bucle de mensajes es iniciado con la invocación del método `[QCoreApplication](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html)::[exec](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html#exec)()`, que no retorna hasta que la aplicación finaliza. Por ejemplo cuando el método `[QCoreApplication](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html)::[quit](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html#quit)()` es llamado.

Si la aplicación no necesita de un bucle de mensajes, no es necesario instanciar `[QCoreApplication](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html)`, pudiendo desarrollarla como cualquier programa convencional en C++, sólo que beneficiándonos de las facilidades ofrecidas por las clases de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/).

Las clases de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) que requieren disponer de un bucle de mensajes son:

*   **Controles, ventanas y en general todas las relacionadas con el GUI**.
*   **Temporizadores**.
*   **Comunicación entre hilos mediante señales**.
*   **Red**. Si se usan los métodos síncronos `waitFor*` se puede evitar el uso del bucle de mensajes, pero hay que tener en cuenta que las clases de comunicaciones de alto nivel (`QHttp`, `QFtp`, etc.) no ofrecen dicho API.

### Entrada estándar

Muchas aplicaciones de consola interactúan con el usuario a través de la _entrada estándar_, para lo cual se pueden usar tanto las clases de la librería estándar de C++:
``std::string line;  
std::getline(std::cint, line)``

como los flujos de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/):
``QTextStream qtin(stdin);  
QString line = qtin.readLine();``

Sin embargo es necesario tener presente que en ambos casos el hilo principal se puede bloquear durante la lectura —hasta que hayan datos que leer— lo que impediría la ejecución del bucle de mensajes.

Para evitarlo se puede delegar la lectura de la _entrada estándar_ a otro hilo, que se comunicaría con el principal para informar de las acciones del usuario a través del mecanismo de señales y _slots_ de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/). El procedimiento sería muy similar al que comentamos en [una entrada anterior](https://jmtorres.webs.ull.es/me/2013/02/hilos-de-trabajo-usando-senales-y-slots-en-qt/), sólo que para leer la _entrada estándar_ en lugar de para ordenar un vector de enteros.

### Usando manejadores de señales POSIX con Qt

Los sistemas operativos compatibles con el estándar POSIX implementan un tipo de interrupción por software conocida como [señales POSIX](https://jmtorres.webs.ull.es/me/2015/03/introduccion-a-las-senales-posix/), que son enviadas a los procesos para informar de situaciones excepcionales durante la ejecución del programa. El problema es que las _señales POSIX_ pueden llegar en cualquier momento, interrumpiendo así la secuencia normal de ejecución de instrucciones del proceso, lo que puede introducir problemas de concurrencia debido al posible acceso del manejador —o de funciones invocadas por el manejador— a datos que estén siendo manipulados por el programa en el momento en que es interrumpido.

Lo cierto es que [sólo unas pocas funciones de la librería del sistema son seguras frente a señales POSIX](https://jmtorres.webs.ull.es/me/2015/03/introduccion-a-las-senales-posix/#seguridad). Y obviamente no hay seguridad de que las funciones del API de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) lo sean, por lo que no podemos invocarlas directamente desde los _manejadores de señal_. Además [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) no integra ninguna solución que encapsule y simplifique la gestión de _señales POSIX_, puesto que éstas no están disponibles en sistemas operativos no POSIX y [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) sólo implementa características portables entre sistemas operativos.

Aun así en la documentación de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) se describe una forma de usar _señales POSIX_, que en realidad es muy sencilla:

*   Basta con que al recibir la señal POSIX el manejador haga algo que provoque que [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) emita una señal, antes de retornar. Por ejemplo, escribir algunos bytes en un _socket_ que está conectado a otro gestionado por [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/).
*   Al volver a la secuencia normal de ejecución del programa, tarde o temprano la aplicación volverá al bucle de mensajes. Entonces la condición será detectada — en el ejemplo anterior, sería que han llegado algunos bytes a través del _socket_ que [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) gestiona — y se emitiría la señal de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) correspondiente, que invocaría al _slot_ al que está conectada, desde donde se podrían ejecutar de forma segura las operaciones que fueran necesarias.

Concretamente en el artículo [Calling Qt Functions From Unix Signal Handlers](http://doc.qt.io/qt-5/unix-signals.html) se propone la solución esquematizada en la siguiente ilustración:




![Manejo de señales POSIX en aplicaciones con Qt](https://docs.google.com/drawings/d/1CnH_jpMjLO7iDAMd9p2VsRa0v_yPJUvZZLs3xucZkIU/pub?w=797&amp;h=597)

Solución de manejo de señales POSIX en Qt.



Así que comenzaremos declarando una clase que contenga los _manejadores de señal_, los _slots_ y otros elementos que comentaremos posteriomente.




En el constructor de la clase anterior, para cada señal que se quiere manejar, se usa la llamada al sistema `[socketpair](http://linux.die.net/man/2/socketpair)()` para crear una pareja de [sockets de dominio UNIX](http://es.wikipedia.org/wiki/Socket_Unix) anónimos conectados entre sí. Al estar conectados desde el principio, lo que se escribe en uno de los _sockets_ de la pareja se puede leer en el otro. Además se crea un objeto `[QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html)` para que gestione uno de los sockets de la pareja, con el objeto de detectar cuándo hay datos disponibles para ser leídos, en cuyo caso `[QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html)` envía la señal `[QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html)::[activated](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html#activated)()`.




Entonces el manejador de señal POSIX lo único que tiene que hacer cuando es invocado es escribir _algo_ en el _socket_ que no gestiona `[QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html)`.




Mientras que en el _slot_ al que conectamos la señal `[QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html)::[activated](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html#activated)()` se lee _lo escrito_ desde el manejador anterior en el _socket_, para después pasar a tratar la señal como creamos conveniente. Como este _slot_ es invocado desde el bucle de mensajes de la aplicación, podemos hacer cualquier acción que nos venga en gana, al contrario de lo que pasa dentro de un manejador de señal POSIX como `MyDaemon::termSignalHandler()`, donde sólo podemos invocar [unas pocas funciones](http://en.wikipedia.org/wiki/Unix_signal#POSIX_signals).




Por conveniencia, podemos añadir una función para asignar el manejador `MyDaemon::termSignalHandler` a la señal SIGTERM usando la llamada al sistema `[sigaction](http://linux.die.net/man/2/sigaction)()`. Recordemos que los métodos que se van a utilizar como manejadores se declaran como `static` para que puedan ser pasados como un puntero de función a la llamada al sistema `[sigaction](http://linux.die.net/man/2/sigaction)()`.




### Referencias

*   [QCoreApplication](http://qt-project.org/doc/qt-5.0/qtcore/qcoreapplication.html).
*   [QSocketNotifier](http://qt-project.org/doc/qt-5.0/qtcore/qsocketnotifier.html).
*   [Calling Qt Functions From Unix Signal Handlers](http://doc.qt.io/qt-5/unix-signals.html)
