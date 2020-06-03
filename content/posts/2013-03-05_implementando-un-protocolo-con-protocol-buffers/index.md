---
title: "Implementando un protocolo con Protocol Buffers"
author: "Jesús Torres"
date: 2013-03-05T00:00:00.000Z
lastmod: 2020-06-03T11:41:16+01:00

description: ""

subtitle: ""

image: "/posts/2013-03-05_implementando-un-protocolo-con-protocol-buffers/images/1.jpg" 
images:
 - "/posts/2013-03-05_implementando-un-protocolo-con-protocol-buffers/images/1.jpg" 


aliases:
    - "/implementando-un-protocolo-con-protocol-buffers-4996957952d"
---

![image](/posts/2013-03-05_implementando-un-protocolo-con-protocol-buffers/images/1.jpg)

C-3PO vs. Data (137/365) — [JD Hancock](https://flic.kr/p/834e93), License [CC-BY-2.0](https://creativecommons.org/licenses/by/2.0/)

[Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) es un mecanismo sencillo para serializar estructuras de datos, de tal forma que los datos así codificados pueden ser almacenados o enviados a través de una red de comunicaciones. Esto nos ofrece una forma sencilla de crear nuestro propio protocolo de comunicaciones, adaptado a las necesidades de un problema concreto.

Los pasos concretos para usar [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) son lo siguientes:

1.  Especificar la estructura de datos del mensaje del nuevo protocolo en un archivo `.proto`. Estos archivos se escriben utilizando un [lenguaje de descripción de interfaz](https://developers.google.com/protocol-buffers/docs/proto) que es propio de [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/).
2.  Ejecutar el compilador de [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/), para el lenguaje de la aplicación, sobre el archivo `.proto` con el objeto de generar las clases de acceso a los datos. Estas proporcionan _accesores_ para cada campo, así como métodos para serializar y deserializar los mensajes a y desde una secuencia de bytes.
3.  Incluir las clases generadas en nuestra aplicación y usarlas para generar instancias del mensaje, serializarlas y enviar los mensajes codificados o leer dichos mensajes, deserializarlos y reconstruir las instancias de los mensajes para acceder a sus campos.

### Definir la estructura del mensaje

Supongamos que conectados a una red tenemos un conjunto de [Arduinos](http://www.arduino.cc/) equipados con varios sensores de diferente tipo: temperatura, humedad, luminosidad, movimiento, etc. Cada [Arduino](http://www.arduino.cc/) tiene un nombre que lo identifica y su función es leer el estado de dichos sensores, a intervalos regulares, y enviar mensajes con los datos de los mismos a un servidor.

Teniendo esto presente, el archivo `.proto` podría ser el siguiente:




Como se puede observar el lenguaje usado en los archivos `.proto` es muy sencillo. Solamente hay que indicar el nombre y el tipo de cada campo, así como si es opcional (_optional_), requerido (_required_) o se repite (_repeated_).

En [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) los campos se etiquetan de manera única con un entero que después es utilizado en la codificación binaria para identificarlos.

### Clases de acceso a los datos

Una vez tenemos la definición de la estructura del mensaje, podemos invocar al compilador de [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) para generar las clases de acceso a los datos.

#### Desde línea de comandos

Desde línea de comandos generar las clases es tan sencillo como invocar el compilador de la siguiente manera:

`protoc --cpp_out=. sensorsreport.proto`

que genera los archivos `sensorsreport.pb.cc` y `sensorsreport.pb.h` en el directorio actual. Después se debe incluir el archivo de cabecera en nuestro código fuente allí donde vaya a ser utilizado:

`#include &#34;sensorsreport.pb.h&#34;`

Y finalmente compilar el ejecutable junto con el archivo `sensorsreport.pb.cc` y enlazar con la librería `protobuf`.

#### Con qmake

Si estamos usando `qmake` para construir nuestro proyecto (como es el caso cuando desarrollamos con el IDE Qt Creator) lo más cómodo es que este se encargue de invocar al compilador [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) para generar las clases de acceso de forma automática.

En este sentido el archivo `protobuf.pri` del proyecto [ostinato](http://ostinato.org/) puede ser de gran ayuda con algunos cambios:




Para usarlo sólo tenemos que:

*   Crear el archivo `protobuf.pri` con el contenido anterior en el directorio del proyecto.
*   Abrir el archivo `.pro` del proyecto y añadir las líneas:``PROTOS = sensorsreport.proto  
include(protobuf.pri)  
LIBS += -lprotobuf``

Finalmente sólo tenemos que compilar el proyecto y obtendremos los archivos `sensorsreport.pb.cc` y `sensorsreport.pb.h` que hemos mencionado.

### Interfaz de Protocol Buffers

Si abrimos el archivo `sensorsreport.pb.h` veremos que la clase `SensorsReport` nos ofrece los siguientes _accesores_:




a los campos del mensaje. Además se define el `enum` `SensorsReport::SensorStatus` y la clase `SensorsReport::SensorStatus`.

Todos los detalles sobre el código generado por el compilador están documentados en la [referencia del código generado en C++](https://developers.google.com/protocol-buffers/docs/reference/cpp-generated). Eso incluye [los accesores creados](https://developers.google.com/protocol-buffers/docs/reference/cpp-generated#fields) según el tipo de definición de los campos.

Veamos algunos ejemplos.

#### Campos individuales de tipos básicos

Para definiciones de este tipo:
``optional int32 foo = 1;  
required int32 foo = 1;``

el compilador genera los siguientes _accesores_:

*   `bool has_foo() const`
Devuelve `true` si el campo `foo` tiene un valor.
*   `int32 foo() const`
Devuelve el valor del campo `foo`. Si el campo no tiene valor, devuelve el
valor por defecto.
*   `void set_foo(int32 value)`
Fija el valor del campo. Después de llamar a este método, llamar a `has_foo()` devolvería `true`.
*   `void clear_foo()`
Limpia el valor del campo. Después de llamar a este método, llamar a `has_foo()` devolvería `false`.

que nos permiten hacer cosas tales como:
``SensorsReport report;````report.set_devicename(&#34;ARDUINO01&#34;);  
report.set_timestamp(1362507283);````cout &lt;&lt; &#34;Device name: &#34; &lt;&lt; report.devicename() &lt;&lt; &#39;\n&#39;;  
cout &lt;&lt; &#34;Timestamp: &#34; &lt;&lt; report.timestamp() &lt;&lt; &#39;\n&#39;;``

#### Campos de tipos básicos con repeticiones

Mientras que para definiciones de este tipo:

`repeated int32 foo = 1;`

El compilador genera los siguientes _accesores_:

*   `int foo_size() const`
Devuelve el número de elementos en el campo.
*   `int32 foo(int index) const`
Devuelve el elemento en el índice indicado.
*   `void set_foo(int index, int32 value)`
Fija el valor del elemento en el índice indicado.
*   `void add_foo(int32 value)`
Añade un nuevo elemento con el valor indicado.
*   `void clear_foo()`
Elimina todos los elementos del campo.
*   `const RepeatedField&amp; foo() const`
Devuelve el objeto `RepeatedField`que almacena todos los elementos. Este contenedor proporciona iteradores al estilo de otros contenedores de la STL.

#### Campos de tipo mensaje embebido con repeticiones

Un mensaje puede contener campos cuyo tipo es otro _tipo de mensaje_. Son los denominados campos de tipo _mensaje embebido_. Por ejemplo, si queremos un campo que admita varios mensajes de tipo `MyMessage` —que a su vez es un mensaje— sólo tenemos que añadir lo siguiente:
``repeated MyMessage foo = 1;``

Entonces el compilador generá los siguientes _accesores_:

*   `int foo_size() const`
Devuelve el número de elementos en el campo.
*   `const MyMessage&amp; foo(int index) const`
Devuelve el elemento en el índice indicado.
*   `MyMessage* mutable_foo(int index)`
Devuelve un puntero al elemento mutable en el índice indicado.
*   `MyMessage* add_foo()`
Añade un nuevo elemento y devuelve un puntero a él con el valor indicado.
*   `void clear_foo()`
Elimina todos los elementos del campo.
*   `const RepeatedPtrField&amp; foo() const`
Devuelve el objeto `RepeatedPtrField` que almacena todos los elementos. Este contenedor proporciona iteradores al estilo de otros contenedores de la STL.
*   `RepeatedField* mutable_foo() const`
Devuelve un puntero al objeto `RepeatedPtrField` mutable que almacena todos los elementos. Este contenedor también proporciona iteradores al estilo de otros contenedores de la STL, sólo que en este caso se puede usar para modificar los elementos almacenados.

que podemos usar de la siguiente manera:
``SensorsReport report;````SensorsReport::SensorsStatus* sensors = report.add_sensors();  
sensors-&gt;set_type(SensorsReport::TEMPERATURE);  
sensors&gt;set_value(25);````cout &lt;&lt; &#34;Temperature: &#34; &lt;&lt; sensors-&gt;value() &lt;&lt; &#39;\n&#39;;```Serialización y deserialización`

Cada clase de un mensaje ofrece un conjunto de métodos para codificar —serializar — y decodificar — deserializar — los mensajes:

*   `bool SerializeToString(string* output) const`
Serializa el mensaje y almacena los bytes en la cadena especificada en el argumento `output`. Nótese que estos bytes son binarios, no texto, y que la clase `std::string` se usa como un mero contenedor.
*   `bool ParseFromString(const string&amp;amp; data)`
Deserializa un mensaje codificado en la cadena especificada en el argumento `data`.
*   `bool SerializeToOstream(ostream* output) const`
Escribe el mensaje serializado en el flujo `ostream` indicado.
*   `bool ParseFromIstream(istream* input)`
Deserializa un mensaje leido del flujo `istream` indicado.

#### Almacenamiento y transmisión por red de múltiples mensajes

El formato de codificación de [Protocol Buffers](https://jmtorres.webs.ull.es/me/2013/03/protocol-buffers/) no está auto-limitado. Es decir, no incluye marcas que permitan identificar el principio y fin de los mensajes. Esto es un problema si se quieren almacenar o enviar varios mensajes en un mismo flujo de datos.

La forma más sencilla de resolverlo es comenzar escribiendo el tamaño del mensaje codificado y después escribir el mensaje en si mismo.
``// Serializar el mensaje  
std::string buffer;  
report.SerializeToString(&amp;buffer);  
uint32 bufferSize = buffer.size();````// Abrir el archivo de destino y escribir el mensaje  
//  
// std::ofstream ofs(...);  
//  
ofs.write(reinterpret_cast&lt;char*&gt;(&amp;bufferSize),  
sizeof(bufferSize));  
ofs.write(buffer.c_str(), bufferSize);``

Al leer, se lee primero el tamaño del mensaje, después leer los bytes indicados en un _buffer_ independiente y finalmente se deserializa el mensaje desde dicho _buffer_.
``// Abrir el archivo de origen y leer el tamaño del mensaje  
//  
// std::ifstream ifs(...);  
//  
uint32 bufferSize;  
ifs.read(&amp;bufferSize, sizeof(bufferSize));````// Leer el mensaje  
std::string buffer;  
buffer.resize(bufferSize);  
ifs.read(const_cast&lt;char*&gt;(buffer.c_str()), bufferSize);````// Deserializar  
report.ParseFromString(buffer);``

En la misma documentación de la librería se nos sugiere una solución más conveniente usando las clases `CodedInputStream` y `CodedOutputStream`:
> If you want to avoid copying bytes to a separate buffer, check out the CodedInputStream class (in both C++ and Java) which can be told to limit reads to a certain number of bytes.

### Referencias

*   [Protocol Buffers — Google Developers](https://developers.google.com/protocol-buffers/)
*   [Language Guide](https://developers.google.com/protocol-buffers/docs/proto)
*   [C++ Generated Code](https://developers.google.com/protocol-buffers/docs/reference/cpp-generated)
*   [protobuf — Protocol Buffers — Google’s data interchange format](http://code.google.com/p/protobuf/)
*   [Streaming Multiple Messages](https://developers.google.com/protocol-buffers/docs/techniques#streaming)
*   [Protocol Buffers — coded_stream.h](https://developers.google.com/protocol-buffers/docs/reference/cpp/google.protobuf.io.coded_stream)
*   [Stackoverflow — Are there C++ equivalents for the Protocol Buffers delimited I/O functions in Java?](http://stackoverflow.com/questions/2340730/are-there-c-equivalents-for-the-protocol-buffers-delimited-i-o-functions-in-ja)
*   [Stackoverflow — Length prefix for protobuf messages in C++](http://stackoverflow.com/questions/11640864/length-prefix-for-protobuf-messages-in-c)
