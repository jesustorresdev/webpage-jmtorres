---
title: "Resource Interchange File Format"
author: "Jesús Torres"
date: 2013-05-12T00:00:00.000Z
lastmod: 2020-06-03T11:41:30+01:00

description: ""

subtitle: ""

image: "/posts/2013-05-12_resource-interchange-file-format/images/1.jpg" 
images:
 - "/posts/2013-05-12_resource-interchange-file-format/images/1.jpg" 


aliases:
    - "/resource-interchange-file-format-258ad4bfac0a"
---

![image](/posts/2013-05-12_resource-interchange-file-format/images/1.jpg)

Container — [Izabela Reimers](https://www.flickr.com/photos/33280166@N02/5354725682/), License [CC-BY-NC-SA-2.0](https://creativecommons.org/licenses/by-nc-sa/2.0/)

El [Resource Interchange File Format](http://en.wikipedia.org/wiki/Resource_Interchange_File_Format) o [RIFF](http://en.wikipedia.org/wiki/Resource_Interchange_File_Format) es un formato contenedor genérico diseñado para almacenar datos en forma de fragmentos etiquetados o [chunks](http://en.wikipedia.org/wiki/Chunk_%28information%29). Siendo usado en la actualidad como formato contenedor de los conocidos formatos de archivo AVI, ANI y WAV de Microsoft, es indudable que resulta especialmente útil para almacenar contenidos multimedia, aunque realmente puede almacenar cualquier tipo de información.

### Tipos de fragmentos

Hay dos tipos de fragmentos en un archivo [RIFF](http://en.wikipedia.org/wiki/Resource_Interchange_File_Format). El más básico son los [chunks](http://en.wikipedia.org/wiki/Chunk_%28information%29) o fragmentos de datos propiamente dichos:
``struct Chunk  
{  
    uint32_t type;  
    uint32_t size;  
    uint8_t  data[size];        // contiene datos en general  
};``

donde `type` sirve para identificar el tipo y el formato de los datos que almacena el fragmento y `size` para especificar su tamaño —sin incluir ni el tamaño del campo `type` ni el de `size`—.

El otro tipo de fragmento son las listas:
``struct List  
{  
    uint32_t type;  
    uint32_t size;  
    uint32_t listType;  
    uint8_t  data[size-4];      // contiene otros Chunk o List  
};``

que son aquellos que contienen una colección de otros fragmentos o listas:

*   Las listas se identifican y distinguen de otros fragmentos porque su campo `type` contiene o los 4 caracteres de `RIFF` o los de `LIST`. Pero hay que tener en cuenta que si bien en el archivo se almacenan en `type` los caracteres `&#39;R&#39;`, `&#39;R&#39;`, `&#39;I&#39;`, `&#39;F&#39;` en ese orden, hay que tener en cuenta que al interpretarlo como `uint32_t` en una máquina _little-endian_ no veremos el número 0x52494646 sino 0x46464952.
*   Para este tipo de fragmentos el tamaño en el campo `size` incluye tanto el de los datos almacenados dentro del fragmento como el del campo `listType`.
*   Dentro de la lista los fragmentos que contiene se disponen unos detrás de otros, pero siempre asegurando que cada fragmento comienza en una dirección par — es decir, que se alinean a 16 bits — .

El archivo contenedor en si mismo es una gran fragmento de lista tipo `RIFF` que contiene otros fragmentos. Estos pueden ser _chunks_ o listas de tipo `LIST`. Por lo tanto en una archivo RIFF sólo existe una lista de este tipo, que hace las veces de contenedor de todos los fragmentos del archivo. El valor del campo `listType` del fragmento `RIFF` es una secuencia de 4 bytes que identifica el formato del archivo y se lo conoce como el [FourCC](http://www.fourcc.org/codecs.php) del mismo.

### Estructura general

Para hacernos una idea del formato este sería el esquema de un archivo AVI convencional:
``RIFF (&#39;AVI &#39;  
      LIST (&#39;hdr1&#39;  
            AVIH (&lt;cabecera principal del AVI&gt;)  
            LIST (&#39;str1&#39;  
                  STRH (&lt;cabecera del flujo&gt;)  
                  STRF (&lt;formato del flujo&gt;)  
                  ...  
            )  
            ...  
      )  
      LIST (&#39;movi&#39;  
            {Chunk | LIST (&#39;rec &#39;  
                           Chunk1  
                           Chunk2  
                           ...  
                     )  
             ...  
            }  
            ...  
      )  
      [IDX1 (&lt;índice AVI&gt;)]  
)``

Donde los identificadores en mayúsculas denotan el valor del campo `type` al comienzo de un fragmento. Este siempre es seguido por el campo `size`, que no se muestra en el esquema anterior. Por otro lado el valor de los campos `listType` de los fragmentos de tipo lista se indica entre comillas simples. Para observar una estructura real de archivo RIFF se puede utilizar el programa [rifftree](https://manned.org/rifftree/8b35d536) del paquete `gigtools` con cualquier archivo `.avi` o `.wav` que tengamos a mano.

### Mi rifftree

Para ilustrar lo comentado sobre los archivos RIFF, he publicado en GitHub [mi propia versión de rifftree](http://github.com/aplatanado/rifftree). Está desarrollada con [Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones/) y hace uso del mapeo de archivos en memoria para simplificar el acceso al archivo RIFF.

### Referencias

1.  Wikipedia — [Resource Interchange File Format](http://en.wikipedia.org/wiki/Resource_Interchange_File_Format)
2.  MSDN — [AVI RIFF File Reference](http://msdn.microsoft.com/en-us/library/ms779636%28VS.85%29.aspx)
3.  [AVI File Format](http://www.alexander-noe.com/video/documentation/avi.pdf)
4.  [FourCC](http://www.fourcc.org/codecs.php)
