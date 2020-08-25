---
title: "Capturando secuencias de vídeo con Qt"
author: "Jesús Torres"
date: 2014-02-11T00:00:00.000Z

description: ""

subtitle: ""

image: "/posts/2014-02-11_capturando-secuencias-de-vídeo-con-qt/images/1.jpeg" 
images:
 - "/posts/2014-02-11_capturando-secuencias-de-vídeo-con-qt/images/1.jpeg" 
 - "/posts/2014-02-11_capturando-secuencias-de-vídeo-con-qt/images/2.png" 


aliases:
    - "/capturando-secuencias-de-v%C3%ADdeo-con-qt-497ccb6e459c"
---

{{< figure src="/posts/2014-02-11_capturando-secuencias-de-vídeo-con-qt/images/1.jpeg" caption="Ampex video tape --- [Sagie](http://www.flickr.com/people/n0thing/), License [CC-BY-SA-2.0](https://creativecommons.org/licenses/by-sa/2.0/)" >}}
[Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) incluye el módulo [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/qtmultimedia-index.html) para facilitar la manipulación de contenidos multimedia.
Entre otras cosas permite reproducir audio y vídeo y capturar desde dispositivos de adquisición soportados por el sistema operativo.

Como por defecto no viene activado, es necesario abrir el archivo `.pro` del proyecto y añadir la línea
``QT += multimedia multimediawidgets``

## Primeros pasos con la webcam

Capturar de una webcam es tan sencillo como crear un objeto `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)` e iniciar la captura mediante el método `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)::[start](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html#start)()`:
``QCamera* camera = new QCamera;  
camera->start();``

Por lo general suele ser interesante incorporar un visor en el que mostrar al usuario lo que la cámara está capturando.
Para simplificar esta tarea, [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) nos ofrece el control [QCameraViewfinder](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcameraviewfinder.html) que hereda del más genérico [QVideoWidget](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideowidget.html):
``QCamera* camera = new QCamera;  
QCameraViewfinder* viewfinder = new QCameraViewfinder;  
camera->setViewfinder(viewfinder);``

Como `[QCameraViewfinder](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcameraviewfinder.html)` --- al igual que otros controles de [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/qtmultimedia-index.html) --- no está disponible en Qt Designer, tendremos que colocarlo en nuestra ventana desde el propio código.
Por ejemplo como el control central de la misma:
``viewfinder->setSizePolicy(QSizePolicy::Maximum, QSizePolicy::Maximum);  
setCentralWidget(viewfinder);``



![Organización de controles en la ventana principal](http://qt-project.org/doc/qt-5/images/mainwindowlayout.png)



Hecho esto, finalmente, podemos iniciar la cámara:
``// camera->setCaptureMode(QCamera::CaptureVideo);  
camera->setCaptureMode(QCamera::CaptureViewfinder);  
camera->start();``

## Acceder a un dispositivo específico

En un mismo sistema pueden haber varios dispositivos de captura, de tal forma que puede ser necesario crear un objeto `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)` para un dispositivo concreto.
En ese caso simplemente tenemos que indicarlo en el constructor:
``QCamera* camera = new QCamera("/dev/video0");``

Obviamente para hacerlo necesitamos conocer la lista de los dispositivos disponibles en el sistema.
Esto se puede hacer a través del método `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)::[availableDevices](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html#availableDevices)()`.
Al igual que se puede obtener para cada uno de ellos un texto más descriptivo, principalmente de cara a los usuarios, usando `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)::[deviceDescription](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html#deviceDescription)()`:
``QList devices = QCamera::availableDevices();  
qDebug() << "Capturando de... "  
         << QCamera::deviceDescription(devices[0]);  
QCamera* camera = new QCamera(devices[0]);``

## Accediendo a los frames individualmente

En el módulo [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/qtmultimedia-index.html) cada objeto de la clase `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` representa un _frame_ de vídeo.

### La clase QVideoFrame

El motivo por el que no se usa para esto la clase `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` es porque `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` no siempre contiene los datos de los píxeles del _frame_, como sí ocurre con la clase `[QImage](http://qt-project.org/doc/qt-5/qimage.html)`.

Cada sistema operativo tiene su propio API multimedia que tiene una manera particular de gestionar los _buffers_ de memoria --- por ejemplo, como una textura en OpenGL, como un _buffer_ de memoria compartida en XVideo, como una CImage en MacOS X, etc --- .
Estos _buffers_ suelen ser internos al API, así que las aplicaciones los identifican a través de manejadores o _handlers_.
Copiar los datos de los píxeles desde los _buffers_ internos a la memoria del programa suele tener cierto coste, por lo que `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` evita hacerlo, a menos que el programador lo solicite.
Esto tiene una serie de implicaciones para nuestros fines:

*   Por lo general `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` no contiene los datos de los píxeles sino un manejador al _buffer_ interno del API donde están almacenados.
Dicho manejador se puede obtener a través del método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[handle](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#handle)()`.
*   Para conocer el tipo de manejador --- algo que depende del API nativo que esté usando el módulo [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/qtmultimedia-index.html) --- se puede usar el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[handleType](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#handletype)()`.
*   Para acceder al contenido de los píxeles se puede usar el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[bits](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#bits)()` pero primero hay que asegurarse de que dichos datos son copiados desde el _buffer_ interno a la memoria del programa.
Eso se hace invocando previamente el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[map](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#map)()`.
Cuando el acceso a estos datos ya no es necesario se debe usar el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[unmap](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#unmap)()` para liberar la memoria.
*   El contenido de los objetos `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` se comparte explícitamente, por lo que cualquier cambio en un _frame_ será visible en todas las copias.

### Ganar acceso a los frames

Si estamos interesados en procesar los _frames_ capturados, la forma más sencilla --- aunque no la única --- es crear nuestro propio visor para la cámara.
El método `[QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html)::[setViewfinder](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html#setViewfinder)()` admite un puntero a objetos de la clase `[QAbstractVideoSurface](http://qt-project.org/doc/qt-5.0/qtmultimedia/qabstractvideosurface.html)`, que define la interfaz genérica para las superficies que saben como mostrar vídeo.
Por lo que será esa la clase de la que heredaremos la nuestra:




De tal forma que sólo tenemos que instanciarla y configurarla como visor de nuestra cámara.
``CaptureBuffer* captureBuffer = new CaptureBuffer;  
camera->setViewfinder(captureBuffer);``

### Convertir objetos QVideoFrame en QImage

A través del método `present()` de nuestra clase `CaptureBuffer` obtenemos los _frames_ capturados.
Sin embargo estos son de poca utilidad si no podemos acceder al contenido de los píxeles.
Así que vamos a convertir el objeto `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)` en un objeto `[QImage](http://qt-project.org/doc/qt-5/qimage.html)`.

Como ya sabemos, `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` tiene diversos constructores.
Entre ellos el siguiente:
``QImage (const uchar *buffer, int width, int height,  
        int bytesPerLine, QImage::Format format)``

que permite crear un objeto `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` si tenemos:

*   El ancho --- width --- y el alto --- height --- del frame.
Esto lo podemos obtener a través de los métodos `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[width](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#width)()` y `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[width](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#width)()`.
*   El número de bytes por línea --- bytesPerLine --- .
Para lo que tenemos el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[bytesPerLine](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#bytesperline)(`).
*   El formato de los píxeles --- format --- .
En este caso el método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[pixelFormat](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#pixelformat)()` proporciona dicho formato para el _frame_ y podemos convertirlo en uno equivalente de `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` usando `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[imageFormatFromPixelFormat](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#imageformatfrompixelformat)()`.
*   Un puntero al _buffer_ en memoria que contiene los datos de los píxeles.
Como comentamos anteriormente, `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[bits](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#bits)()` nos proporciona esa información pero primero tenemos que invocar al método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[map](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#map)()` para que dichos datos sean copiados desde el _buffer_ interno a la memoria del programa.``frame.map(QAbstractVideoBuffer::ReadOnly);  
QImage frameAsImage = QImage(frame.bits(), frame.width(),  
    frame.height(), frame.bytesPerLine(),  
    QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat()));````// Aquí el código que manipula frameAsImage...````frame.unmap();``

Hay que tener en cuenta que cuando se crea un objeto `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` de esta manera, no se hace una copia del contenido de los píxeles, por lo que es importante asegurarse de que el puntero devuelto por `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[bits](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#bits)()` es válido mientras se esté haciendo uso del objeto.
Por eso se invoca al método `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[unmap](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#unmap)()` después de manipularlo y no antes.

Si se quiere conservar la imagen del objeto `[QImage](http://qt-project.org/doc/qt-5/qimage.html)` después de invocar a `[QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html)::[unmap](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html#unmap)()` es necesario hacer una copia usando, por ejemplo, `[QImage](http://qt-project.org/doc/qt-5/qimage.html)::[copy](http://qt-project.org/doc/qt-5/qimage.html#copy)()`.

## Referencias

*   [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/qtmultimedia-index.html)
*   [QCamera](http://qt-project.org/doc/qt-5.0/qtmultimedia/qcamera.html) Class Reference.
*   [QVideoFrame](http://qt-project.org/doc/qt-5.0/qtmultimedia/qvideoframe.html) Class Reference.
*   [Video Overview](http://qt-project.org/doc/qt-5.0/qtmultimedia/videooverview.html)
