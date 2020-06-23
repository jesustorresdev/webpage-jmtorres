---
title: "Visor de realidad virtual DIYVR"
author: "Jesús Torres"
date: 2015-01-04T22:00:56.000Z

summary: "El pasado 10 de diciembre terminó la [campaña de financiación de DIYVR en Kickstarter. Apenas unas semanas después, me llegó mi «recompensa» por colaborar."

tags:
 - VR
 - Móvil

featuredImage: "/posts/visor-de-realidad-virtual-diyvr/images/1.png" 
images:
 - "/posts/visor-de-realidad-virtual-diyvr/images/1.png" 
 - "/posts/visor-de-realidad-virtual-diyvr/images/2.jpg" 
 - "/posts/visor-de-realidad-virtual-diyvr/images/3.jpg" 
 - "/posts/visor-de-realidad-virtual-diyvr/images/4.jpg" 
 - "/posts/visor-de-realidad-virtual-diyvr/images/5.jpg" 

aliases:
 - "/visor-de-realidad-virtual-diyvr-b5cb09aab875"
---

_Escena de la película [Johnny Mnemonic (1995)](https://www.youtube.com/watch?v=Uwl5MBzTCRQ)._
____

El pasado 10 de diciembre terminó la [campaña de financiación de DIYVR en Kickstarter](https://www.kickstarter.com/projects/dodocase/diy-virtual-reality-open-source-future) con notable éxito.
De los 25.000$ propuestos como objetivo para este visor de realidad virtual hecho con cartón, consiguieron 62.909$ para llevar acabo el proyecto.
Así que hoy, apenas unas semanas después, me llegó mi «recompensa» por colaborar.

La idea del proyecto era muy sencilla, hacer la realidad virtual accesible a cualquiera.
Para eso [DODOcase](http://www.dodocase.com/) ---empresa dedicada a la venta de estuches fundas para móviles y tablets--- se asoció con Tony Parisi ---coautor de [VRML](http://en.wikipedia.org/wiki/VRML)---.
Los primeros ofrecieron [visores de cartón para móviles](http://www.dodocase.com/products/google-cardboard-vr-goggle-toolkit), al estilo de la famosa [Google Cardboard](https://www.google.com/get/cardboard/).
El segundo el proyecto [GLAM](http://tparisi.github.io/glam/#/home), cuya función es cubrir el lado software para desarrollar de forma sencilla aplicaciones de realidad virtual, y cuyo desarrollo se financiará con los beneficios obtenidos en [Kickstarter](http://www.kickstarter.com).

Lo interesante de [GLAM es que es un lenguaje declarativo](http://es.slideshare.net/auradeluxe/glam-35009205) que busca hacer que la creación de contenido 3D para la web sea tan sencilla como lo es crear otro tipo de contenidos con HTML5, CSS y Javascript.
GLAM usa un lenguaje de marcas similar a HTML5 para definir los objetos de la escena, extiende CSS para que se pueda usar para indicar los estilos y las animaciones y ofrece un API basado en DOM para manipular los objetos y manejar eventos desde Javascript.

## Desempaquetando y montando

El paquete que me llegó traía diversos elementos:

* Un visor de cartón DOBOcase VR 1.2.
* Una estructura de cartón para poder montar el visor en una gorra, evitando tener que sujetarlo con las manos.
* Una gorra de DIYVR.

{{< figure src="/posts/visor-de-realidad-virtual-diyvr/images/2.jpg" caption="Contenido del envío de DIVVR." >}}

El visor indica en el exterior de su caja el ancho y alto máximo que debe tener el móvil que se va a usar con él.
En mi caso terminé de montarlo sin darme cuenta de que mi móvil excedía dicho ancho por medio centímetro.
Así que ahora me veo en la necesidad de hacer algunos ajustes si quiero poder usarlo.

En el interior vienen las instrucciones para su montaje.
Sin embargo es preferible acudir a la página del fabricante donde hay [vídeos](http://www.dodocase.com/pages/VRkit1) con instrucciones actualizadas.

Por ejemplo, las incluidas no indican como montar el botón magnético, el soporte para la [Leap Motion](https://www.leapmotion.com/) ---lo que hipotéticamente nos permitirá, si tenemos una, controlar el entorno con nuestras propias manos mientras estamos en él--- ni una modificación para reforzar la unión del botón mecánico.
Pero sí trae una pequeña reseña de unas pocas líneas sobre cómo usar los espaciadores especiales para iPhone 5 ---ç estos dispositivos son demasiado pequeños, por lo que hacen falta estos espaciadores para ayudar a que queden centrados en el campo de visión---.

En todo caso, tanto si se usan las instrucciones de la caja como los vídeos, hay que ir con cuidado porque es sencillo acabar montando alguna cosa al revés o usando elementos que no corresponden.
De hecho a mi me pasó y tuve que corregir lo que pude posteriormente.
Así que aunque la caja indique un tiempo de montaje de 2 min. yo creo que está mas cerca de los 20 min.
Y es muy conveniente tener tijeras, cúter y pegamento de contacto por si es necesario hacer alguna corrección.

{{< figure src="/posts/visor-de-realidad-virtual-diyvr/images/3.jpg" caption="Visor DOBOcase VR, gorra y estructura de cartón diseñada para sujetar el visor." >}}

En los mismos [vídeos](http://www.dodocase.com/pages/VRkit1) se indica cómo montar la estructura para la gorra.
Básicamente se trata de un marco que facilita sujetar el visor DOBOcase VR a la visera de cualquier gorra.

En mi caso, para resolver el problema de tener un teléfono demasiado ancho para el visor, opté finalmente por seguir este sencillo [instructable](http://www.instructables.com/id/DodoCase-Mod-for-Galaxy-Note-3/?lang=es) que explica cómo adaptar la carcasa a un Samsung Galaxy Note 3, de tal forma que no se pulsen los botones de volumen al cerrarla ---aunque el «instructable» habla de proteger el botón de encendido, lo que se van a proteger entre las dos piezas de cartón son los botones de volumen, ubicados en el lado izquierdo del móvil---.

## El visor de realidad virtual

{{< figure src="/posts/visor-de-realidad-virtual-diyvr/images/4.jpg" caption="Perspectiva del visor DOBOcase VR donde se puede apreciar el botón mecánico (izquierda), la película metálica que contacta con la pantalla capacitiva del dispositivo (centro) y la pegatina NFC (debajo, con las letras DOBOcase)." >}}

El visor funciona muy bien, es cómodo y es necesario destacar la idea de montarlo en una gorra para no tener que sujetarlo con las manos.

Dentro lleva dos lentes bi-convexas ---parece que las mismas que las de la [Google Cardboard](https://www.google.com/get/cardboard/)--- muy sencillas de montar y que son las encargadas de que podamos ver adecuadamente y a tan corta distancia la pantalla del móvil.

Al igual que el dispositivo de Google, la carcasa DOBOcase VR trae un botón magnético que sirve para «hacer clic».
Sin embargo cierto tiempo ha pasado desde que Google presentó solución y la gente de DOBOcase ha podido introducir algunas mejoras.
Así la carcasa trae un botón mecánico que funciona aprovechando la pantalla capacitiva del móvil ---por lo que funciona en cualquier dispositivo--- y una tarjeta NFC que puede usarse para lanzar automáticamente la aplicación de DOBOcase cuando el móvil se monta en el visor.

## Aplicaciones

Respecto al software, lo más sencillo es instalar [DODOcase VR Portal](https://play.google.com/store/apps/details?id=com.dodocase.vr) que, todo hay que decirlo, aun está en fase beta.
La aplicación no es muy atractiva y realmente no hace nada por sí misma, ya que simplemente es una lista de aplicaciones para Android y contenido WebGL VR que puede usarse con el visor en cuestión.

Por mi parte, y fundamente debido al problema con el ancho de mi móvil, sólo he podido probar [Cardboard](https://play.google.com/store/apps/details?id=com.google.samples.apps.cardboarddemo) y [Tuscany Dive](https://play.google.com/store/apps/details?id=com.FabulousPixel.TuscanyDive).
La primera es la aplicación original hecha por Google para su visor.

[Cardboard](https://play.google.com/store/apps/details?id=com.google.samples.apps.cardboarddemo) básicamente incluye una serie de demos para mostrar las posibilidades de los móviles Android cuando se usan como dispositivos de realidad virtual:

* **Earth**. Ir a donde quieras en Google Earth.
* **Tour Guide**. Visita turística guiada en inglés al palacio de Versalles.
* **YouTube**. Impresionante vista en 360º de los vídeos más populares de YouTube.
* **Exhibit**. Exposición en 360º de diversas antigüedades.
* **Photo Sphere**. ¿Qué mejor que un visor de realidad virtual para ver las fotos esféricas que hayas tomado?
* **Windy Day**. Corto de animación interactivo realizado por Spotlight Stories.

{{< figure src="/posts/visor-de-realidad-virtual-diyvr/images/5.jpg" caption="Captura de pantalla de la aplicación [Cardboard](https://goo.gl/dlDhCg) de Google, justo antes de elegir la demo de Youtube." >}}

Mientras que [Tuscany Dive](https://play.google.com/store/apps/details?id=com.FabulousPixel.TuscanyDive) es una fantástica demo con la que se puede explorar una villa en la Toscana italiana.
Si se dispone de un controlador bluetooth se puede utilizar para caminar.
Aunque como no dispongo de uno, me he tenido que limitar a mirar el suelo para activar o desactivar el caminar.
En cualquier caso la sensación es impresionante.

## Conclusiones

¿Qué puedo decir? He vivido gran parte de mi vida leyendo libros y viendo películas donde se hablaba de una manera o de otra de la inminente llegada de la realidad virtual a nuestra vida cotidiana.
Pero sólo una vez antes que esta pude experimentarla y no fue precisamente en el salón de mi casa.

Este tipo de soluciones abre tal mundo de posibilidades y hace que la realidad virtual parezca tan accesible, que no dudo que en parte la elección de mi próximo móvil vendrá determinada porque me pueda ofrecer una adecuada experiencia virtual cuando lo vaya a usar con un visor como este.
