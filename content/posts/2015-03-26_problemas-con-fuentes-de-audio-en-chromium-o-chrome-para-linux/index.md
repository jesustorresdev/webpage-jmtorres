---
title: "Problemas con fuentes de audio en Chromium o Chrome para Linux"
author: "Jesús Torres"
date: 2015-03-26T08:00:01.000Z
lastmod: 2020-06-03T11:42:06+01:00

description: ""

subtitle: ""

image: "/posts/2015-03-26_problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/images/1.png" 
images:
 - "/posts/2015-03-26_problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/images/1.png" 
 - "/posts/2015-03-26_problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/images/2.png" 
 - "/posts/2015-03-26_problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/images/3.png" 


aliases:
    - "/problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux-44e8bc7040aa"
---

_Artículo originalmente publicado en la_ [_Oficina de Software Libre de la Universidad de La Laguna_](http://osl.ull.es/linux/problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/) _el 25 de marzo de 2015._En la actualidad muchos pasamos la mayor parte del tiempo trabajando en el navegador. En mi caso concreto el “afortunado” es [Chromium](https://www.chromium.org/Home), que utilizo en un escritorio [KDE](http://www.kde.org). Lamentablemente, a veces parece dar problemas con las aplicaciones que capturan audio — en mi caso concreto sospecho que eso ocurrió tras actualizar a una versión que incluía soporte para [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio) — . El resultado de esto, entre otras cosas, es que deja de ser posible hacer llamadas y videoconferencias con [Hangout](https://plus.google.com/hangouts).




![image](/posts/2015-03-26_problemas-con-fuentes-de-audio-en-chromium-o-chrome-para-linux/images/1.png)



En el caso concreto del que quiero hablar el problema finalmente estaba en la selección del dispositivos de captura. Muchos ordenadores modernos tienen una webcam, una entrada de audio analógica integrada en la placa madre o se usan con unos auriculares USB con manos libres. Para evitar problemas algunas aplicaciones permiten elegir el dispositivo de captura. Sin embargo, yo nunca conseguí que eso me funcionara. Probando tanto con Chromium como con Chrome la demo [AudioRecorder](http://webaudiodemos.appspot.com/AudioRecorder/index.html) daba la impresión de que se grababa algún tipo de ruido, proveniente con toda probabilidad de la entrada analógica, a la que no tenía nada conectado. Pero modificar el dispositivo de captura tanto en [Hangout](https://plus.google.com/hangouts) como en otras aplicaciones no parecía tener ningún efecto.

Además, como usuario de KDE que soy, se que a través de **Preferencias del sistema / Multimedia** es posible cambiar las preferencias de dispositivos, tanto para grabar como para reproducir, según el rol de la aplicación multimedia que se esté utilizando. Estos roles son indicados por las aplicaciones en cuestión cuando solicitan acceso al sistema de audio. Lamentablemente, modificar estas preferencias no parece tener efecto sobre el dispositivo finalmente utilizado por [Chromium](https://www.chromium.org/Home)




![Preferencias multimedia en KDE](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/03/preferencias-multimedia-en-kde.png)



### El sistema de audio en Linux

En un sistema moderno a los dispositivos de audio se accede a través de un componente del núcleo de Linux, denominado [ALSA](http://es.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture), que provee tanto una interfaz de programación adecuada como los controladores de dispositivo correspondientes.

Para obtener un mejor control del sistema de sonido, algunas distribuciones instalan un servidor de sonido a través del cual las aplicaciones tiene acceso a los dispositivos soportados por [ALSA](http://es.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture). En la actualidad ese servidor suele ser [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio), que está diseñado para manejar todos los flujos de audio en el sistema. De hecho, en un escenario estándar, las aplicaciones que intentan usar [ALSA](http://es.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture) directamente acceden a un dispositivo virtual proporcionado por [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio). Así estas aplicaciones envían el audio a [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio) sin saberlo, que a su vez usa [ALSA](http://es.wikipedia.org/wiki/Advanced_Linux_Sound_Architecture) para acceder a los dispositivo de audio reales. Obviamente otras aplicaciones pueden utilizar la interfaz de programación de [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio) para hablarse con él directamente.

En el caso de [KDE](http://www.kde.org) las aplicaciones utilizan una capa adicional multiplataforma denominada [Phonon](http://es.wikipedia.org/wiki/Phonon_%28KDE%29). En los sistemas Linux con [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio), [Phonon](http://es.wikipedia.org/wiki/Phonon_%28KDE%29) se integra con dicho servidor de sonido para ofrecer servicios multimedia a la aplicaciones de [KDE](http://www.kde.org).

### Roles y flujos de audio

Cuando una aplicación de [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio) — ya sea directamente o usando Phonon — necesita acceder aun dispositivo de audio, crea un flujo. Durante la creación del mismo debe especificar el rol de la aplicación de entre una lista predefinida: accesibilidad, notificación, juego, vídeo, música, etc. Esto permite configurar diferentes dispositivos de audio preferidos para cada rol, pero también para cada flujo de cada aplicación concreta.

Gracias a la integración de [KDE](http://www.kde.org) con [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio), las preferencias para cada rol se configurar fácilmente en **Preferencias del sistema / Multimedia**. Mientras que es el mezclador de [KDE](http://www.kde.org) KMix el que nos permite controla tanto dichas preferencias como incluso el volumen de sonido para cada flujo particular.

### Configurando el dispositivo de audio para Chromium

Echando un vistazo al código fuente de Chrome/Chromium todo parece indicar que al crear el flujo de captura de audio no se indica ningún rol. Sin embargo, eso no evita que podamos abrir KMix y buscar **Chrome input: RecordStream**. Usando la barra de desplazamiento vertical se puede controlar el volumen del audio capturado específico para la aplicación. Pero además, pulsando con el botón derecho del ratón sobre el icono del navegador, en la opción **Mover** del menú contextual que se despliega, se puede seleccionar la fuente de audio que más nos interese, de entre los dispositivos disponibles en nuestro sistema.




![Flujos de captura en KMix](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/03/flujo-de-captura-de-audio-en-kmix.png)



### ¿Y si no utilizo KDE?

Si no se dispone de KMix porque no se utiliza el entorno de escritorio KDE se puede emplear el programa [pavucontrol](http://freedesktop.org/software/pulseaudio/pavucontrol/), un mezclador expresamente creado para [Pulseaudio](http://es.wikipedia.org/wiki/PulseAudio). Eso sí, es importante tener en cuenta que ni KMix ni [pavucontrol](http://freedesktop.org/software/pulseaudio/pavucontrol/) pueden mostrar flujos de audio hasta que la aplicación correspondiente los crea. Por lo tanto, tenemos que hacer que [Chromium](https://www.chromium.org/Home) intente capturar sonido antes de poder ajustar su volumen y la fuente de audio con dichos programas. En eso nos puede resultar de gran ayuda la demo de [AudioRecorder](http://webaudiodemos.appspot.com/AudioRecorder/index.html).
