---
title: "Detección de movimiento con OpenCV"
author: "Jesús Torres"
date: 2013-02-19T00:00:00.000Z

description: ""

subtitle: ""

image: "/posts/2013-02-19_detección-de-movimiento-con-opencv/images/1.png" 
images:
 - "/posts/2013-02-19_detección-de-movimiento-con-opencv/images/1.png" 


aliases:
    - "/detecci%C3%B3n-de-movimiento-con-opencv-e9eb5818e871"
---

Detectar movimiento en una secuencia de vídeo es una tarea relativamente simple que puede abordarse en unos pocos pasos:

1.  **Supresión del fondo**
Consiste en estimar un modelo del fondo y compararlo con el _frame_ actual para detectar cambios
El resultado es una imagen binaria donde los píxeles se clasifican entre si forman parte del fondo o son del
primer plano.
2.  **Operaciones morfológicas**
En la imagen resultado de la operación anterior suelen aparecer regiones de pequeño tamaño marcadas como de primer plano debido al ruido en el _frame_ original
Una solución muy común en estos casos es aplicar operaciones de dilatación y erosión con el objeto de suprimirlas.
3.  **Extracción de blobs**
Los píxeles clasificados como de primer plano suelen agruparse en regiones que corresponden a objetos en movimiento en el _frame_ original
La _extracción de blobs_ permite identificar estas regiones para, por ejemplo, marcarlas con un cuadro delimitador en la imagen original.

## OpenCV

Los pasos a realizar son relativamente sencillos, por lo que no nos costaría mucho desarrollar nuestra propia implementación, ya que la mayor parte de ellos están perfectamente documentados de manera muy comprensible en Internet:

### **Supresión del fondo**:

*   Wikipedia --- [Detección de primer plano](http://es.wikipedia.org/wiki/Detecci%C3%B3n_de_primer_plano)

### **Operaciones morfológicas**

*   Wikipedia --- [Morfología matemática](http://es.wikipedia.org/wiki/Morfolog%C3%ADa_matem%C3%A1tica)
*   Johanna Carvajal --- [Operaciones Morfológicas](https://prezi.com/xlzctixq-qsu/operaciones-morfologicas/)

### **Extracción de blobs**

*   Wikipedia --- [Connected-component labeling](http://en.wikipedia.org/wiki/Blob_extraction)

Sin embargo existe una librería de visión por computador, denominada [OpenCV](http://opencv.org/), que permite que nos ahorremos todo este trabajo.




{{< figure src="/posts/2013-02-19_detección-de-movimiento-con-opencv/images/1.png" >}}



Además en estos casos siempre debemos tener presente que aunque se trate de algoritmos sencillos, siempre existen pequeñas cuestiones que deben ser tenidas en cuenta, fundamentalmente desde el punto de vista de la precisión de los algoritmos y del rendimiento, lo que puede dificultar el desarrollo
Por eso suele ser preferible utilizar una librería madura en lugar de hacer nuestra propia implementación.

## OpenCV y Qt

Si estamos desarrollando una aplicación gráfica en [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) debemos tomar una serie de medidas para poder emplear la librería [OpenCV](http://opencv.org/) desde ella:

### Conversión de QImage en cv::Mat

Las imágenes de las que haremos uso son instancias de la clase `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)`, propia del _framework_ [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/)
Sin embargo las funciones, clases y métodos de [OpenCV](http://opencv.org/) esperan objetos `cv::Mat`
Para convertir entre un formato y otro podemos emplear el proyecto [QtOpenCV](https://github.com/dbzhang800/QtOpenCV) de [Debao Zhang](https://github.com/dbzhang800) (licencia [MIT](http://es.wikipedia.org/wiki/MIT_License))

Para utilizarlo sólo necesitamos:

1.  Descargar en el directorio del proyecto los archivos:

*   `[cvmatandqimage.cpp](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.cpp)`
*   `[cvmatandqimage.h](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.h)`
*   `[opencv.pri](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.h)`

1.  Abrir el archivo `.pro` del proyecto y añadir al final la línea:
2.  `include(opencv.pri)`

Los archivos `.pri` tienen el mismo formato que los `.pro` pero están pensados para ser incluidos por estos últimos.
En nuestro caso el archivo `[opencv.pri](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.h)` contiene información sobre como incorporar los archivos `[cvmatandqimage.cpp](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.cpp)` y `[cvmatandqimage.h](https://github.com/dbzhang800/QtOpenCV/raw/master/cvmatandqimage.h)` al proyecto, haciendo que las funciones por ellos definidas estén disponibles para nuestra aplicación.

Tal y como se comenta en el archivo `README.md` de [QtOpenCV](https://github.com/dbzhang800/QtOpenCV), en el proyecto se definen dos funciones:




que podemos usar para convertir objetos `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` a `cv::Mat` y viceversa.

### Incorporar la librería OpenCV al proyecto

Aunque ya hemos incorporado [QtOpenCV](https://github.com/dbzhang800/QtOpenCV) a nuestro proyecto para la conversión entre formatos de imagen, aun no hemos añadido la librería OpenCV propiamente dicha:

El archivo [opencv.pri](https://github.com/dbzhang800/QtOpenCV/raw/master/opencv.pri) incluido anteriormente facilita el añadir [OpenCV](http://opencv.org/) al proyecto.
Lo único que tenemos que hacer es editar el archivo `.pro` e incorporar al final la línea `add_opencv_modules(core video imgproc)`.
Si estamos trabajando en Windows, la línea a incorporar debe ser `add_opencv_modules(core video imgproc, 2.4.4)`, donde `2.4.4` debe sustituirse por el número de la versión actualmente instalada de OpenCV.
Esto es un requisito en dichos sistemas ya que ese número se usa para componer el nombre de las librerías `.dll` con las que debe enlazarse el ejecutable del proyecto.

En la [introducción](http://docs.opencv.org/modules/core/doc/intro.html) de [OpenCV](http://opencv.org/) se explica que el paquete está divido a su vez en distintos módulos o librerías, cada uno de los cuales está dedicado a un tipo de tarea específico.
En nuestro caso concreto el módulo _video_ incluye las clases y funciones de supresión del fondo que nos interesa utilizar, mientras que _imgproc_ contiene las operaciones morfológicas y de detección de contornos.

### Incorporar manualmente la librería OpenCV al proyecto

Si por cualquier motivo no estuviéramos haciendo uso de los archivos `.pri` tendríamos que incorporar la librería al proyecto manualmente:

En Linux y Mac OS X esto se puede hacer como un _paquete instalado en el sistema_:

1.  En el menú contextual del proyecto (botón derecho sobre el proyecto)
seleccionar **Add Library…/System package**.
2.  En el paso posterior indicar **opencv** como nombre del paquete.
Obviamente la librería tiene que haber sido instalada previamente usando el procedimiento usual de nuestra distribución.

Mientras que en Windows este recurso no existe, por lo que la librería suele incorporarse al proyecto como _librería externa_:

1.  En el menú contextual del proyecto (botón derecho sobre el proyecto) seleccionar **Add Library…/External library**.
2.  Indicar el archivo de la librería (_Library file_) que queremos incorporar y el directorio de cabeceras (_Include Path_).
Como lo estamos haciendo para Windows, sólo tenemos que tener marcada dicha opción en la lista de plataformas soportadas.
Por lo general:

*   Librerías en `C:\opencv\build\<ARQUITECTURA>\mingw\lib`:
*   `libopencv_core<VERSION>.dll.a`
*   `libopencv_video<VERSION>.dll.a`
*   Ruta de las cabeceras: `C:\opencv\build\include`

Para ambos sistemas, al terminar se nos abrirá el archivo `.pro` del proyecto con los cambios correspondientes realizados.
Debemos guardarlo para dar por finalizada la incorporación de la librería.

## QImage vs QPixmap

Una instancia de `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)` es una representación de una imagen optimizada para ser mostrada.
Esto significa que en muchos sistemas sus características dependen de las de la pantalla (p.
ej.
su profundida de color puede tener que ser la misma que la que actualmente tiene el adaptador gráfico: 8 bits, 16 bits, 32 bits, etc.) y que internamente se implementa mediante algún tipo de objeto del lado del servidor gráfico cuya función es representar a las imágenes de cara al resto del sistema de ventanas.
Por lo tanto, los píxeles de un objeto `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)` no son accesibles directamente por parte del aplicación.

Una instancia de `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` es una representación independiente del hardware de una imagen.
Básicamente permite leer y escribir imágenes desde un archivo y manipular los píxeles directamente, sin que las características actuales del adaptador gráfico tengan nada que ver.
Los datos de la imagen se almacenan en el lado de la aplicación, por lo que son accesibles a esta en todo momento.

Normalmente la clase `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` se utiliza para cargar una imagen desde un archivo, opcionalmente manipular los píxeles y después convertirla a un objeto `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)` para mostrarla en la pantalla.

En nuestro caso existen dos motivos fundamentales para utilizar `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` en lugar de `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)`:

*   Para convertir la imagen a un objeto `cv::Mat` de [OpenCV](http://opencv.org/) se necesita acceso a los datos de los píxeles.
Como hemos comentado, eso sólo es posible con la clase `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)`.
*   Generalmente un objeto `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)` encapsula el acceso a algún tipo de recurso del servidor gráfico, con el que la aplicación se comunica a través del hilo GUI (el hilo principal de la aplicación).
Puesto que en muchos sistemas operativos no es seguro comunicarse con el servidor gráfico a través de un hilo diferente a ese, cualquier manipulación de un objeto `[QPixmap](http://qt-project.org/doc/qt-5.0/qtgui/qpixmap.html)` fuera del hilo principal puede dar lugar a efectos inesperados.
Dado que queremos transferir las imágenes a un hilo de trabajo para su procesamiento, parece que lo más seguro es utilizar la clase `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)`.

## Detección de movimiento

Con acceso a las clases y funciones de [OpenCV](http://opencv.org/) desde nuestra aplicación, podemos pasar a resolver el problema que nos habíamos propuesto; detectar movimiento en una secuencia de vídeo.

Como ocurre con muchas otras tareas en el campo de la visión por computador, esta se puede resolver de múltiples maneras.
Además es muy común que en cada técnica posible haya una decena de parámetros que den resultados diferentes según como los ajustemos.

Nosotros nos centraremos en solución concreta:




Donde suponemos que previamente hemos convertido todas las imágenes de `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` a `cv::Mat` y las hemos almacenado en un vector.

Al final de cada iteración del bucle tenemos para cada imagen un vector de contornos, donde cada uno es un vector de puntos.
Con los contornos se pueden hacer múltiples operaciones.
Por ejemplo calcular el rectángulo que contiene a cada uno (_bounding box_) con `[cv::boundingRect](http://docs.opencv.org/modules/imgproc/doc/structural_analysis_and_shape_descriptors.html#boundingrect)()` para pintarlos sobre la imagen antes de mostrársela al usuario.

## Referencias

*   [OpenCV](http://opencv.org/)
*   [QtOpenCV](https://github.com/dbzhang800/QtOpenCV)
*   [QPixmap: It is not safe to use pixmaps outside the GUI thread](http://www.qtcentre.org/threads/41595-QPixmap-It-is-not-safe-to-use-pixmaps-outside-the-GUI-thread)
