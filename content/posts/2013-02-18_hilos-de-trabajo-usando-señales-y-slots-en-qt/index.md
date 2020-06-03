---
title: "Hilos de trabajo usando señales y slots en Qt"
author: "Jesús Torres"
date: 2013-02-18T00:00:00.000Z
lastmod: 2020-06-03T11:41:07+01:00

description: ""

subtitle: ""

image: "/posts/2013-02-18_hilos-de-trabajo-usando-señales-y-slots-en-qt/images/1.jpg" 
images:
 - "/posts/2013-02-18_hilos-de-trabajo-usando-señales-y-slots-en-qt/images/1.jpg" 
 - "/posts/2013-02-18_hilos-de-trabajo-usando-señales-y-slots-en-qt/images/2." 


aliases:
    - "/hilos-de-trabajo-usando-se%C3%B1ales-y-slots-en-qt-445a1879f2e3"
---

![image](/posts/2013-02-18_hilos-de-trabajo-usando-señales-y-slots-en-qt/images/1.jpg)

Coloured Thread — [Philippa Willitts](https://flic.kr/p/4HyaDs), License [CC-BY-NC-2.0](https://creativecommons.org/licenses/by-nc/2.0/)

[Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) proporciona clases para hilos y mecanismos de sincronización que facilitan sacar las tareas de larga duración del hilo principal de la aplicación, lo que de lo contrario bloquearía la interfaz de usuario.

Una forma práctica de hacerlo la hemos visto [anteriormente](https://jmtorres.webs.ull.es/me/2013/02/introduccion-al-uso-de-hilos-en-qt/) utilizando un _buffer_ compartido. Sin embargo [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) provee a cada hilo de una cola de mensajes, lo que permite enviar señales a _slots_ en otros hilos. Esto nos proporciona una forma sencilla de pasar datos entre los hilos de la aplicación.

Si no se indica lo contrario, las señales emitidas desde un hilo a un objeto en el mismo hilo son entregadas directamente. Es decir, que al emitir la señal se invoca el _slot_ como si de un método convencional se tratara. Sin embargo si el emisor y el receptor residen en hilos diferentes, la señal es insertada en la cola de mensajes del hilo del objeto de destino. Así el _slot_ correspondiente será invocado en el hilo receptor desde su bucle de mensajes.

En la actualidad esta es la forma recomendada de usar hilos en [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) ya que permite evitar el uso de de mecanismos de sincronización como [QMutex](http://qt-project.org/doc/qt-5.0/qtcore/qmutex.html), [QWaitCondition](http://qt-project.org/doc/qt-5.0/qtcore/qwaitcondition.html), etc.

### El ejemplo. Ordenar números enteros

El ejemplo que vamos a seguir básicamente consiste en ordenar un vector de enteros en un hilo de trabajo distinto al hilo principal.

Como se puede observar en la figura utilizaremos dos objetos, uno vinculado al hilo principal (clase `Sorter`) y otro al hilo de trabajo (clase `SorterWorker`). En una aplicación gráfica convencional con [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) la clase `Sorter` podría ser una ventana o cualquier otro control que quiera ceder una tarea al hilo de trabajo. Aquí no lo haremos así para que el ejemplo sea lo más sencillo posible.




![Ejemplo de comunicación entre hilos en Qt](https://docs.google.com/drawings/d/1tZ0CMTNJoLsbHx3TjgecQuRXGEM5hf3pYwm9_s1R8bI/pub?w=960&amp;h=720)



En [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) un objeto se dice que vive en el hilo en el que es creado. Esto se puede cambiar utilizando el método `[moveToThread](http://qt-project.org/doc/qt-5.0/qtcore/qobject.html#moveToThread)()` que tienen todas las clases de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) que heredan de la clase base `[QObject](http://qt-project.org/doc/qt-5.0/qtcore/qobject.html)`.

### La clase Sorter




La propia clase `Sorter` se hará cargo de crear el hilo de trabajo, que por defecto lo único que hace es iterar en su propio bucle de mensajes. Todos los detalles acerca de la creación de hilos ya los vimos [anteriormente](https://jmtorres.webs.ull.es/me/2013/02/introduccion-al-uso-de-hilos-en-qt/)

La clase `Sorter` provee un método `sortAsync()` que podrá ser llamado por los clientes para ordenar un vector de números enteros. Puesto que la operación es asíncrona, necesitamos definir un _slot_ `vectorSorted()` para ser notificados cuando el ordenamiento haya finalizado con éxito.

La implementación de esta clase sería la siguiente:




Como se puede observar, en el constructor de `Sorter` se usa el método `qRegisterMetaType()`, antes de conectar las señales, para registrar el tipo `QVector&lt;int&gt;`. Esto debe hacerse porque cuando una señal es encolada sus parámetros deben ser de tipos conocidos para [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/), de forma que pueda almacenar los argumentos en la cola.

Por otro lado en el destructor de `Sorter` tenemos cuidado de detener el hilo de trabajo en condiciones seguras cuando ya no va a ser necesario. Si no lo hacemos así, el hilo podría ser destruido por el sistema operativo en cualquier punto de la secuencia de instrucciones al termina la aplicación, lo que podría dejar los datos en uso en un estado indeterminado.

### La clase SorterWorker




### Como usar el ejemplo

Para usar el ejemplo sólo necesitamos crear una instancia de `Sorter` y llamar a su método `sortAsync()` para pedir que ordene el vector especificado.




### Referencias

*   [Introducción al uso de hilos en Qt](https://jmtorres.webs.ull.es/me/2013/02/introduccion-al-uso-de-hilos-en-qt/)
*   [Worker Thread in Qt using Signals &amp; Slots](http://cdumez.blogspot.com.es/2011/03/worker-thread-in-qt-using-signals-slots.html)
