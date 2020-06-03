---
title: "Introducción al uso de hilos en Qt"
author: "Jesús Torres"
date: 2013-02-16T00:00:00.000Z
lastmod: 2020-06-03T11:41:05+01:00

description: ""

subtitle: ""

image: "/posts/2013-02-16_introducción-al-uso-de-hilos-en-qt/images/1.jpg" 
images:
 - "/posts/2013-02-16_introducción-al-uso-de-hilos-en-qt/images/1.jpg" 


aliases:
    - "/introducci%C3%B3n-al-uso-de-hilos-en-qt-458d63342a31"
---

![image](/posts/2013-02-16_introducción-al-uso-de-hilos-en-qt/images/1.jpg)

[Colorful Threads](http://www.flickr.com/photos/prashant_sh/3965274345/) — [Prashant Shrestha](http://www.flickr.com/people/13978609@N08), License [CC-BY-2.0](https://creativecommons.org/licenses/by/2.0/deed.en).

Debido a la existencia del bucle de mensajes, no se pueden ejecutar tareas de larga duración en los _slots_. Si lo hiciéramos la ejecución tardaría en volver al bucle de mensajes, retrasando el momento en el que la aplicación puede procesar nuevos eventos de los usuarios.

Por eso lo habitual es que desde los _slots_ se deleguen esas tareas a hilos de trabajo — o _worker thread_ — de tal manera que se ejecuten mientras el hilo principal sigue procesando los eventos que lleguen a la aplicación.

### Gestionar hilos con Qt

Para usar hilos en [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) se utiliza la clase [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html), donde cada instancia de dicha clase representa a un hilo de la aplicación.

Crear un hilo es tan sencillo como heredar la clase [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html) y reimplementar el método [run](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#run)() insertando el código que queremos que ejecute el hilo. En este sentido el método [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html)::[run](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#run)() es para el hilo lo que la función `main()` es para la aplicación.




Una vez instanciada la clase, iniciar el nuevo hilo es tan sencillo como invocar el método [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html)::[start](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#start)().
``MyThread thread;  
thread.start()``

El hilo terminará cuando la ejecución retorne de su método MyThread::[run](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#run)() o si desde el código del hilo se invocan los métodos [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html)::[exit](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#exit)() o [QThread](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html)::[quit](http://qt-project.org/doc/qt-5.0/qtcore/qthread.html#quit)().

### Problema del buffer finito

Generalmente los hilos no se crean directamente en los _slots_ en los que son necesarios, sino en la función `main()`, en el constructor de la clase de la ventana que los va a utilizar o en otros sitios similares. Eso se así por una cuestión de eficiencia, ya que crear y destruir hilos según cuando son necesarios tiene cierto coste.

La única cuestión es que entonces un _slot_ debe poder entregar la tarea al hilo correspondiente que ha sido creado previamente. Como todos los hilos comparten la memoria del proceso, esto no debe ser un problema, pero realmente entraña ciertas dificultades relacionadas con la concurrencia.

Para ilustrarlo supongamos que hemos abierto un archivo de vídeo para procesarlo y que un _slot_ de la clase de la ventana es invocado cada vez que se dispone de un nuevo _frame__[_1_](#fn-500-1)_. La función del _slot_ sería la de transferir al hilo el _frame_ para que se haga cargo de su procesamiento. Teniendo esto en cuenta, el problema al que nos enfrentamos podría ser descrito de la siguiente manera:

*   El _slot_ obtiene los _frames_, por lo que sería nuestro _productor_. Como se ejecuta desde el bucle de mensajes sabemos que siempre lo hace dentro del hilo principal del proceso.
*   El hilo de trabajo encargado del procesamiento sería nuestro _consumidor_, ya que toma los _frames_ entregados por el productor.
*   Ambos comparten un _buffer_ de _frames_ de tamaño fijo que se usa a modo de cola circular. El _productor_ insertaría los _frames_ en la cola mientras el _consumidor_ los extraería.
*   No será un problema que el _productor_ añada más _frames_ de los que caben en la cola porque la cola será circular. Es decir, aunque se llene se siguen añadiendo _frames_ sobrescribiendo los más antiguos. Es preferible perder _frames_ a hacer crecer la cola, retrasando cada vez más el procesamiento de los nuevos _frames_, hasta quedarnos sin memoria. Para que esto funcionen _productor_ y _consumidor_ tendrán que compartir las posiciones del primer y último elemento de la cola.
*   Si habrá que controlar que el _consumidor_ no intente extraer más _frames_ cuando ya no queden.

Para que todo esto funcione correctamente vamos a necesitar una serie de elementos de sincronización que ayuden a ambos hilos a coordinarse:

*   Un cerrojo — o _mutex_ — de exclusión mutua [QMutex](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html) que serialice la ejecución del código en ambos hilos que manipulan la cola y su contador. La idea es que mientras uno de los hilos esté manipulando la cola, el otro tenga que esperar.
*   Una condición de espera [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html) para que el _consumidor_ pueda dormir mientras la cola esté vacía. La siguiente vez que el productor inserte un _frame_ en la cola, utilizaría la condición de espera para notificar al consumidor que puede volver a extraerlos.

Teniendo todo esto presente, a continuación desarrollamos un posible solución.

#### La clase FiniteBuffer

Vamos a encapsular el _buffer_ compartido dentro de una clase propia, de tal forma que el acceso al mismo sólo pueda realizarse usando los métodos seguros que implementaremos.

*   `void insertFrame(const QImage&amp; frame)
`Insertar la imagen `frame` en el buffer de _frames_.
*   `QImage extractFrame()
`Extraer el _frame_ más antiguo del _buffer_.

Como ya hemos comentado, los hilos deben compartir: la cola, las posiciones del primer y ultimo elemento de la cola y una serie de objetos de sincronización:




que debemos inicializar adecuadamente en el constructor de nuestra nueva clase:
``FiniteBuffer::FiniteBuffer(int size)  
    : buffer_(size), numUsedBufferItems_(0),  
      bufferHead_(-1), bufferTail_(-1)  
{}``

#### El productor

El código en el _slot_ de la ventana principal llamado cada vez que se dispone de un nuevo _frame_ podría tener el siguiente aspecto:




siendo el método `FiniteBuffer::insertFrame()` el siguiente:




Donde la instancia `lock` de la clase [QMutexLocker](http://doc.qt.io/qt-5/qmutexlocker.html) sirve para evitar que el _productor_ y el _consumidor_ accedan al contador compartido al mismo tiempo. Concretamente:

*   El primero en crea el objeto [QMutexLocker](http://doc.qt.io/qt-5/qmutexlocker.html) obtiene el cerrojo `mutex`. Si un segundo hilo llega a ese método mientras el otro tiene el cerrojo, simplemente se duerme a la espera de que el cerrojo sea liberado por el primero.
*   El salir del método se libera el cerrojo `mutex`. En ese momento uno de los hilos que espera obtener el cerrojo se despierta y lo obtiene, continuación con su ejecución.

Usar [QMutexLocker](http://doc.qt.io/qt-5/qmutexlocker.html) equivalente a llamar directamente a [QMutex](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html)::[lock](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html#lock)() y [QMutex](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html)::[unlock](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html#unlock)() para obtener y liberar el cerrojo `mutex`. Sin embargo, es mejor utilizar [QMutexLocker](http://doc.qt.io/qt-5/qmutexlocker.html) siempre porque reduce las posibilidades de cometer el error de olvidarnos de liberar `mutex`.

Por otro lado las instancias de condiciones de espera [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html) permiten dormir un hilo hasta que se de una condición determinada. Como se verá más adelante, _consumidor_ utiliza el método [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html)::[wait](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html#wait)() para dormir si la cola está vacía. Antes de hacerlo libera temporalmente el cerrojo `mutex_`, permitiendo que el _productor_ se pueda ejecutar en el código que protege.

El _productor_ utiliza el método [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html)::[weakAll](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html#weakAll)() después de insertar un elemento con el objeto de despertar al consumidor. Obviamente este deberá bloquear el cerrojo `mutex_` antes de volver del método [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html)::[wait](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html#wait)().

#### El consumidor

El código del hilo consumidor podría tener el siguiente aspecto:




donde el código del método `FiniteBuffer::removeFrame()` es muy similar al de inserción:




#### El constructor de la ventana principal

Finalmente es en constructor de ventana principal del programa `MyWindow` donde debe crearse el buffer `FiniteBuffer` y el hilo encargado del procesamiento de los _frames_. Es decir, nuestro consumidor.




### Referencias

*   [Como usar QMovie en Qt](https://jmtorres.webs.ull.es/me/2013/02/como-usar-qmovie-en-qt/)
*   [Starting Threads with QThread](http://doc.qt.io/qt-4.8/threads-starting.html)
*   [Wait Conditions Example](http://doc.qt.io/qt-5/qtcore-threads-waitconditions-example.html)
*   Wikipedia — [Producer-consumer problem](http://en.wikipedia.org/wiki/Producer-consumer_problem)
*   Un ejemplo de cómo usar de esta manera [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) se trató en el artículo [Como usar QMovie en Qt](https://jmtorres.webs.ull.es/me/2013/02/como-usar-qmovie-en-qt/). [↩](#fnref-500-1)
