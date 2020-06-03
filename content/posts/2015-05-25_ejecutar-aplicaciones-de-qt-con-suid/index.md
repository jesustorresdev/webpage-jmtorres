---
title: "Ejecutar aplicaciones de Qt con SUID"
author: "Jesús Torres"
date: 2015-05-25T19:08:58.000Z
lastmod: 2020-06-03T11:42:15+01:00

description: ""

subtitle: ""

image: "/posts/2015-05-25_ejecutar-aplicaciones-de-qt-con-suid/images/1.jpg" 
images:
 - "/posts/2015-05-25_ejecutar-aplicaciones-de-qt-con-suid/images/1.jpg" 


aliases:
    - "/ejecutar-aplicaciones-de-qt-con-suid-552588c76faf"
---

![image](/posts/2015-05-25_ejecutar-aplicaciones-de-qt-con-suid/images/1.jpg)

Para los casos en los que necesitamos ejecutar un programa con un usuario distinto al que hemos usado para autenticarnos en el sistema, los sistemas estilo UNIX como Linux nos ofrecen el mecanismo SUID o SetUID. Este es básicamente un permiso que puede asignarse a los ejecutables para permitir que se lancen con los privilegios del usuario que es propietario del mismo y no con los del usuario que intenta ejecutarlo.

A un fichero con el bit SetUID activado se le identifica por una `&#39;s&#39;` en el listado de archivos del directorio que lo contiene:
``# ls -l /usr/bin/passwd  
-rwsr-xr-x 1 root root 51128 jul 18 2014 /usr/bin/passwd``

Por eso el programa `passwd`, del ejemplo anterior, se ejecutará siempre con privilegios de `root`, independientemente del usuario que invoque dicho comando.

Lo que ocurre realmente es que el usuario real del proceso de `passwd` es el usuario que invocó el comando, pero el usuario efectivo —el usado para comprobar los privilegios y permisos del proceso— es el propietario del archivo —que en nuestro ejemplo es `root`—.

### SUID con aplicaciones Qt

El activar el bit SetUID en una aplicación entraña ciertos riesgos. Un programa mal diseñado puede facilitar que un atacante tome el control del proceso, permitiendo que éste lo use para hacer las tareas que él quiera. Si dicho proceso dispone de privilegios de `root` gracias al permiso SetUID, el atacante tendrá acceso sin ningún límite a todo el sistema.

Por lo tanto, los usuarios y administradores no deben activar el bit SetUID en cualquier programa. Sólo en aquellos que han sido diseñados e implementados con ese uso en mente. Por ese motivo y porque [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) es un librería muy grande que si no se usa con cuidado ofrece múltiples vectores de ataque, las aplicaciones desarrolladas con este _framework_ desde la versión 5.3 no pueden ejecutarse con el permiso SetUID.

Concretamente, la clase `[QCoreApplication](http://doc.qt.io/qt-5/qcoreapplication.html)` es la responsable de comprobar si el usuario real del proceso es distinto del efectivo. Si tal cosa ocurre, [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) abortará la aplicación con el error `FATAL: The application binary appears to be running setuid, this is a security hole`.

Si estamos seguros de que nuestra aplicación es segura y que por tanto puede ser usada con permiso SetUID si el usuario lo desea, sólo debemos invocar `[QCoreApplication](http://doc.qt.io/qt-5/qcoreapplication.html)::[setSetuidAllowed](http://doc.qt.io/qt-5/qcoreapplication.html#setSetuidAllowed)()` con su único argumento a `true`, antes de instanciar el objeto de la aplicación:




### Referencias

*   [QCoreApplication](http://doc.qt.io/qt-5/qcoreapplication.html) Class Reference.
