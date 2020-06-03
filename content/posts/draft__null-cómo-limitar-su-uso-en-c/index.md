---
title: "NULL: cómo limitar su uso en C++"
author: ""
date: 
lastmod: 2020-06-03T11:43:12+01:00
draft: true
description: ""

subtitle: "Me animó a escribir este artículo, sobre los recursos de C++ para evitar el uso de nulos, tras la lectura del fantástico artículo  Null, un…"




aliases:
    - "/"
---

_Me animó a escribir este artículo, sobre los recursos de C++ para evitar el uso de nulos, tras la lectura del fantástico artículo_ [_Null, un viejo enemigo del lado oscuro_](https://leanmind.es/es/blog/evitar-null-tambien-en-kotlin/) _de_ [_Carlos Blé_](https://www.carlosble.com/)_, donde aborda los motivos y las maneras de evitar al máximo el uso de objetos nullables en Kotlin. Recomiendo su lectura._Cambiar el enfoque. Usar punteros cuando sea posible:

[References, simply](https://herbsutter.com/2020/02/23/references-simply/)


Para pasar parámetros mejor sobre cargar las funciones:

[Let&#39;s Talk about std::optional and optional references](https://foonathan.net/2018/07/optional-reference/)


al no existir std::optional&lt;T&amp;&gt;

Supongo que debido a las raíces de C++ en C, a muchos no suena raro lo de C++ sin NULL. El concepto de NULL está íntimamente relacionado con el concepto de puntero y todos hemos oído que los punteros son una de las principales características y, al mismo tiempo, maldición de esos dos grandes lenguajes. Entonces ¿realmente es posible programa en C++ sin nulos?.

Obviamente cuando hablo de programar en C++ sin NULL, me estoy refiriendo tanto al uso de la antigua macro de puntero nulo NULL, como a la nueva palabra clave `nullptr`, disponible desde C++11 y cuyo uso en sustitución de NULL es la práctica recomendada actualmente.

Al diseñar un lenguajes de programación parece bastante conveniente no solo admitir variables que contienen valores, sino también variables que contienen direcciones que apuntan a otra variables u objetos en la memoria.  Para estas últimas parece interesante tener la opción de señalar cuando no apunta a nada, haciendo que surja el concepto de nulo.

Obviamente dentro de este tipo de variables entran los punteros de C++, pero también cualquier variable no primitiva  —variables de objetos—  en lenguajes como Java, C# y otros. Porque aunque estos lenguajes eliminaron los punteros con la intención de crear lenguajes más seguros, lo cierto es que en ellos las variables de cualquier tipo de objeto son muy parecidas a los punteros de C++. Contienen la dirección a los objetos y no los objetos en si mismos. Por eso esas variables pueden valer nulo y es importante comprobarlo antes de hacer uso de las mismas, como ocurre con los punteros en C++.

En ese sentido lo que realmente hicieron los diseñadores de Java y otros lenguajes, no fue eliminar los punteros, sino esconderlos y suprimir — o solo permitir su uso en bloques de código marcados de forma especial, como ocurre en C# — algunas de sus características mas peligrosas. Ejemplos de estas características restringidas son la [aritmética de punteros](https://es.wikipedia.org/wiki/Puntero_%28inform%C3%A1tica%29#C_y_C++) o la posibilidad de apuntar a direcciones arbitrarias de la memoria:
`int* a = 0xfffe1234;    // a apunta a una dirección cualquiera`

Pero el hecho es que desde el punto de vista del uso y los peligros del abuso de NULL, los punteros de C++ y las variables usadas para pasar objetos por referencia en esos lenguajes, no son muy diferentes, presentando problemas y soluciones muy parecidas en todos ellos.

**_NOTA:_** _Me parece un acierto la decisión de que en Go los punteros no se escondan sino que se usen de forma explícita. Al igual que en Java, Go no soporta aritmética de punteros ni otras características peligrosas, pero los punteros se declaran y usan de forma explícita con “*”, como ocurre en C y en C++. Eso facilita detectar de un vistazo posibles problemas._

### Usa el Valor Luke…

Si el concepto de nulo está vinculado a los punteros, la solución más directa para evitar los problemas de NULL es evitar utilizar punteros, utilizando _variables de tipo valor_ todo lo posible.

En otros lenguajes solo los tipos primitivos  —como _int_, _float_ o _byte_ —  son de _tipo valor_. Es decir, que el valor se almacenen en la variable. Mientras que los tipos más complejos son de _tipo referencia_, de forma que las variables lo que almacenan es la dirección del objeto en la memoria —un puntero — . 

En C++ no existe esta restricción. Tantos los tipos primitivos como las clases, por complejas que sean, son por defecto de tipo valor. Los datos del objeto se almacenan en la propia variable, a menos que indiquemos explícitamente que queremos un puntero o una referencia.

Lo interesante es que las variables de tipo valor siempre son un objeto válido Nunca pueden valer nulo porque eso es cosa de punteros:
`MiClase a = nullptr;  
// **error:** conversion from &#39;**std::nullptr_t**&#39; to non-scalar type  
// &#39;**MiClase**&#39; requested`

En algunos casos, asignaciones como la anterior pueden compilar si la clase tiene un operador de asignación o un constructor adecuado para admitir la asignación de un NULL. Por ejemplo es el caso de `std::string`:
`std::string s = nullptr;`

Pero incluso así el objeto _s_ es perfectamente válido. Se puede acceder a sus métodos y atributos con total normalidad. Simplemente el desarrollador a interpretado de alguna forma lo que significa asignar un NULL a un `std::string`  — en este caso concreto que _s_ sea una cadena vacía — .

Lamentablemente las variables de tipo valor no se puede utilizar en todos los casos. Antes de C++11, esto era especialmente cierto. Prácticamente era imposible evitar el uso de punteros y crear objetos dinámicamente con el operador `new`. Basta con examinar el código de cualquier proyecto de los 90 para comprobar  — para mi un buen ejemplo de este tipo de código antiguo es la librería Qt — .

Por fortuna, las distinta adiciones al lenguaje desde la versión C++11 han ido en la línea de dotarlo de cada vez más características para facilitar el uso de tipos valor todo lo posible en C++ moderno. Eso no solo permite que nos olvidemos de NULL y sus problemas, sino del resto de problemas derivados del uso de punteros. **Hoy en día, la capacidad de C++ para trabajar por defecto con tipos valor es considerada como una característica clave y distintiva del lenguaje**.

Probablemente los tipos valor encajen bien en el 80% de nuestras necesidades. Si embargo a veces queremos hacer cosas que no encajan bien del todo con ellos. A continuación veremos algunos de estos casos y su solución.

### Como evitar copias innecesarias

Los objetos de tipo valor se copian al ser asignados. Esto no importa en variables de tipos primitivos, pero es bastante costoso con objetos complejos con decenas de atributos. Lo mismo ocurre al pasar estos objetos como parámetros o retorno de métodos y funciones.
`MiClaseC foo(MiClaseA a, MiclaseB b)  
{  
    ...``    return MiClaseC( ... );  
}`

El usar punteros para resolver este problema nos devolvería a tener que lidiar con los NULL.
`**const MiClaseC*** foo(**const MiClaseA*** a, **const MiclaseB*** b)  
{  
    if (**a == nullptr**) {  
        ...  
    }``    if (**b == nullptr**) {  
        ...  
    }``    ...``    return **new MiClaseC( ... )**;  
}`

Por eso la recomendación es utilizar referencias para evitar las copias:
`**MiClaseC** foo(**const MiClaseA&amp;** a, **const MiclaseB&amp;** b)  
{  
    ...``    return MiClaseC( ... );  
}`

Las referencias en C++ no son como las referencias en otros lenguajes  —que más bien se parecen a punteros disimulados — . No puede valer NULL, siempre hay que inicializarlas y no se pueden reasignar, por lo que son mucho más seguras:
`MiClase&amp; a = nullptr;  
// **error:** invalid initialization of non-const reference of type  
// &#39;**MiClase&amp;**&#39; from an rvalue of type &#39;**std::nullptr_t**&#39;``MiClase&amp; b;  
// **error:** &#39;b&#39; declared as reference but not initialized`

### Cuando el tiempo de vida del objeto es mayor que el alcance donde se crea

Es importarte fijarse que en el ejemplo anterior con referencias, el valor de retorno se copia, no se devuelve por referencia:
`**MiClaseC** foo(const MiClaseA&amp; a, const MiclaseB&amp; b)  
{  
    ...``    return MiClaseC( ... );  
}`

Como sabe cualquier programador de C++, el motivo es que el objeto MiClaseC se crea dentro de la función y que al terminar esta se destruye. Si devolviéramos una referencia, esta referencia fuera de la función señalaría a un objeto que ya no existe. Por eso, en el C++ que aprendimos todos, si queríamos crear un objeto dentro de una función para ser usarlo desde fuera, prácticamente estábamos condenados a usar el operador `new`, para que el objeto se creara dinámicamente y no se destruyera al salir, y devolver el objeto como puntero.
`**const MiClaseC*** foo( ... )  
{  
    ...``    return **new MiClaseC( ... )**;  
}`

Hoy, como hemos visto antes, la recomendación es devolver el objeto resultado siempre por valor:
`**MiClaseC** foo( ... )  
{  
    ...``    return MiClaseC( ... );  
}`

y dejar en manos del compilador [ciertas optimizaciones](https://en.cppreference.com/w/cpp/language/copy_elision) que se incorporaron al estándar a partir de C++11 y que evitan la copia del objeto en un muchos de los casos.

Incluso si las reglas para omitir la copia no se cumplen, el compilador primero intentará mover el objeto que está dentro de la función, a punto de desaparecer, al objeto que recibe el resultado en la función invocadora. Solo si esto no fuera posible  —porque no se ha implementado en la clase la semántica de mover objetos, introducida también en C++11 —  el objeto sería copiado.

### Objetos no copiables

A veces interesa tener objetos con una identidad propia. Es decir, evitar que se puedan crear clones, manteniendo una única instancia a la que se hace referencia desde distintos lugares del programa.

Esto puede ser por distintos motivos, pero uno muy común es porque cada objeto de ese tipo representa un recurso que no puede ser copiado fácilmente. Por ejemplo, cada instancia de la clase `std::thread` representa a un hilo en el proceso actual. Estos objetos no se pueden copiar porque si se permitiera ¿qué se supone que debería pasar con el hilo gestionado por el objeto?

*   ¿Tal vez crear una copia exacta del hilo en el mismo estado que el original para que sea gestionado por la nueva copia del objeto?. Quizás por los problemas que podría dar  — si fuera posible hacerlo —  los sistemas operativos no suelen tener funciones para clonar hilos. Además ¿era ese el comportamiento esperado por el programador al copiar el objeto?.
*   Tal vez es mas intuitivo hacer que las distintas instancias copiadas sirvan para gestionar un mismo hilo. Pero entonces ¿qué pasa si una de las copias se destruye? ¿debe terminar el hilo o no? ¿se debe idear algún mecanismo para que termine el hilo cuando todas las copias sean destruidas? cuando el hilo termine ¿qué hacemos con las copias cuando intenten manipular el hilo?.

Al final lo más sencillo es que las que las instancias de `std::thread` se comporte como el recurso que gestiona. Es decir, que no se puedan crear copias.

Esto no solo ocurre con los objetos que representan los hilos de un proceso. Pasa igual con los que representan archivos abiertos, sockets y conexiones de red, regiones de la memoria, ventanas, dispositivos abiertos u otros recursos del sistema operativo. También ocurre con determinadas abstracciones del dominio de nuestro programa, como puede una clase que representa un repositorio de documentos o algún servicio o gestor de algún tipo, donde no tiene significado eso de “hacerles copias”.

Referencias, move y smart pointers. y polimorfismo

### Opcionalidad

A veces queremos poder expresar opcionalidad. Por ejemplo, aceptar en una función un argumento pero que indicarlo sea opcional para el que llama. En ese caso pasar el argumento a través de un puntero indicando con un NULL cuando no queremos especificarlo, es la solución más común.

Retorno de punteros

[GotW-ish Solution: The &#39;clonable&#39; pattern](https://herbsutter.com/2019/10/03/gotw-ish-solution-the-clonable-pattern/)


[https://docs.microsoft.com/en-us/cpp/cpp/value-types-modern-cpp?view=vs-2019](https://docs.microsoft.com/en-us/cpp/cpp/value-types-modern-cpp?view=vs-2019)

Smart pointers

gsl:null

std::optional

### Otras

mull

[https://medium.com/@elizarov/null-is-your-friend-not-a-mistake-b63ff1751dd5](https://medium.com/@elizarov/null-is-your-friend-not-a-mistake-b63ff1751dd5)
