---
title: "\"Diseñando IoT\" en la revista EDN Europe"
author: "Jesús Torres"
#date: 2014-05-13T16:20:45.000Z

tags:
 - IoT

images:
 - "images/1.png" 

aliases:
 - "/diseñando-iot-en-la-revista-edn-europe-8e14ef6934"
 - "/posts/diseñando-iot-en-la-revista-edn-europe"
---

{{< figure src="images/1.png" >}}

[EDN Europe](http://www.edn-europe.com/) ha publicado un artículo en cuatro partes sobre el diseño de la **Internet de las Cosas (IoT)**:

* [Part 1 --- IoT Devices and Local Networks](http://www.edn.com/5G/4428131/Designing-IoT-Part-1-IoT-Devices-and-Local-Networks-)
* [Part 2 --- The Thing](http://www.edn.com/5G/4428905/Designing-IoT-Part-II-The-Thing)
* [Part 3 --- Internet Usage and Protocols](http://www.edn.com/5G/4429615/Designing-for-IoT-Part-III-Internet-Usage-and-Protocols)
* [Part 4 --- The Cloud](http://www.edn.com/5G/4429618/Designing-for-IoT-Part-IV-The-Cloud)

Hace mucho tiempo que me viene interesando este tema, pero la verdad es que mis conocimientos se limitan a algunas nociones acerca de las redes y los protocolos Xbee/Zigbee ---típicos de las redes de sensores--- y algunas placas y dispositivos usados en los nodos sensores, muchos de los cuales se han diseñado específicamente para mundo DIY ---p. ej. Arduino, Mbed, Electric imp, Raspberry Pi, BeagleBone y similares---.
Así que la verdad es que es muy interesante para quienes buscábamos una revisión de los temas más actuales y las principales tendencias en este campo, aunque adelanto que mi impresión es que realmente el artículo no está muy bien escrito.

## A destacar

Concretamente del artículo destacaría como aspectos más interesantes:

* **La recomendación que se hace de los procesadores para IoT usados según la funcionalidad del nodo en cuestión**.
En la [parte 2 del artículo](http://www.edn.com/5G/4428905/Designing-IoT-Part-II-The-Thing) el autor trata los modelos de procesadores ARM adecuados según la tarea y comenta los futuros procesadores de bajo consumo que trabajan cerca o por debajo de la tensión umbral de sus transistores.
Esto permite crear sistemas que tienen un rendimiento muy pobre ---se habla de decenas de kilohertz--- pero que al mismo tiempo tienen un consumo insignificante.
  Contradiciendo la máxima de que la mejor manera de ahorrar energía es hacer las tareas lo más rápido posible para después hacer que el procesador se duerma.
* **Los detalles sobre algunos protocolos de comunicación**.
En concreto me parecen muy interesantes, al igual que al autor, aquellos que buscan traer IPv6 al IoT; permitiendo que los nodos de la red de sensores se conecten de forma casi directa a otros dispositivos en Internet.

Algunos ejemplos de estos protocolos son:

* **6LoWPPAN** es un protocolo de [IETF](http://es.wikipedia.org/wiki/Internet_Engineering_Task_Force) que define una forma encapsular y comprimir cabeceras para permitir el envío y recepción de paquetes IPv6 sobre redes de sensores basadas en IEEE 802.15.4 ---que define el nivel físico y el control de acceso al medio del estándar ZigBee---.
Esto facilita que nodos de pequeño consumo con capacidades de procesamiento limitadas puedan participar directamente en la IoT.
* **ZigBee IP** es la aproximación de la ZigBee Alliance al problema de traer IPv6 a las redes malladas de sensores y su respuesta al empuje de 6LoWPAN por el creciente interés en poder usar directamente los protocolos IP en este tipo de redes.
ZigBee IP realmente configura una completa pila de protocolos para redes malladas sobre IEEE 802.15.4 a partir de estándares bien establecidos: 6LoWPAN, IPv6, PANA, RPL, TCP, TLS y UDP
* **CoAP** ---Constrained Application Protocol--- es un protocolo extremadamente ligero que trae la semántica de HTTP y la arquitectura RESTful a dispositivos con poca capacidad de procesamiento.
Hoy en día HTTP y RESTful son de uso extendido en la nube, pero no son adecuados para nodos de pequeño tamaño, bajo consumo y poca capacidad de procesamiento que operan sobre redes de sensores con altas tasas de error y un ancho de banda muy limitado.
Por eso la [IETF](http://es.wikipedia.org/wiki/Internet_Engineering_Task_Force) ha estandarizado este protocolo como un RESTful con restricciones, que opera sobre UDP --- que a su vez operaría sobre 6LoWPAN --- y es adecuado para conectar a nivel de aplicación dispositivos en redes de sensores.

## Protocolos de comunicación

En lo que respecta a los protocolos de comunicación, **para el autor del artículo la combinación ganadora será 6LoWPAN, por el lado de las redes de sensores, junto a algún protocolo ligero basado en IP ---como CoAP--- en el lado de los servicios de _backend_ en Internet**.

Si alguien se pregunta por el porqué de esa apuesta por 6LoWPAN y no por ZigBee IP, aunque este último parezca tener características superiores; en mi opinión la respuesta está relacionada con las licencias.
**La especificación ZigBee es gratuita solamente para propósitos no comerciales.**
Esto causa problemas a los desarrolladores de software libre porque el requisito de unirse a la ZigBee Alliance y pagar una cuota anual entra en conflicto con muchas licencias de software libre, incluida la GPL.
Aunque se les ha preguntado, la ZigBee Alliance ha rechazado hacer su licencia compatible con la GPL, por lo que los desarrolladores de Linux ---y no debemos olvidar que muchos sistemas empotrados usan en la actualidad ese sistema operativo--- prefieren usar soluciones basadas en la pila de protocolos TCP/IP antes que en ZigBee.

_Al escribir estas líneas, aún faltaba el último artículo, por lo que me quedé pendiente de que lo publicaran para actualizar convenientemente esta entrada._
_Al final, si bien creo que su lectura es interesante, no me parece que diga nada tan relevante como para destacarlo aquí._
