---
title: "Introducción a las señales POSIX"
author: "Jesús Torres"
date: 2015-03-30T13:08:46.000Z

description: ""

subtitle: ""

image: "/posts/2015-03-30_introducción-a-las-señales-posix/images/1.gif" 
images:
 - "/posts/2015-03-30_introducción-a-las-señales-posix/images/1.gif" 


aliases:
    - "/introducci%C3%B3n-a-las-se%C3%B1ales-posix-1920819e5014"
---

{{< figure src="/posts/2015-03-30_introducción-a-las-señales-posix/images/1.gif" caption="Logo original del sistema UNIX." >}}


Los sistemas operativos compatibles con el estándar POSIX implementan un tipo de interrupción por software conocida como _señales POSIX_.
Estas son enviadas a los procesos para informar de situaciones excepcionales durante la ejecución del programa, como por ejemplo:

*   `**SIGSEGV**`
Acceso a una dirección de memoria no válida.
*   `**SIGFPE**`
Intento de ejecutar una operación aritmética inválida, como por ejemplo una división por cero.
*   `**SIGILL**`
Intento de ejecutar una instrucción ilegal.
*   `**SIGCHLD**`
Notificación de terminación de algún proceso hijo.
Por defecto también se notifica que un proceso hijo ha sido detenido.
*   `**SIGTERM**`
Notificación de que se ha solicitado la terminación del proceso.
*   `**SIGINT**`
Notificación de que el proceso está controlado por una terminal y el usuario quiere interrumpirlo.
Generalmente esta señal es motivada por la pulsación de la combinación de teclas `Ctrl-C` en la terminal desde la que se controla el proceso.
*   `**SIGHUP**`
Notificación de que se ha cerrado la terminal a través de la que se controla el proceso, por lo que dicho proceso debe terminar.
Al recibir esta señal muchos procesos no interactivos --- como servicios o demonios --- releen los archivos de configuración y reabren los de registro, sin tener que matar y volver a iniciar el proceso.

Estos son una pequeña muestra de una [lista](http://en.wikipedia.org/wiki/Unix_signal#POSIX_signals) mucho más extensa.

## Manejadores de señal

Para cada tipo de señal el proceso puede especificar una [acción](http://pubs.opengroup.org/onlinepubs/000095399/functions/xsh_chap02_04.html#tag_02_04_03) diferente:

*   `**SIG_DFL**`
Ejecutar la acción por defecto, lo que generalmente implica terminar el proceso inmediatamente.
*   `**SIG_IGN**`
Ignorar la señal, lo que no es posible para todos los tipos de señales.
*   **Invocar un manejador de señal
**Invocar una función concreta del programa que actúa como _manejador de la señal_ para realizar las acciones que el programador considere oportunas.

Esto último es interesante porque, por ejemplo, permite realizar las acciones necesarias para que el programa termine en condiciones seguras cuando reciba señales como `SIGINT` o `SIGTERM`.
Por ejemplo: borrar archivos temporales, asegurar que los datos se escriben en disco y la estructura de su contenido es consistente, terminar procesos hijo a los que se les haya delegado parte del trabajo, cerrar canales de comunicación, detener hilos de ejecución, etc.

Para fijar el manejador de una señal concreta, simplemente hay usar la función de la librería estándar `[std::signal](http://en.cppreference.com/w/cpp/utility/program/signal)()` ̣ --- o alternativamente la llamada al sistema `[signal](http://linux.die.net/man/2/signal)()` --- de la siguiente manera:




## Seguridad respecto a las señales

Al trabajar con _señales POSIX_ debemos tener presente que éstas pueden llegar en cualquier momento, interrumpiendo así la secuencia normal de ejecución de instrucciones del proceso.
Es decir, los _manejadores de señal_ son invocados de forma asíncrona respecto a la ejecución del proceso, lo que introduce problemas de concurrencia debido al posible acceso del manejador a datos que estaban siendo manipulados por el programa en el momento en que fue interrumpido.
Por ello:

*   El estándar POSIX establece que **desde un manejador de señal sólo se pueden invocar funciones seguras respecto a la asincronicidad de las señales**.
Estas funciones son aquellas que o son _reentrantes_ o no interrumpibles respecto a las señales.
Pero hay que tener mucho cuidado porque sólo [unas pocas](http://en.wikipedia.org/wiki/Unix_signal#POSIX_signals) funciones de la librería del sistema cumplen con dicho requisito.
De hecho el estándar de C++ establece que el comportamiento está indefinido si dentro de un manejador de señal se llama a cualquier función de la librería estándar del lenguaje, excepto `std::abort`, `std::_Exit`, `std::quick_exit` o `std::signal` ---en este último caso siempre que el primer argumento no sea el número de la señal que actualmente está siendo manejada---.
*   En programas multihilo **cualquier hilo en el que no se haya bloqueado una señal puede ser utilizado para atenderla**.
Esto introduce problemas adicionales de concurrencia que obligan al uso de [cerrojos, semáforos y otros elementos de sincronización](https://jmtorres.webs.ull.es/me/2013/02/introduccion-al-uso-de-hilos-en-qt/).
Por eso es muy común bloquear las señales en todos los hilos excepto en uno, que de esta manera podrá ser el único interrumpido para manejarlas.
*   Incluso si se usan variables como banderas para notificar desde el manejador al programa principal que ha ocurrido una señal, con el objeto de que éste último ejecute las acciones necesarias, **debemos especificar al compilador que no utilice con ellas variables optimizaciones que puedan dar problemas de concurrencia**:
*   El tipo `volatile std::sig_atomic_t` para definir variables atómicas cumple con esos requisitos.
La palabra reservada de C/C++ `volatile` permite indicarle al compilador que no optimice el acceso a una variable porque su valor puede cambiar de improviso.
Mientras que `sig_atomic_t` es un tipo de entero que está garantizado que puede ser accedido como una entidad atómica ---sin interrupciones--- incluso en presencia de señales.
*   En C++11 o posterior la plantilla `[std::atomic](http://en.cppreference.com/w/cpp/atomic/atomic)` también permite definir variables atómicas.

Por lo tanto, la siguiente podría ser una forma correcta de terminar un proceso cuando llegan señales tales como `SIGINT` o `SIGTERM`:




### Funciones reentrantes y no interrumpibles.

Como hemos comentado, un manejador de señal sólo se pueden invocar funciones seguras respecto a la asincronicidad de las señales.
Y esto sólo ocurren con aquellas que o son _reentrantes_ o no son interrumpibles respecto a las señales.

Una función es _reentrante_ si puede ser interrumpida en medio de su ejecución y vuelta a llamar con total seguridad.
En general una función es reentrante si no modifica variables estáticas o globales, no modifica su propio código y no llama a otras funciones que no sean reentrantes.

Mientras que una función puede ser no interrumpible respecto a las señales si al entrar en la función lo primero que hace el código es bloquea dichas señales, desbloqueándolas antes de salir.

## Bloqueo de señales

A veces no interesa manejar todas las señales que puede recibir un proceso o puede ser interesante bloquearlas en instantes concretos de la ejecución del mismo.
Por eso el sistema nos proporciona funciones para hacerlo.

A la colección de señales actualmente bloqueadas se las denomina _máscara de señales_ y se hereda de padres a hijos durante la creación de los procesos.
Posteriormente, durante la ejecución de un programa, esta _máscara de señales_ se puede modificar utilizando las llamadas al sistema `[sigprocmask](http://linux.die.net/man/2/sigprocmask)()` o `[pthread_sigmask](http://linux.die.net/man/3/pthread_sigmask)()`.
``int sigprocmask (int how,  
                 const sigset_t *restrict set,  
                 sigset_t *restrict oldset)````int pthread_sigmask(int how,  
                    const sigset_t *set,  
                    sigset_t *oldset);``

Es importante notar que ambas llamadas operan de la misma manera, sin embargo `[sigprocmask](http://linux.die.net/man/2/sigprocmask)()` sólo debe usarse en programas monohilo para modificar la _máscara de señales_ del proceso.
En los programas multihilo cada hilo tiene su propia _máscara de señales_, por lo que debe utilizarse `[pthread_sigmask](http://linux.die.net/man/3/pthread_sigmask)()` si deseamos modificarla.
Según el estándar POSIX, el efecto de usar `[sigprocmask](http://linux.die.net/man/2/sigprocmask)()` en procesos multihilo no está especificado.

Ambas funciones están diseñadas tanto para examinar como para cambiar la _máscara de señales_:

*   `oldset`
Se utiliza para devolver la _máscara de señales_ previa.
Si se desea examinar la _máscara de señales_ actual sin modificarla, sólo es necesario pasar un puntero a NULL en `set`.
De igual forma, si sólo se desea modificar la _máscara de señales_ sin recuperar la máscara previa, basta con pasar `oldset` a NULL.
*   `set
`Se utiliza para indicar la nueva _máscara de señales_.
Cómo se interprete este argumento para construir dicha nueva máscara depende del argumento `how`.
*   `how`
Determina como cambiará la _máscara de señales_ actual.

Los valores posibles para `how` son:

*   `SIG_BLOCK`
Añade las señales indicadas en `set` a la máscara actual para bloquearlas también.
*   `SIG_UNBLOCK`
*   Elimina las señales indicadas en `set` de la máscara actual para desbloquearlas.
*   `SIG_SETMASK`
Usar el contenido de `set` como _máscara de señales_ actual, ignorando así el valor previo de dicha máscara.

Tanto los argumentos `set` como `oldset` son de tipo `sigset_t`, que es con el que se representan los conjuntos de señales.
Por portabilidad estos conjuntos no deben manipularse directamente sino a través de las siguientes funciones:

*   `int sigemptyset(sigset_t *set)
`Inicializa `set` sin ninguna señal.
*   `int sigefillset(sigset_t *set)`
Inicializa `set` para que incluya todas las señales.
*   `int sigeaddset(sigset_t *set, int signum)`
Añade la señal `signum` al conjunto de señales `set`.
*   `int sigedelset(sigset_t *set, int signum)`
Elimina la señal `signum` del conjunto de señales `set`.
*   `int sigismember (const sigset_t *set, int signum)`
Devuelve 1 si la señal `signum` está incluida en el conjunto `set`.
Mientras que retorna 0 en caso contrario.

## Manejo avanzado de señales

En el apartado sobre [manejadores de señal](#manejadores) vimos como podemos especificar un manejador para cada señal usando la función de la librería estándar `[std::signal](http://en.cppreference.com/w/cpp/utility/program/signal)()` o la llamada al sistema `[signal](http://linux.die.net/man/2/signal)()`.
Sin embargo esta no es la forma recomendada de hacerlo.
En su lugar, por motivos de portabilidad, se recomienda usar `[sigaction](http://linux.die.net/man/2/sigaction)()`.
``int sigaction (int signum,  
               const struct sigaction *act,  
               struct sigaction *restrict oldact)``

*   `signum`
Señal para la que se va a modificar la acción.
*   `act`
Puntero a una estructura `sigaction` que describe la nueva acción para la señal `signum`.
Si este puntero es NULL, no se modificará la acción actual y su descripción podrá recuperarse a través de `oldact`.
*   `oldact`
Puntero a una estructura `sigaction` que será rellenada con la antigua acción para la señal `signum`.
Si este puntero es NULL, no se recuperará el valor previo de la acción para dicha señal.

### Estructura sigaction

De la estructura `sigaction`, que describe la acción para una señal, los campos más relevantes son:

*   `sa_handler`
Describe el manejador de la señal.
Igual que ocurre con `[signal](http://linux.die.net/man/2/signal)()`, este campo puede valer `SIG_DFL`, `SIG_IGN` o un puntero a una función.
*   `sa_mask`
Es un campo de tipo `sigset_t` que describe el conjunto de señales que serán bloqueadas mientras el manejador indicado en `sa_handler` es ejecutado.
Además de estas señales, también se bloqueará automáticamente la misma señal que provocó la ejecución del manejador.
*   `sa_flags`
Especifica varios _flags_, combinados mediante operador _OR_, que puede afectar a como se maneja la señal.

Entre los valores posibles para `sa_flags` los más comunes son:

*   `SA_NOCLDSTOP`
Este _flag_ sólo tiene sentido si se usa con la señal `SIGCHLD` y sirve para indicar que dicha señal sólo debe enviarse al padre de un proceso cuando uno de sus hijos termina, no cuando es detenido.
Por defecto la señal `SIGCHLD` se envía al padre en ambos casos.
*   `SA_RESTART`
Este _flag_ controla qué ocurre cuando la señal llega mientras el proceso o el hilo están dentro de ciertas llamadas al sistema ---como `open()`, `read()` o `write()`---.
Si no se especifica `SA_RESTART`, dichas operaciones serán interrumpidas cuando termine el manejador de la señal, retornando con el código de error `EINTR`.
Por el contrario, si se especifica `SA_RESTART`, la llamada afectada continuará tras ejecutarse el manejador de la señal que la interrumpió.

## Referencias

*   Wikipedia --- [Unix signal](http://en.wikipedia.org/wiki/Unix_signal)
*   The GNU C Library --- [Signal Handling](http://www.gnu.org/software/libc/manual/html_node/Signal-Handling.html)
