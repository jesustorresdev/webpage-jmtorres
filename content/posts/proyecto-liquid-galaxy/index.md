---
title: "Proyecto Liquid Galaxy"
author: "Jesús Torres"
date: 2014-07-29T00:57:22.000Z

tags:
 - Google Earth
 - VR

images:
 - "images/1.jpg" 

aliases:
 - "/proyecto-liquid-galaxy-ac9e53041049"
---

Hace unos días en la [TLP Tenerife 2014](http://www.tlp-tenerife.com/) tuve la oportunidad de ver un sistema de 5 pantallas para navegar con Google Earth llamado [Liquid Galaxy](http://www.google.com/earth/explore/showcase/liquidgalaxy.html).

Básicamente el sistema consistía en 5 pantallas dispuestas en vertical, unas junto a las otras, rodeando al usuario.
En cada una se veía una porción de una vista aérea de Google Earth, ajustada de tal forma que la sensación era envolvente, como si miráramos desde un avión o una nave espacial con 5 ventanas.

Cada pantalla estaba conectada a un mini-PC Gigabyte donde se ejecutaba una copia de Google Earth sobre alguna versión de Ubuntu.
Estos ordenadores estaban conectados a través de una red Ethernet Gigabit, de tal forma que trabajan de forma perfectamente sincronizada.
El ordenador de la pantalla central podía ser manejado por el usuario tanto con un sensor [Leap Motion](https://www.leapmotion.com/) como con un ratón 3D [SpaceNavigator](http://www.3dconnexion.es/products/spacenavigator.html), que se comunicaba con el resto de equipos para crear un sensación espectacular, como si fueran uno solo.

{{< figure src="images/1.jpg" caption="Ratón 3D SpaceNavigator de 3Dconnection --- vía [AmericanXplorer13~commonswiki](https://commons.wikimedia.org/wiki/User:AmericanXplorer13~commonswiki), License [CC-BY-SA-2.5](https://creativecommons.org/licenses/by-sa/2.5/)" >}}

El asunto parecía interesante con vistas a crear simuladores de vuelo y cosas parecidas y la verdad es que tenía curiosidad por saber el porqué de usar 5 ordenadores y no uno sólo con soporte para 5 pantallas, ya que aunque no soy un experto se que las tarjetas AMD con tecnología [Eyefinity](http://www.amd.com/en-us/innovations/software-technologies/technologies-gaming/eyefinity) permiten usar hasta 6 monitores con conexión DisplayPort.

## El porqué de Liquid Galaxy

Parece que el asunto es que Google Earth tiene un máximo de resolución de 5760x1200, por lo que no importa cuantas pantallas tengamos en nuestro ordenador que nunca podremos superar esa resolución horizontal.
Además, el punto de vista ofrecido por el programa es panorámico ---muy ancho respecto al alto--- pero no está corregido para generar sensación de que estamos viendo lo que tenemos a nuestro alrededor y además [no hace corrección _bezel_](https://groups.google.com/forum/#!topic/liquid-galaxy/srokd1fiFzo).
Este último tipo de corrección es muy importante porque hace que el programa considere que una parte de la vista permanece oculta por el marco de los monitores, lo que ayuda a que el resultado final se aun más realista.

El proyecto Liquid Galaxy se encarga de resolver todo esto y lo documenta perfectamente en el [HOWTO](https://code.google.com/p/liquid-galaxy/wiki/LiquidGalaxyHOWTO) del proyecto.
Básicamente consiste en tener un ordenador ---ya sea físico o virtual, si preferimos usar máquinas virtuale --- para cada pantalla.
En cada uno correrá una copia de Google Earth.
El ordenador conectado a la pantalla central opera de maestro y los demás son esclavos que se comunican usando una característica de Google Earth hecha ex profeso para eso ---ya que Google Earth no es libre, sólo Google puede añadir funcionalidades como esta--- llamada [ViewSync](https://code.google.com/p/liquid-galaxy/wiki/GoogleEarth_ViewSync), cuya función es comunicar por UDP a cada esclavo las coordenadas y el punto de vista corregido correspondiente.

Todo esto ha llevado a ideas muy interesantes.
Por ejemplo, algunos han modificado el visor de imágenes [Xiv](http://xiv.sourceforge.net/) y de vídeos [MPlayer](http://www.mplayerhq.hu/) para que opere de forma similar a como lo hace Google Earth con ViewSync, permitiendo ver imágenes y vídeos de forma panorámica y envolvente.
De igual forma otros usan la función de ViewSync para preconfigurar rutas turísticas que después pueden reproducirse en Liquid Galaxy.

Sin duda las posibilidades son muchas, como muestra el contenido de la [página de ideas para el Google Summer of Code 2014](https://code.google.com/p/liquid-galaxy/wiki/GSoC2014Ideas).

## El hardware de Gigabyte

A parte de todo esto, uno de los aspectos que me llamó la atención fueron los mini-ordenadores Gigabyte que usaron en la instalación de la [TLP Tenerife 2014](http://www.tlp-tenerife.com/).

Realmente los [requisitos hardware de Liquid Galaxy](https://code.google.com/p/liquid-galaxy/wiki/ComputerHardware) no son excesivos por lo que optaron por [sistemas BRIX de Gigabyte](http://www.gigabyte.com.es/products/product-page.aspx?pid=4603#ov).
La verdad es que no lo había pensando pero estos dispositivos permiten tener un clúster de 5 procesadores i7 o i5 por unos 1500€; lo que no está nada mal.
Para el tipo de aplicación que estamos hablado ¿sería mejor un único equipo de 1500€ o 5 de 300€ dedicado cada uno a su monitor? Sospecho que seguramente la segunda solución escale mejor cuando el número de monitores crece.
