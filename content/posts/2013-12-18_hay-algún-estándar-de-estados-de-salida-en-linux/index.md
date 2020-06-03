---
title: "¿Hay algún estándar de estados de salida en Linux?"
author: "Jesús Torres"
date: 2013-12-18T15:21:20.000Z
lastmod: 2020-06-03T11:41:37+01:00

description: ""

subtitle: ""

image: "/posts/2013-12-18_hay-algún-estándar-de-estados-de-salida-en-linux/images/1.jpg" 
images:
 - "/posts/2013-12-18_hay-algún-estándar-de-estados-de-salida-en-linux/images/1.jpg" 


aliases:
    - "/hay-alg%C3%BAn-est%C3%A1ndar-de-estados-de-salida-en-linux-4f3b14be9a2d"
---

![image](/posts/2013-12-18_hay-algún-estándar-de-estados-de-salida-en-linux/images/1.jpg)

Todos sabemos que si un proceso termina con éxito en Linux siempre lo hace usando 0 como estado de salida. Mientras que en caso de error, dicho valor debe estar comprendido entre 1 y 255.

Pero ¿existe algún estándar respecto del estado de salida que se debe usar en función de la causa del error?

Obviamente esta no es una pregunta que a uno le venga alegremente a la cabeza. Ayer estaba corrigendo prácticas y todas las “inspiradas” en la misma fuente tenían la costumbre de usar estados de salida curiosamente altos: 127, 128, etc. Así que obviamente a alguien se le ocurrió preguntarme ¿de verdad esto tiene que ser así? ¿para terminar a causa de este error concreto tengo que usar `exit(128)` o puedo emplear cualquier otro valor?

### Exit Status en el manual de GNU libc

El [manual de la librería](http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html) del sistema en Linux comenta que cualquier valor entre 0 y 255 es válido, con la salvedad de que:

*   **0 siempre indica que no hubo error**.
*   **Cualquier valor diferente indica que sí lo hubo**.

Sin embargo, como algunos sistemas no POSIX puede usar una convención diferente, el manual recomienda utilizar las macros `EXIT_SUCCESS` —0 en los sistemas POSIX— y `EXIT_FAILURE` —1 en los sistemas POSIX—. También comenta que por lo general valores superiores a 127 se reservan para propósitos especiales, **recomendando usar el valor 128 para indicar un fallo en la ejecución de un programa en un subproceso**.

### Estados de salida de BASH

En el [apéndice E](http://tldp.org/LDP/abs/html/exitcodes.html) de [Advanced Bash Scripting Guide](http://tldp.org/LDP/abs/html/) se publica una tabla que muestra el uso y significado de los estados de salida empleados por BASH:
``1:     Catchall for general errors````2:     Misuse of shell builtins (according to Bash documentation)````126:   Command invoked cannot execute````127:   &#34;command not found&#34;````128:   Invalid argument to exit (exit takes only integer args in  
       the range 0 - 255)````128+n: Fatal error signal &#34;n&#34;````255:   Exit status out of range (exit takes only integer args in  
       the range 0 - 255)``

Esta tabla puede ser útil para tener alguna idea acerca de los estados de salida adecuados para nuestros propios scripts de BASH y además nos puede servir de guía cuando programamos nuestra propias aplicaciones en otros lenguajes.

### Archivo &lt;sysexits.h&gt; en C y C++

La comunidad ha intentado sistematizar el uso y la interpretación de los estados de salida cuando se desarrolla en C y C++, siendo muchos los programas que siguen esta recomendación, aunque nunca se haya estandarizado. **Estos estados de salida recomendados, junto con su significado, están disponibles en el archivo /usr/include/sysexits.h**.
``#define EX_OK           0   /* successful termination */````#define EX__BASE        64  /* base value for error messages */````#define EX_USAGE        64  /* command line usage error */  
#define EX_DATAERR      65  /* data format error */  
#define EX_NOINPUT      66  /* cannot open input */  
#define EX_NOUSER       67  /* addressee unknown */  
#define EX_NOHOST       68  /* host name unknown */  
#define EX_UNAVAILABLE  69  /* service unavailable */  
#define EX_SOFTWARE     70  /* internal software error */  
#define EX_OSERR        71  /* system error (e.g., can&#39;t fork) */  
#define EX_OSFILE       72  /* critical OS file missing */  
#define EX_CANTCREAT    73  /* can&#39;t create (user) output file */  
#define EX_IOERR        74  /* input/output error */  
#define EX_TEMPFAIL     75  /* temp failure; user is invited to retry */  
#define EX_PROTOCOL     76  /* remote error in protocol */  
#define EX_NOPERM       77  /* permission denied */  
#define EX_CONFIG       78  /* configuration error */````#define EX__MAX         78  /* maximum listed value */``
