---
title: "Protocol Buffers"
author: "Jesús Torres"
date: 2013-03-02T00:00:00.000Z
lastmod: 2020-06-03T11:41:12+01:00

description: ""

subtitle: ""

image: "/posts/2013-03-02_protocol-buffers/images/1.jpg" 
images:
 - "/posts/2013-03-02_protocol-buffers/images/1.jpg" 


aliases:
    - "/protocol-buffers-f5b266783652"
---

![image](/posts/2013-03-02_protocol-buffers/images/1.jpg)

Google — [Trevor Devine](https://flic.kr/p/okeMB), License CC-BY-NC-2.0

[Protocol Buffers](http://code.google.com/p/protobuf/) es una herramienta para la serialización de estructuras de datos. La serialización es un proceso de codificación de un objeto en un medio de almacenamiento — como puede ser una archivo o un buffer en memoria — en ocasiones para transmitirlo a través de una conexión de red o para preservarlo entre ejecuciones de un programa. La serie de bytes que codifican el estado del objeto tras la serialización puede ser usada para crear un nuevo objeto, idéntico al original, tras aplicar el proceso inverso de deserialización.

[Protocol Buffers](http://code.google.com/p/protobuf/) básicamente provee una manera sencilla de definir la estructura de los datos, pudieron entonces generar código capaz de leer y escribir dichos datos de manera eficiente, desde diferentes lenguajes y en una variedad de distintos tipos de flujos de datos.

Fue desarrollado internamente por Google para almacenar e intercambiar todo tipo de información estructurada. Hasta el punto de que sirve de base para un sistema de [llamada a procedimiento remoto](http://es.wikipedia.org/wiki/Remote_Procedure_Call) o [RPC](http://es.wikipedia.org/wiki/Remote_Procedure_Call) (Remote Procedure Call) propio que es usado prácticamente para todas las comunicaciones entre equipos en Google.

En su momento Google hizo generadores de código de [Protocol Buffers](http://code.google.com/p/protobuf/) para C++, Java y Python y liberó la herramienta con una licencia [BSD](http://es.wikipedia.org/wiki/Licencia_BSD)

### Alternativas

La idea detrás de [Protocol Buffers](http://code.google.com/p/protobuf/) es muy similar a la que dio origen a [XML](http://en.wikipedia.org/wiki/XML), solo que en este caso el formato es binario, compacto y pone énfasis en la velocidad a la hora de serializar[1](#fn-489-1) y deserializar los datos. Además es muy similar a [Apache Thrift](http://en.wikipedia.org/wiki/Apache_Thrift) — creado y usado internamente por Facebook — o [Apache Avro](http://en.wikipedia.org/wiki/Apache_Avro), excepto porque [Protocol Buffers](http://code.google.com/p/protobuf/) no define un protocolo [RPC](http://es.wikipedia.org/wiki/Remote_Procedure_Call) concreto, sino sólo como deben empaquetarse los datos.

Si se quiere definir un servicio [RPC](http://es.wikipedia.org/wiki/Remote_Procedure_Call) que haga uso de un protocolo que se apoye sobre [Protocol Buffers](http://code.google.com/p/protobuf/) para el intercambio de datos, existen [diversas implementaciones RPC](http://code.google.com/p/protobuf/wiki/ThirdPartyAddOns#RPC_Implementations) para distintos lenguajes de programación.

### Referencias

1.  [protobuf — Protocol Buffers — Google’s data interchange format](http://code.google.com/p/protobuf/).
2.  [Protocol Buffers — Google Developers](https://developers.google.com/protocol-buffers/)
3.  Wikipedia — [Protocol Buffers](http://en.wikipedia.org/wiki/Protocol_Buffers).
