---
title: "El sistema de mensajería de los alumnos de Sistemas Operativos Avanzados"
author: "Jesús Torres"
date: 2016-12-05T08:00:55.000Z
lastmod: 2020-06-03T11:42:35+01:00

description: ""

subtitle: ""

image: "/posts/2016-12-05_el-sistema-de-mensajería-de-los-alumnos-de-sistemas-operativos-avanzados/images/1.jpg" 
images:
 - "/posts/2016-12-05_el-sistema-de-mensajería-de-los-alumnos-de-sistemas-operativos-avanzados/images/1.jpg" 


aliases:
    - "/el-sistema-de-mensajer%C3%ADa-de-los-alumnos-de-sistemas-operativos-avanzados-4c9c0663289"
---

Hace tiempo que venía pensando en dar un cambio a la asignatura de [Sistemas Operativos Avanzados](https://jmtorres.webs.ull.es/me/proyecto/sistemas-operativos-avanzados/). El problema es que el tiempo no da para todo. La idea detrás de la asignatura es que los estudiantes aprendan a desarrollar software de sistemas y para eso les propongo un proyecto que deben realizar en grupo y usando metodologías ágiles. Yo hago de _Product Owner_ y les doy las historias de usuario. Ellos deben organizar los _sprint_ y uno tras otro van haciendo el desarrollo y entregado un producto con las funcionalidades acordadas.

Hasta la fecha ese producto era una especie de sistema de vigilancia. Desarrollaban un cliente que se ejecutaba en varios ordenadores donde usan la cámara instalada en el sistema para grabar vídeo y detectar movimiento. Los frames con cambios son enviados junto con todo tipo de información a un servidor donde se almacenan para poder ser buscados prosteriormente.

La idea no está mal pero la verdad es que me va apeteciendo un cambios en varios sentidos:

*   **Lenguaje de programación**. Me gusta C++ y me gusta Qt. Lo positivo de Qt es que pueden hacer interfaces gráficas, que es algo que no suelen ver los estudiantes en otras asignaturas, y que presenta problemas de concurrencia similares a los que tiene el desarrollar servicios. Sin embargo programar con Qt no es exactamente programar en C++. Da muchas facilidades, pero no ofrece un API moderno con toda las novedades de C++11/14/17. Sin duda es mucho lo que nos estamos perdiendo de las últimas actualizaciones del estándar y me fastidia no darles la importancia que se merecen. Además hay otros lenguajes para software de sistemas: Rust, Go o tal vez Elixir. Lo que hacemos incluso se podría hacer con Java o C#, que son más demandados por las empresas locales. Aunque cambiar de lenguaje también significa que el tiempo daría para menos. En este punto no me termino de decidir. Hay tantas posibilidades.
*   **Herramientas**. Obviamente cambiando de lenguaje cambian las herramientas pero además hay algunas cosas que me gustaría incorporar. Por ejemplo, usar [Cucumber](https://cucumber.io/) para desarrollar test y hacer algo de TDD o usar [cppcheck](http://cppcheck.sourceforge.net/) para el análisis estático del código. Hace tiempo que estoy detrás de que añadan una interfaz web al servicio de vigilancia incorporando, por ejemplo, [mongoose](https://github.com/cesanta/mongoose/). También me gustaría incorporar algo de administración de sistemas. Por ejemplo teniendo que hacer un despliegue en condiciones en el servicios [IAAS de STIC](http://www.ull.es/servicios/stic/category/iaas/). Y estaría encantado si pudiéramos usar algo de programación reactiva y orientación a los microservicios a la hora de diseñar la solución. Este año un alumno me sugirió usar JIRA en lugar de las _issues_ de GitHub o Taiga. Y también me pregunto si debería optar por un desarrollo más basado en los protocolos y estándares de la web que en uno donde deben diseñar su propias soluciones desde 0.
*   **Cambiar el proyecto**. Tengo claro que hay ganas de buscar otro proyecto y abandonar el sistema de vigilancia. De hecho, escribiendo estas líneas, se me ha ocurrido que podrían crear un sistema de registro de datos para IoT, ahora que está tan de moda. Un servicio al que lleguen datos de todo tipo de sensores y que éstos se puedan mostrar en un panel de mando. Sin duda tendré que explorarlo. ¿Daría esto cabida para ver algo de desarrollo de controladores de dispositivo? Creo que también tendré que explorarlo.



![image](/posts/2016-12-05_el-sistema-de-mensajería-de-los-alumnos-de-sistemas-operativos-avanzados/images/1.jpg)



El pasado curso di un primer paso cambiando la práctica. Aproveché que habíamos estrenado un nuevo proyecto en la asignatura previa ese mismo año y que estos estudiantes no lo habían hecho — por haber cursado esa asignatura el año anterior — para usar ese mismo proyecto y extenderlo. En concreto les pedí un servicio de mensajería instantánea, a lo Whatsapp, con autenticación, grupos de charla y avatares.

Del resultado estoy bastante contento, teniendo en cuenta que sólo fueron dos meses de desarrollo usando herramientas completamente nuevas para ellos. Dos de los grupos hicieron unos vídeos para mostrar el resultado. Los dejo aquí porque creo que merece la pena compartirlos.

### ChatOsO

El primero de los proyectos es **ChatOsO** de [Alberto Martínez Chincho](https://github.com/alu0100698893/ChatOsO) y [Alejandro Delgado Martel](https://github.com/alu0100767452/ChatOsO).






### qVersare

El segundo de los proyectos es **qVersare** de [Adrián Abreu González](https://github.com/aabreuglez/qVersare) y [Jose Ricardo Pérez Castillo](https://github.com/alu0100832976/qVersare).
