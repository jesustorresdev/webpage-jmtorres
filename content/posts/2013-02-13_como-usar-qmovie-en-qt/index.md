---
title: "Como usar QMovie en Qt"
author: "Jesús Torres"
date: 2013-02-13T00:00:00.000Z
lastmod: 2020-06-03T11:41:01+01:00

description: ""

subtitle: ""

image: "/posts/2013-02-13_como-usar-qmovie-en-qt/images/1.JPG" 
images:
 - "/posts/2013-02-13_como-usar-qmovie-en-qt/images/1.JPG" 


aliases:
    - "/como-usar-qmovie-en-qt-edc1b064c6e8"
---

![image](/posts/2013-02-13_como-usar-qmovie-en-qt/images/1.JPG)

Arriflex, cámara cinematográfica de 35mm — [Biswarup Ganguly](https://commons.wikimedia.org/wiki/User:Gangulybiswarup), License [CC-BY-3.0](https://creativecommons.org/licenses/by/3.0/deed.en)

[Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) trae una clase denominada [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) que facilita mostrar pequeñas animaciones sin mucho esfuerzo.

[QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) está diseñada para ser independiente del formato de archivo pero como internamente depende de [QImageReader](http://qt-project.org/doc/qt-5.0/qtgui/qimagereader.html), sólo puede utilizarse con los que esta última soporta — véase [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[supportedFormats](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#supportedFormats)() — . Esto incluye GIF animados, archivos MNG y MJPEG. Para mostrar vídeo y otros contenidos multimedia, es mejor utilizar el _framework_ [Qt Multimedia](http://qt-project.org/doc/qt-5.0/qtmultimedia/multimediaoverview.html).

#### Primeros pasos

La forma más sencilla de usar [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) es asignar un objeto [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) a un control [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html) usando el método [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html)::[setMovie](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html#setMovie)():
`QMovie *movie = new QMovie(&#34;video.mjpeg&#34;);  
ui-&gt;label-&gt;setMovie(movie);`

donde `ui` es el miembro de la clase que tiene asignada la instancia de la ventana creada previamente con Qt Creator.

#### Nombre de archivo especificado por el usuario

No siempre ocurre que el nombre del archivo a reproducir se conozca de antemano al desarrollar el programar. Si por ejemplo se pretende que el usuario lo escoja de entre los disponibles en su disco duro podemos crear un objeto [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html), guardarlo en un miembro de la clase — manteniendo así un puntero al mismo que nos permita referenciarlo más adelante — y asignar dicho objeto [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) a [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html):
`MovieViewerWindow::MovieViewerWindow(QWidget *parent)  
    : QMainWindow(parent),  
      ui(new Ui::MovieViewerWindow)  
{  
    movie_ = new QMovie();  
    ui-&gt;label-&gt;setMovie(movie_);  
}  

`

En el _slot_ de la acción que abre el cuadro de diálogo _abrir archivo_, asignamos al objeto [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) el nombre escogido por el usuario mediante el método [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[setFileName](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#setFileName)():
`void MovieViewerWindow::on_actionOpen_triggered()  
{  
    // Aquí el código que abre el cuadro de diálogo y comprueba si  
    // el usuario seleccionó algún archivo...  
    //  
    // QString fileName = QFileDialog::getFileName(...);  
    //  
    // ...  
    //``    movie_-&gt;setFileName(fileName);  
    if (!movie_-&gt;isValid()) {  
        QMessageBox::critical(this, tr(“Error”),  
            tr(&#34;No se pudo abrir el archivo o el formato &#34;  
               &#34;es inválido&#34;));  
        return;  
    }  
    movie_-&gt;start();    // Iniciar la reproducción de la animación  
}`

Como se puede observar es conveniente utilizar el método [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[isValid](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#isValid)() para comprobar si el archivo pudo ser abierto y tiene uno de los formatos soportados.

Para distinguir entre ambos tipos de error, con el objeto de mostrar al usuario un mensaje diferente según el caso, podemos emplear el método [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[device](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#device)(). Este devuelve el objeto [QFile](http://qt-project.org/doc/qt-5.0/qtcore/qfile.html) — realmente devuelva una instancia de [QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html), que es la clase base de [QFile](http://qt-project.org/doc/qt-5.0/qtcore/qfile.html) y de todas clases que representan dispositivos de E/S — vinculado con la instancia de [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html). Así podemos comprobar mediante el método [QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)::[isOpen](http://qt-project.org/doc/qt-5.0/qtcore/qfile.html#isOpen)() si el archivo se pudo abrir con éxito o no.

### Control de la reproducción

El control de la reproducción se puede hacer mediante los _slots_ [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)() y [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[stop](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#stop)().

En el ejemplo anterior se puede observar como el _slot_ [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)() es invocado exactamente de la misma manera que un método convencional para iniciar la reproducción de la animación. Sin embargo el hecho de que los desarrolladores de [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) lo hayan declarado como un _slot_ y no como un método nos permitiría conectarlo a una señal emitida desde otro control.

Por ejemplo, si tuviéramos un botón de _play_ podríamos conectar su señal [clicked](http://qt-project.org/doc/qt-5.0/qtwidgets/qabstractbutton.html#clicked)() al slot [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)() de la siguiente manera:
`connect(ui-&gt;playButton, SIGNAL(clicked()), movie_, SLOT(start()));`

de forma que al pulsar dicho botón se inicie automáticamente la reproducción.

Otro detalle a tener en cuenta es que los _slots_ [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)() y [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[stop](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#stop)() indican a la instancia de [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) que inicie o detengan la reproducción pero, una vez hecho, vuelven inmediatamente. Es decir, que no se quedan a la espera de que la animación se reproduzca o esperan a que termine.

Este es un detalle importante porque al _slot_ `on_actionOpen_triggered()` de nuestro ejemplo se llega a través del bucle de mensajes, cuando el sistema de ventanas notifica a la aplicación un _click_ sobre la acción correspondiente. Si en el _slot_ introdujéramos tareas de larga duración, la ejecución tardaría en volver al bucle de mensajes, retrasando el momento en el que la aplicación puede procesar nuevos eventos de los usuarios. Es decir, que si [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)() se quedara a la espera y añadiéramos un botón para detener la reproducción, este nunca funcionaría porque la aplicación no volvería al bucle de mensajes hasta que la reproducción no hubiera terminado.

Podemos comprobar esto añadiendo una espera justo después de invocar el _slot_ [start](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#start)():
`QWaitCondition sleep;  
QMutex mutex;  
sleep.wait(&amp;mutex, 2000);    // Espera de 2 segundos`

Debido a los efectos desastrosos que este tipo de esperas tienen en las aplicaciones dirigidas por eventos, [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) no incluye funciones del tipo de `sleep()`, `delay()`, `usleep()` y `nanosleep()`, que muchos sistemas operativos sí soportan.

### Procesando la imagen frame a frame

Aunque [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) se hace cargo de mostrar la animación sin que tengamos que intervenir de ninguna otra manera, en ocasiones puede ser interesante tener acceso a los _frames_ de manera individualizada para poder procesarlos antes de que sean mostrados. Por ese motivo [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) emite una señal [updated](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#updated)() cada vez que el _frame_ actual cambia.

Para aprovecharlo, declaramos un _slot_ para que reciba la señal [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[updated](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#updated)():
`private slots:  
    // Otros slots...  
    //  
    // void on_actionOpen_triggered();  
    //  
    // ...  
    //  
    void showFrame(const QRect&amp; rect);`

Definimos el código del _slot_ para que al ser invocado actualice la imagen mostrada por el control [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html). En ese sentido el método [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html)::[setPixmap](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html#setPixmap)() permite indicar al objeto [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html) que imagen queremos mostrar. Mientras que [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[currentPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#currentPixmap)() nos permite obtener el último _frame_ del objeto [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) en formato [QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html):
`void MovieViewerWindow::showFrame(const QRect&amp; rect)  
{  
    QPixmap pixmap = movie_-&gt;currentPixmap();  
    ui-&gt;label-&gt;setPixmap(pixmap);  
}`

Suprimimos el uso del método [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html)::[setMovie](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html#setMovie)(), para que el objeto [QLabel](http://qt-project.org/doc/qt-5.0/qtwidgets/qlabel.html) no sepa nada de nuestra animación, y conectamos la señal [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html)::[updated](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html#updated)() con nuestro nuevo slot:
`    movie_ = new QMovie();  
    // ui-&gt;label-&gt;setMovie(movie_);  
    connect(movie_, SIGNAL(updated(const QRect&amp;)),  
    this, SLOT(showFrame(const QRect&amp;)));  
}`

Ahora podríamos introducir en el _slot_ todo aquello que nos interese hacer sobre los _frames_ antes de mostrarlos.

### Referencias

1.  [QMovie](http://qt-project.org/doc/qt-5.0/qtgui/qmovie.html) Class Reference.
2.  [Moviel Example](http://doc.qt.io/qt-5/qtwidgets-widgets-movie-example.html)
3.  [Image Viewer Example](http://doc.qt.io/qt-5/qtwidgets-widgets-imageviewer-example.html)
