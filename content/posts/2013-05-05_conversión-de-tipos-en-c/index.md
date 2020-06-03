---
title: "Conversión de tipos en C++"
author: "Jesús Torres"
date: 2013-05-05T00:00:00.000Z
lastmod: 2020-06-03T11:41:29+01:00

description: ""

subtitle: ""

image: "/posts/2013-05-05_conversión-de-tipos-en-c/images/1.png" 
images:
 - "/posts/2013-05-05_conversión-de-tipos-en-c/images/1.png" 


aliases:
    - "/conversi%C3%B3n-de-tipos-en-c-ce37d8ba7e46"
---

En C el compilador es capaz de hacer ciertas conversiones de tipos de forma automática — o implícita —. Por ejemplo, ir de `char` a `int` o de este a `float` es algo que ace el compilador sin que nos demos cuenta:
`int i = 10;  
float d = i;       /* correcto */`

Sin embargo, hay conversiones que no son válidas:
`int* i = NULL;  
float* d = i;      /* conversión inválida de &#39;int*&#39; a &#39;float*&#39; */`

cuyo comportamiento por defecto es no es el deseado:
`int a = 10;  
int b = 7;  
float c = a / b;    /* c = 1.0 y no 1.4, como podría esperarse */`

Para esos casos el lenguaje nos permite forzar la conversión de tipos, utilizando una expresión de _typecast_ de la forma `(type)object` —o `type(object)`— indicando así que queremos convertir `object` al tipo especificado por `type`. Por ejemplo:
`int a = 10;  
int b = 7;  
float c = (float)a / (float)b;    /* c = 1.4 */`

En C++ se puede utilizar la misma expresión de _typecast_ que en C, aunque no es lo más aconsejable. En su lugar C++ ofrece diversos operadores de _typecast_ cuyo uso es más adecuado y menos peligroso que la conversión de tipos _estilo C_.




![image](/posts/2013-05-05_conversión-de-tipos-en-c/images/1.png)



### static_cast

El operador:
``static_cast(object)``

es siempre el primer tiempo de conversión que debemos intentar utilizar.

Permite invocar conversiones implícitas entre tipos —es decir, esas conversiones automáticas del compilador que mencionamos al principio — . Por ejemplo, de `int` a `float`:
`int a = 10;  
float d = static_cast&lt;float&gt;(a);    // correcto y equivalente a...  
//float d = a;`

o para hacer una división de enteros en coma flotante:
`int a = 10;  
int b = 7;  
float c = static_cast&lt;float&gt;(a) / static_cast&lt;float&gt;(b); // = 1.4  
//float c = a / b                                        // = 1.0`

Permite la conversión de cualquier tipo de puntero a `void*` —que también ocurre de forma implícita — :
`int* pa = NULL;  
void* pb = static_cast&lt;void*&gt;(pa);    // correcto y equivalente a...  
//void* pb = pa;`

y viceversa — que no es implícita — :
`void* pa = NULL;  
char* pb = static_cast&lt;char*&gt;(pa);   // correcto  
//char* pb = pa;    // conversión inválida de &#39;void*&#39; a &#39;char*&#39;`

De hecho, para reservar 10 caracteres con `malloc()` sería algo así:
`char* c = static_cast&lt;int*&gt;(malloc(10 * sizeof(char)));`

ya que la conversión del puntero `void*` que retorna `malloc()` a `char*` no se hace de forma automática. Hay que hacer un _typecast_.

En el caso de objectos, `static_cast` llama a los métodos de conversión explícitos definidos en las clases:
``class Foo  
{  
    ...```    // Método de conversión a char*  
    `operator const char*()  
    {  
        ...  
    }  
};```Foo foo;``// En los siguientes dos casos se llama al método de conversión  
// Foo::`operator const char*()`.  
char* c = static_cast&lt;char*&gt;(foo);  // correcto y equivalente a...  
//char* c = foo;`

`static_cast` también convierte de clases bases a derivadas en una jerarquía de clases —la conversión inversa, de clases derivadas a clases bases es automática— siempre que no haya polimorfismo. Es decir, siempre que la clase base no tenga algún método virtual:
``class Base  
{  
    ...  
};```class Derived: public Base  
{  
    `...  
};```Derived* derived = new Derive;  
Base* base = derived;                    // conversión implícita``// Recuperamos el puntero a la clase Derived a partir del  
// puntero a la clase Base.  
Derived* derived_de_nuevo = static_cast&lt;Derived*&gt;(base);`

Sin embargo hay que tener en cuenta que las conversiones `static_cast` se resuelven siempre en **tiempo de compilación** y no se comprueba si el tipo al que se convierte coincide con el tipo real del objeto. Por ejemplo, que en el ejemplo anterior el puntero `base` realmente apunta a un objecto creado inicialmente al instanciar la clase `Derived`. El estándar indica que queda indefinido lo que pueda pasar si se convierte de un tipo base a uno derivado cuando este último no es el tipo real del objeto:
``class Base  
{  
    ...  
};```class Derived: public Base  
{  
    `...  
};```Base* base = new Base;``// Intentamos obtener un puntero Derived para un objeto creado  
// directamente como Base.  
Derived* derived = static_cast&lt;Derived*&gt;(base);    // ¡indefinido!`

### dynamic_cast

El operador:
``dynamic_cast(object)``

se utiliza exclusivamente para manejar el polimorfismo ya que permite convertir un puntero o referencia de un tipo polimórfico —esto es, una clase con algún método virtual — a cualquier otro tipo. Esto no solo permite convertir de clases base a derivadas, sino también desplazarnos lateralmente e incluso movernos a una cadena de herencia diferente dentro de una misma jerarquía de clases.
``class Base  
{  
    ...````    // Por ejemplo, declaramos el destructor como virtual para que  
    // la clase sea polimórfica.  
    virtual ~Base() {}  
};```class Derived: public Base  
{  
    `...  
};```Derived* derived = new Derive;  
Base* base = derived;                    // conversión implícita``// Recuperamos el puntero a la clase Derived a partir del  
// puntero a la clase Base usando dynamic_cast()  
Derived* derived_de_nuevo = dynamic_cast&lt;Derived*&gt;(base);`

`dynamic_cast` busca en **tiempo de ejecución** el objeto del tipo deseado en la jerarquía del objeto, devolviéndolo en caso de encontrarlo. Si los tipos no son compatibles —por ejemplo, si el objeto no fue creado originalmente con el tipo o con un tipo derivado del tipo indicado — `dynamic_cast` devuelve `NULL`, si se está trabajando con puntero, o lanza una excepción `std::bad_cast`, si se está trabajando con referencias.
``class Base  
{  
    ...````    // Por ejemplo, declaramos el destructor virtual para que  
    // la clase sea polimórfica.  
    virtual ~Base() {}  
};```class Derived: public Base  
{  
    `...  
};```Base* base = new Base;``// Intentamos obtener un puntero Derived para un objeto creado  
// directamente como Base.  
Derived* derived = dynamic_cast&lt;Derived*&gt;(base);    // = NULL ¡error!`

### const_cast

El operador:
``const_cast(object)``

se usa exclusivamente para eliminar o añadir `const` a una variable, ya que esto es algo que no pueden hacer los otros operadores de _typecast_.

Añadir `const` a un tipo es una conversión implícita:
`int a = 10;  
const int b = const_cast&lt;const int&gt;(a);    // equivalente a...  
//const int b = a;`

pero quitarlo no:
`const int a = 10;  
int b = static_cast&lt;int&gt;(a);   // correcto  
//int b = a;                   // ¡error!`

Es importante destacar que su uso queda indefinido si la variable original realmente es constante. Por ejemplo, algunos compiladores optimizan las constantes reemplazándolas, allí dónde son utilizadas, directamente por el valor que contienen. En casos como ese intentar modificar la variable tiene un resultado indefinido.

### reinterpret_cast

El operador:
``reinterpret_cast(object)``

instruye al compilador para que una expresión de un tipo sea tratada sin más como de un tipo diferente. No se genera código para llevar acabo la conversión de los datos y, por tanto, es el más peligroso de los operadores de _typecast_.

Se utiliza para convertir punteros de un tipo a otro de forma arbitraria. Por ejemplo, si se recibe un flujo de bytes como un `char*` pero dichos bytes realmente son una secuencia de enteros, con `reinterpret_cast` se puede convertir el puntero `char*` en `int*` para facilitar recuperar cada uno de los números de la secuencia.

También se puede utilizar para convertir un puntero en un entero para manipular la dirección directamente:
`char* c = new char[15];  
// Obtener un entero con la dirección a la que apunta &#39;c&#39;.  
uintptr_t p = reinterpret_cast&lt;uintptr_t&gt;(c)`

La única garantía ofrecida por el estándar de C++ es que si se hace un `reinterpret_cast` y posteriormente se realiza otro para volver al tipo original, se obtiene el mismo resultado siempre que el tipo intermedio tenga el tamaño suficiente para que no se pierda información.

### Conversión estilo C

Si en C++ se indica una conversión de _estilo C_ —usando la sintaxis tradicional `(type)object` o `type(object)` — el efecto será el mismo que la primera conversión de la siguiente lista que tenga éxito:

1.  **const_cast**.
2.  **static_cast**.
3.  **static_cast** y después **const_cast**.
4.  **reinterpret_cast**
5.  **reinterpret_cast** y después **const_cast**.

Usar en C++ _typecasts_ _estilo C_ es peligroso porque pueden convertirse en un `reinterpret_cast` sin pretenderlo. Si hace falta este tipo de conversión, es preferible indicarlo explícitamente en el código usando el operador `reinterpret_cast`.

Además la conversión _estilo C_ ignora el control de acceso de las clases — _protected_ o _private_ — por lo que este tipo de conversión permite hacer operaciones que con los operadores de C++ no se puede. Por ejemplo, en este caso el compilador termina con un error:
``class Base  
{  
    ...  
};```class Derived: protected Base  
{  
    `...  
};```Derived* derived = new Derived;  
Base* base = static_cast&lt;Base*&gt;(derived);    // ¡error!`

ya que la clase `Base` es una clase base protegida de `Derived`. Sin embargo el ejemplo compila sin problemas usando tanto `reinterpret_cast` como _typecast_ _estilo C_:
``class Base  
{  
    ...  
};```class Derived: protected Base  
{  
    `...  
};```Derived* derived = new Derived;  
Base* base = reinterpret_cast&lt;Base*&gt;(derived);  // correcto  
//Base* base = (Base*)derived;                  // correcto`

### Referencias

1.  [When should static_cast, dynamic_cast and reinterpret_cast be used?](http://stackoverflow.com/questions/332030/when-should-static-cast-dynamic-cast-and-reinterpret-cast-be-used)
2.  [static_cast restricts access to public member function?](http://stackoverflow.com/questions/8548667/static-cast-restricts-access-to-public-member-function)
