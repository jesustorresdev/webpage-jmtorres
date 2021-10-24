---
title: "Conversión de tipos en C++"
author: "Jesús Torres"
#date: 2013-05-05T00:00:00.000Z

summary: |
  Al igual que ocurre en C, el compilador de C++ soporta convertir variables de un tipo en otro diferente.
  C++ permite indicar estas conversiones mediante la misma sintaxis que C, pero lo recomendado es utilizar los
  operadores específicos que C++ tiene para eso.

code:
  maxShownLines: -1

toc: false
tags:
 - C++
 - Programación

featuredImage: "images/1.png" 
images:
 - "images/1.png" 

aliases:
 - "/conversión-de-tipos-en-c-ce37d8ba7e46"
---

En C el compilador es capaz de hacer ciertas conversiones de tipos de forma automática ---o implícita---.
Por ejemplo, ir de `char` a `int` o de este a `float` es algo que ace el compilador sin que nos demos cuenta:

{{< highlight c >}}
int i = 10;  
float d = i;        /* correcto */
{{< / highlight >}}

Sin embargo, hay conversiones que no son válidas:

{{< highlight c >}}
int* i = NULL;  
float* d = i;       /* conversión inválida de 'int*' a 'float*' */
{{< / highlight >}}

cuyo comportamiento por defecto es no es el deseado:

{{< highlight c >}}
int a = 10;  
int b = 7;  
float c = a / b;    /* c = 1.0 y no 1.4, como podría esperarse */
{{< / highlight >}}

Para esos casos el lenguaje nos permite forzar la conversión de tipos, utilizando una expresión de _typecast_ de la forma `(type)object` ---o `type(object)`--- indicando así que queremos convertir `object` al tipo especificado por `type`.
Por ejemplo:

{{< highlight c >}}
int a = 10;  
int b = 7;  
float c = (float)a / (float)b;  /* c = 1.4 */
{{< / highlight >}}

En C++ se puede utilizar la misma expresión de _typecast_ que en C, aunque no es lo más aconsejable.
En su lugar C++ ofrece diversos operadores de _typecast_ cuyo uso es más adecuado y menos peligroso que la conversión de tipos _estilo C_.

## static_cast

El operador:

{{< highlight cpp >}}
static_cast(object)
{{< / highlight >}}

es siempre el primer tiempo de conversión que debemos intentar utilizar.

Permite invocar conversiones implícitas entre tipos ---es decir, esas conversiones automáticas del compilador que mencionamos al principio---.
Por ejemplo, de `int` a `float`:

{{< callouts >}}
{{< highlight cpp >}}
int a = 10;  
float d = static_cast<float>(a);    // correcto <1>
{{< / highlight >}}
1. Equivalente a `float d = a`, ya que esta conversión se hace de forma implícita.
{{< /callouts >}}

o para hacer una división de enteros en coma flotante:

{{< highlight cpp >}}
int a = 10;  
int b = 7;  
float c = static_cast<float>(a) / static_cast<float>(b); // c = 1.4  
// float c = a / b                                       // c = 1.0
{{< / highlight >}}

Permite la conversión de cualquier tipo de puntero a `void*`:

{{< callouts >}}
{{< highlight cpp >}}
int* pa = nullptr;  
void* pb = static_cast<void*>(pa);  // correcto <1>
{{< / highlight >}}
1. Equivalente a `void* pb = pa`, ya que la conversión de cualquier puntero a `void*` se hace de forma implícita.
{{< /callouts >}}

y a la inversa ---que no es una conversión implícita---:

{{< callouts >}}
{{< highlight cpp >}}
void* pa = nullptr;  
char* pb = static_cast<char*>(pa);  // correcto
// char* pb = pa;                   // ¡error! <1>
{{< / highlight >}}
1. La conversión de `void*` a otros tipos de punteros no se hace de forma implícita.
{{< /callouts >}}

De hecho, para reservar 10 caracteres con `malloc()` sería algo así:

{{< highlight cpp >}}
char* c = static_cast<char*>(malloc(10 * sizeof(char)));
{{< / highlight >}}

ya que la conversión del puntero `void*` que retorna `malloc()` a `char*` necesita un _typecast_.

En el caso de objetos, `static_cast` llama a los operadores de conversión explícitos definidos en las clases:

{{< callouts >}}
{{< highlight cpp >}}
class Foo  
{  
    ...
    
    operator const char*() <1>
    {  
        ...  
    }  
};

Foo foo;

char* c = static_cast<char*>(foo);  // correcto <2>
{{< / highlight >}}
1. Definición del operador de conversión de objetos `Foo` a `const char*`.
2. Equivalente a `char* c = foo`.
Tanto si se usa `static_cast` como con la conversión implícita, se llama al método de conversión `operator const char*()` de la clase `Foo`.  
{{< /callouts >}}

`static_cast` también convierte de clases bases a derivadas en una jerarquía de clases.
La conversión inversa, de clases derivadas a clase base es automática, siempre que no haya polimorfismo.
Es decir, siempre que la clase base no tenga algún método virtual:

{{< callouts >}}
{{< highlight cpp >}}
class Base  
{  
    ...  
};

class Derived: public Base  
{  
    ...  
};

Derived* derived = new Derive;  
Base* base = derived;                                    <1>

Derived* derived_de_nuevo = static_cast<Derived*>(base); <2>
{{< / highlight >}}
1. Conversión implícita de puntero a `Derived` a puntero a `Base`.
2. Eecuperamos el puntero a `Derived` a partir del puntero a `Base`.
{{< / callouts >}}

Hay que tener en cuenta que las conversiones `static_cast` se resuelven siempre en **tiempo de compilación**, por lo que no se comprueba si el tipo al que se convierte coincide con el tipo real del objeto.
Por ejemplo, no se comprueba que en el ejemplo anterior el puntero `base` realmente apunta a un objeto creado inicialmente al instanciar la clase `Derived`.
El estándar indica que queda indefinido lo que pueda pasar si se convierte de un tipo base a uno derivado cuando este último no es el tipo real del objeto:

{{< callouts >}}
{{< highlight cpp >}}
class Base  
{  
    ...  
};

class Derived: public Base  
{  
    ...  
};

Base* base = new Base;

Derived* derived = static_cast<Derived*>(base); // ¡indefinido! <1>
{{< / highlight >}}
1. Intentamos obtener un puntero a `Derived` para un objeto creado directamente como `Base`. 
{{< / callouts >}}

## dynamic_cast

El operador:

{{< highlight cpp >}}
dynamic_cast(object)
{{< / highlight >}}

se utiliza exclusivamente para manejar el polimorfismo ya que permite convertir un puntero o referencia de un tipo polimórfico ---esto es, una clase con algún método virtual--- a cualquier otro tipo.
Eso no solo permite convertir de clases base a derivadas, sino también desplazarnos lateralmente e incluso movernos a una cadena de herencia diferente dentro de una misma jerarquía de clases.

{{< callouts >}}
{{< highlight cpp >}}
class Base  
{  
    ...
   
    virtual ~Base() {} <1>
};

class Derived: public Base  
{  
    ...  
};

Derived* derived = new Derive;  
Base* base = derived; <2>

Derived* derived_de_nuevo = dynamic_cast<Derived*>(base); <3>
{{< / highlight >}}
1. Declaramos el destructor virtual para que la clase sea polimórfica.
2. Conversión implícita de puntero a objeto de clase derivada a puntero a objeto de su clase base.
3. Recuperamos el puntero a `Derived` a partir del puntero a `Base` usando `dynamic_cast`.
{{< / callouts >}}

`dynamic_cast` busca en **tiempo de ejecución** el objeto del tipo deseado en la jerarquía del objeto, devolviéndolo en caso de encontrarlo.
Si los tipos no son compatibles ---por ejemplo, si el objeto no fue creado originalmente con el tipo o con un tipo derivado del tipo indicado--- `dynamic_cast` devuelve `nullptr`, si se está trabajando con puntero, o lanza una excepción `std::bad_cast`, si se está trabajando con referencias.

{{< callouts >}}
{{< highlight cpp >}}
class Base  
{  
    ...
    
    virtual ~Base() {} <1>
};

class Derived: public Base  
{  
    ...  
};

Base* base = new Base;

Derived* derived = dynamic_cast<Derived*>(base); // = nullptr ¡error! <2>
{{< / highlight >}}
1. Declaramos el destructor virtual para que  la clase sea polimórfica.  
2. Al intentar obtener un puntero `Derived` para el objeto creado como `Base` se obtiene `nullptr`.
{{< / callouts >}}

## const_cast

El operador:

{{< highlight cpp >}}
const_cast(object)
{{< / highlight >}}

se usa exclusivamente para eliminar o añadir `const` a una variable, ya que esto es algo que no pueden hacer los otros operadores de _typecast_.

Añadir `const` a un tipo es una conversión implícita:

{{< callouts >}}
{{< highlight cpp >}}
int a = 10;  
const int b = const_cast<const int>(a); // correcto <1>
{{< / highlight >}}
1. Equivalente a `const int b = a`, pues añadir `const` a un tipo es una conversión implícita.
{{< / callouts >}}

pero quitarlo no:

{{< callouts >}}
{{< highlight cpp >}}
const int a = 10;  
int b = const_cast<int>(a); // correcto
// int b = a;               // ¡error! <2>
{{< / highlight >}}
1. No se puede quitar el `const` de forma implícita.
{{< / callouts >}}

Es importante destacar que su uso queda indefinido si la variable original realmente es constante.
Por ejemplo, algunos compiladores optimizan las constantes reemplazándolas, allí dónde son utilizadas, directamente por el valor asignado.
En ese caso, intentar modificar la variable tiene un resultado indefinido.

## reinterpret_cast

El operador:

{{< highlight cpp >}}
reinterpret_cast(object)
{{< / highlight >}}

instruye al compilador para que una expresión de un tipo sea tratada sin más como de un tipo diferente.
No se genera código para llevar acabo la conversión de los datos y, por tanto, es el más peligroso de los operadores de _typecast_.

Se utiliza para convertir punteros de un tipo a otro de forma arbitraria.
Por ejemplo, si se recibe un flujo de bytes como un `char*` pero dichos bytes realmente son una secuencia de enteros, con `reinterpret_cast` se puede convertir el puntero `char*` en `int*` para facilitar recuperar cada uno de los números de la secuencia.

También se puede utilizar para convertir un puntero en un entero para manipular la dirección directamente:

{{< callouts >}}
{{< highlight cpp >}}
char* c = new char[15];  
uintptr_t p = reinterpret_cast<uintptr_t>(c) <1>
{{< / highlight >}}
1. Obtener un entero `p` que almacena la dirección de `c` en la memoria.
{{< / callouts >}}

La única garantía ofrecida por el estándar de C++ es que si se hace un `reinterpret_cast` y posteriormente se realiza otro para volver al tipo original, se obtiene el mismo resultado, siempre que el tipo intermedio tenga el tamaño suficiente para que no se pierda información.

## Conversión estilo C

Si en C++ se indica una conversión de _estilo C_ ---usando la sintaxis tradicional `(type)object` o `type(object)`--- el efecto será el mismo que la primera conversión de la siguiente lista que tenga éxito:

1.  **const_cast**.
2.  **static_cast**.
3.  **static_cast** y después **const_cast**.
4.  **reinterpret_cast**
5.  **reinterpret_cast** y después **const_cast**.

Usar en C++ _typecasts_ _estilo C_ es peligroso porque pueden convertirse en un `reinterpret_cast` sin pretenderlo.
Si hace falta este tipo de conversión, es preferible indicarlo explícitamente en el código usando el operador `reinterpret_cast`.

Además, la conversión _estilo C_ ignora el control de acceso de las clases ---_protected_ o _private_--- por lo que este tipo de conversión permite hacer operaciones que con los operadores de C++ no se puede.
Por ejemplo, en el siguiente caso la compilación termina con un error:

{{< highlight cpp >}}
class Base  
{  
    ...  
};

class Derived: protected Base  
{  
    ...  
};

Derived* derived = new Derived;  
Base* base = static_cast<Base*>(derived);   // ¡error!
{{< / highlight >}}

ya que la clase `Base` es una clase base protegida de `Derived`.
Sin embargo el ejemplo compila sin problemas usando tanto `reinterpret_cast` como un _typecast estilo C_:

{{< highlight cpp >}}
class Base  
{  
    ...  
};

class Derived: protected Base  
{  
    ...  
};

Derived* derived = new Derived;  
Base* base = reinterpret_cast<Base*>(derived);  // correcto  
//Base* base = (Base*)derived;                  // correcto
{{< / highlight >}}

## Referencias

* [When should static_cast, dynamic_cast and reinterpret_cast be used?](http://stackoverflow.com/questions/332030/when-should-static-cast-dynamic-cast-and-reinterpret-cast-be-used)
* [static_cast restricts access to public member function?](http://stackoverflow.com/questions/8548667/static-cast-restricts-access-to-public-member-function)
