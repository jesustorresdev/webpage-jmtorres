---
title: "Uso de la memoria como un dispositivo de E/S con QBuffer"
author: "Jesús Torres"
date: 2013-03-13T00:00:00.000Z

description: ""

subtitle: ""

image: "/posts/2013-03-13_uso-de-la-memoria-como-un-dispositivo-de-es-con-qbuffer/images/1.png" 
images:
 - "/posts/2013-03-13_uso-de-la-memoria-como-un-dispositivo-de-es-con-qbuffer/images/1.png" 


aliases:
    - "/uso-de-la-memoria-como-un-dispositivo-de-e-s-con-qbuffer-19f70d7298a6"
---

Algunas libreras se diseñan específicamente para leer y/o escribir datos en dispositivos de entrada/salida.
Por ejemplo, una librería desarrollada en C++ para codificar y decodificar archivos MP3 recibiría objetos `[std::istream](http://www.cplusplus.com/reference/istream/istream/)` o `[std::ostream](http://www.cplusplus.com/reference/ostream/ostream/)` para indicar el flujo del que leer o en el que escribir los datos respectivamente:

*   `[std::istream](http://www.cplusplus.com/reference/istream/istream/)`
Clase de flujo de entrada.
Los objetos de esta clase pueden leer e interpretar la entrada de datos a partir de secuencias de caracteres.
*   `[std::ostream](http://www.cplusplus.com/reference/ostream/ostream/)`
Clase de flujo de salida.
Los objetos de esta clase pueden escribir secuencias de caracteres y representar como cadenas otras clases de datos.

{{< figure src="/posts/2013-03-13_uso-de-la-memoria-como-un-dispositivo-de-es-con-qbuffer/images/1.png" >}}



Por lo tanto, si deseáramos guardar o recuperar audio codificado en MP3 en un medio de almacenamiento concreto, necesitaríamos disponer de una clase que nos ofrezca el acceso al mismo a través de la interfaz de flujos de C++ de entrada/salida descrita por las clases anteriores.

Objetos como `[std::cin](http://www.cplusplus.com/reference/iostream/cin/)` y `[std::cout](http://www.cplusplus.com/reference/iostream/cout/)` son instancias de estas clases, lo que permitiría que nuestra aplicación codificara y decodificara audio hacia y desde la entrada/salida estándar del proceso.
Lo mismo ocurre con `[std::ifstream](http://www.cplusplus.com/reference/fstream/ifstream/)`, `[std::ofstream](http://www.cplusplus.com/reference/fstream/ofstream/)` y `[std::fstream](http://www.cplusplus.com/reference/fstream/fstream/)`; que heredan de las clases anteriores e implementan la interfaz de flujos de C++ para los archivos.
De esta manera nuestra hipotética librería de MP3 podría codificar y decodificar datos en este formato hacia y desde dichos archivos.

En este punto la cuestión que se nos plantea es ¿qué podríamos hacer si, por ejemplo, quisiéramos codificar el audio para posteriormente transmitirlo a otro ordenador a través de una red? Teniendo en cuenta lo comentado hasta ahora, una opción sería codificarlo almacenándolo en un archivo y posteriormente leer del mismo para transmitir los datos por la red.
Obviamente esto dista de ser ideal ya que sería preferible disponer de una clase que implementara la interfaz de `[std::ostream](http://www.cplusplus.com/reference/ostream/ostream/)` para almacenar los datos codificados directamente en la memoria, evitando tener que dar pasos intermedios, como por ejemplo guardarlos y leerlos de un archivo temporal.

Por fortuna la librería estándar de C++ nos provee de las clases:

*   `[std::istringstream](http://www.cplusplus.com/reference/sstream/istringstream/)`
Flujo de entrada para operar sobre cadenas.
Los objetos de esta clase permiten leer los caracteres del flujo de entrada a partir del contenido de un objeto `std::string`.
*   `[std::ostringstream](http://www.cplusplus.com/reference/sstream/ostringstream/)`
Flujo de salida para operar sobre cadenas.
Los objetos de esta clase permiten escribir los caracteres del flujo de salida en un objeto `std::string`.
*   `[std::stringstream](http://www.cplusplus.com/reference/sstream/stringstream/)`
Flujo para operar sobre cadenas.
Los objetos de esta clase permiten leer y escribir en un objeto `std::string`.

ofreciéndonos una forma sencilla de almacenar o leer de la memoria del proceso los datos codificados en MP3, lo que facilitaría cualquier tarea que quisiéramos realizar con ellos posteriormente.

### QIODevice

En el _framework_ [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) ocurre algo muy parecido.
Todas las clases diseñadas para acceder a dispositivos de entrada/salida reciben un objeto de la clase `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.
Por ejemplo:

*   `[QTextStream](http://qt-project.org/doc/qt-5.0/qtcore/qtextstream.html)`
Proporciona una interfaz adecuada para leer y escribir datos en formato texto desde un `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.
*   `[QDataStream](http://qt-project.org/doc/qt-5.0/qtcore/qdatastream.html)`
Proporciona una interfaz adecuada para leer y escribir datos binarios desde un `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.
*   `[QImageReader](http://qt-project.org/doc/qt-5.0/qtgui/qimagereader.html)`
Proporciona una interfaz independiente del formato para leer archivos de imágenes desde un dispositivo `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.
*   `[QImageWriter](http://qt-project.org/doc/qt-5.0/qtgui/qimagewriter.html)`
Proporciona una interfaz independiente del formato para escribir archivos de imágenes desde un dispositivo `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.
*   `[QMovie](https://jmtorres.webs.ull.es/me/2013/02/como-usar-qmovie-en-qt/)`
Es una clase diseñada para reproducir películas leídas con `[QImageReader](http://qt-project.org/doc/qt-5.0/qtgui/qimagereader.html)` desde un `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`.

La clase `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)` no se instancia directamente para crear objetos, sino que su función es definir una interfaz genérica válida para todo tipo de dispositivos de entrada/salida.
En el _framework_ [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) diversas clases heredan de esta, implementando la interfaz `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)` para un dispositivo concreto:

*   `[QTcpSocket](http://qt-project.org/doc/qt-5.0/qtnetwork/qtcpsocket.html)`
Es una clase heredera de `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)` que permite establecer una conexión TCP y transferir flujos de datos a través de ella.
*   `[QFile](http://qt-project.org/doc/qt-5.0/qtcore/qfile.html)`
Es una clase heredera de `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)` para leer y escribir archivos de texto y binarios, así como [recursos de la aplicación](http://qt-project.org/doc/qt-5.0/qtcore/resources.html).
*   `[QProcess](http://qt-project.org/doc/qt-5.0/qtcore/qprocess.html)`
Es una clase heredera de `[QIODevic](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`[e](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html) que permite ejecutar un programa externo y comunicarnos con él.
*   `[QBuffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html)`
Es una clase heredera de `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)` que implementa dicha interfaz de dispositivos sobre un `[QByteArray](http://qt-project.org/doc/qt-5.0/qtcore/qbytearray.html)`.
Ésta es una clase que provee una interfaz para manipular un _array_ de bytes en la memoria.

## Ejemplos con imágenes

Para ilustrar lo comentado vamos a codificar y decodificar una imagen `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` directamente desde la memoria.

## Codificando una imagen en la memoria

Supongamos que `image` es un objeto `[QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html)` que queremos codificar en formato PNG, guardando el resultado en un _array_ en la memoria para su procesamiento posterior --- por ejemplo para transmitirlo a través de una red de comunicaciones --- .

Hacerlo es tan sencillo como incorporar las siguientes líneas al programa:

{{< highlight >}}
QBuffer buffer;  
image.save(&buffer, "png");
{{< / highlight >}}

Como hemos comentado, `[QBuffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html)` es un clase heredada de `[QIODevice](http://qt-project.org/doc/qt-5.0/qtcore/qiodevice.html)`, por lo que podemos usarla allí donde se requiera un dispositivo de entrada/salida.
Por defecto los objetos de `[QBuffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html)` se crean con un _buffer_ interno de tipo `[QByteArray](http://qt-project.org/doc/qt-5.0/qtcore/qbytearray.html)`, al que podemos acceder directamente invocando el método `[QBuffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html)::[buffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html#buffer)()`.
Por ejemplo:

{{< highlight >}}
QByteArray bytes = buffer.buffer();
// Guardamos en un string los primeros 6 bytes de la imagen en PNG  
std::string pngHeader(bytes.constData(), 6);  
std::cout << pngHeader << std::endl;`
{{< / highlight >}}`

lo que mostraría por la salida estándar algo como lo siguiente:
`�PNG`

Esta forma de guardar los datos es adecuada cuando no necesitamos más control sobre las opciones del formato en cuestión.
Si por el contrario queremos controlar el nivel de compresión, el de gamma o algunos otros parámetros específicos del formato, tendremos que emplear un objeto `[QImageWriter](http://qt-project.org/doc/qt-5.0/qtgui/qimagewriter.html)`:

{{< highlight >}}
QBuffer buffer;  
QImageWriter writer(&buffer, "jpeg");  
writer.setCompression(70);  
writer.write(image):
{{< / highlight >}}

### Decodificando una imagen almacenada en la memoria

Ahora vamos a hacerlo en sentido inverso.
Si tenemos un puntero `const char* bytes` a una zona de memoria con `size` bytes donde se almacena una imagen en formato PNG y queremos cargarla en un objeto `QImage`, sólo tenemos que asignar los datos a un objeto `QBuffer` y leer desde el:

{{< highlight >}}
QBuffer buffer;  
buffer.setData(bytes, size);  
QImage image();  
image.setDevice(&buffer);  
image.setFormat("png");  
image.read();
{{< / highlight >}}

o lo que es equivalente y mucho más simple:

{{< highlight >}}
QByteArray buffer(bytes, size);  
QImage image();  
image.loadFromData(buffer, "png");
{{< / highlight >}}

## Referencias

1.  [QBuffer](http://qt-project.org/doc/qt-5.0/qtcore/qbuffer.html).
2.  [QByteArray](http://qt-project.org/doc/qt-5.0/qtcore/qbytearray.html).
3.  [QImage](http://qt-project.org/doc/qt-5.0/qtgui/qimage.html).
4.  [QImageReader](http://qt-project.org/doc/qt-5.0/qtgui/qimagereader.html).
5.  [QImageWriter](http://qt-project.org/doc/qt-5.0/qtgui/qimagewriter.html).
