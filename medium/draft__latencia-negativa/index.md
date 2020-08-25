---
title: "Latencia negativa"
author: ""
date: 
draft: true
description: ""

subtitle: "https://www.xataka.com/videojuegos/latencia-negativa-tecnica-google-stadia-que-promete-que-jugando-nube-tendremos-lag-que-local"




aliases:
    - "/"
---

[https://www.xataka.com/videojuegos/latencia-negativa-tecnica-google-stadia-que-promete-que-jugando-nube-tendremos-lag-que-local](https://www.xataka.com/videojuegos/latencia-negativa-tecnica-google-stadia-que-promete-que-jugando-nube-tendremos-lag-que-local) 

[https://venturebeat.com/2019/10/10/how-google-stadias-negative-latency-might-work/](https://venturebeat.com/2019/10/10/how-google-stadias-negative-latency-might-work/)

[https://arstechnica.com/gaming/2018/04/better-than-reality-new-emulation-tech-lags-less-than-original-consoles/](https://arstechnica.com/gaming/2018/04/better-than-reality-new-emulation-tech-lags-less-than-original-consoles/) 

[https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html](https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html)

Edge Magazine

Hay algunos cosas que parece que todo el mundo olvida al discutir sobre esto.
Primero, que los ingenieros de Google seguro que han considerado todo lo que se ha discutido aquí.
Difícilmente, cuando empezaron este proyecto, no iban a conocer que latencia sería un problema.
Segundo, que habla de un plazo de 1 o 2 años.
Tercero, nadie habla de que juegue por ti.
Seguramente solo prediga cuáles podrían ser los siguientes frames y si no acierta intentará corregir lo antes posible.

Es evidente que cuando Stadia salga lo de la latencia estará ahí.
Por eso nadie espera que Stadia sea interesante para juegos competitivos.
Pero para el resto la latencia de la que se habla no será un problema.
Para minimizarlo en lo posible, seguramente ya al salir use una técnica que también comentó, aunque los médios se han centrado en la maldita predicción: modifica de forma adaptativa el número de frames.

Es decir, el servidor puede ir generando estados de juego y de ahí frames que envía periódicamente con una tasa fija.
Si llega input, los FPS al renderizar pueden aumentar para usar el ancho de banda disponible para que llegue frames con la nueva acción lo antes posible.
¿Tiene sentido? A 60 FPS hay una latencia, solo por esperar al siguiente frame, de 17 ms.
Aumentando los FPS para renderizar y manda un frame actualizado lo antes posible esa parte de la latencia se reduce.

Obviamente el frame estará listo antes cuando mayor sea la potencia del servidor.
Con potencia suficiente el servidor no generará frames a 60 FPS sino 120, 240 o 300.
El cliente puede descartar y quedarse con los frames más recientes, reduciendo esa fuente de retardo.
Aquí el plazo de 1 o 2 años que indican puede tener su importancia porque en ese tiempo el HW será mejor que el actual y tendrán más capacidad.

En los juegos en red se usa cierta predicción generando estados con la input conocida hasta el momento.
Esto es inevitable porque entre clientes y servidor existe cierta latencia que hay que ocultar.
Cuando llega un input se vuelve al estado del juego en el instante donde se estima que se generó, se calcula el nuevo estado y se manda a los clientes para corregir, suponiendo que el resto de la predicción es correcta.
Y se repite cuando llega esta nueva input.

Algo similar hacen algunos emuladores para obtener latencia similares a las del hardware original.
Cuando llega un input se vuelva al estado del juego en el frame donde se estima que se generó, se calcula el nuevo estado con el nuevo input y se renderizan varios frames en una tasa alta de FPS para desechar los viejos frames y alcanzar el siguiente frame que se iba a mostrar.

Para estas cosas hace falta HW muy potente.
Así que cuanto más tiempo pase y más mejore el HW disponible, más se podrán exprimir estas técnicas.


Y, obviamente, luego esa combinar todo esto con algún tipo de predicción.
Porque a fin de cuentas estas técnicas que ya se usan predicen, pero de forma muy ingenua.
Suponen que el personaje si lo movemos en una dirección lo seguiremos haciendo en instante sucesivos.
Con suficiente potencia de cálculo y muestras de jugadores, se puede hacer una predicción especulativa en base al estado del juego, perfil del jugador, etc.
estimando varias opciones con las probabilidades de que ocurran.
Con la potencia adecuada se pueden prerenderizar las diferentes alternativas, a la espera de que llegue el input que confirme lo predicho.
Si se ha cometido un error, con las técnica comentadas, se podría corregir el resultado de la acción lo antes posible.

Pero, lo dicho, no son cosas para noviembre.
Son técnicas anunciadas para al menos para 1 o 2 años vista.
Y claro está que quizás no resuelvan tanto para los que vivimos a más de 3000km de un centro de datos de Google, porque seguiremos teniendo un lag de la leche por la distancia que ninguna de estas técnicas pueden resolver.
Pero para el resto, sí que puede mejorar mucho la experiencia de juego.
