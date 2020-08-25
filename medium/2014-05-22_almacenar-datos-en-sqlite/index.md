---
title: "Almacenar datos en SQLite"
author: "Jesús Torres"
date: 2014-05-22T00:00:00.000Z

description: ""

subtitle: ""

image: "/posts/2014-05-22_almacenar-datos-en-sqlite/images/1.png" 
images:
 - "/posts/2014-05-22_almacenar-datos-en-sqlite/images/1.png" 


aliases:
    - "/almacenar-datos-en-sqlite-2e6785462cc4"
---

{{< figure src="/posts/2014-05-22_almacenar-datos-en-sqlite/images/1.png" >}}

Muchos de los sistemas de gestión de bases de datos relacionales más conocidos son de arquitectura cliente-servidor --- por ejemplo MySQL, PostgreSQL u Oracle --- .
Es decir, que están compuestos por un programa servidor --- que es quien tiene acceso local a los datos --- de forma que uno o más programas cliente pueden solicitarle operaciones sobre dichos datos --- generalmente mediante lenguaje SQL --- .

Esta arquitectura puede no ser la adecuada en cierto tipo de aplicaciones.
Por ejemplo, si desarrollamos un software de agenda de contactos para sistemas de escritorio, el uso de bases de datos relacionales para almacenar la información puede resultar natural, pero distribuir nuestra aplicación junto a un sistema de gestión de bases de datos tradicional --- como MySQL --- seguramente sea un tanto excesivo.

Para estos casos existen otros gestores que no hacen uso de este tipo de arquitectura.
Por ejemplo [SQLite](http://www.sqlite.org/), que es una sencilla librería que contiene en si misma un completo sistema de gestión de bases de datos; de tal forma que las aplicaciones que la utilizan pueden acceder a los archivos y manipular los datos por si mismas, mediante consultas SQL, si necesitar la intermediación de un programa servidor.

Además de con la librería, [SQLite](http://www.sqlite.org/) viene acompañado de una sencilla utilidad de línea de comandos --- en sistemas Debian y derivados esta herramienta viene en su propio paquete bajo el nombre de `sqlite3` --- que permite realizar tareas tales como: manipular el archivo de base de datos, examinar su contenido, hacer consultas SQL, etc.
Además también existen herramientas gráficas, como [Sqliteman](http://sqliteman.com/), que se pueden usar con el mismo fin, pero que pueden resultar un poco más sencillas.
En cualquier caso, ambas herramientas nos permiten examinar la base de datos con el objeto de comprobar si nuestro programa funciona como esperamos.

## Casos de uso de SQLite

[SQLite](http://www.sqlite.org/) es usada por muchos _frameworks_ --- por ejemplo Django o Ruby On Rails --- como base de datos por defecto durante el desarrollo de nuevos proyectos.
La ventaja de esto es que así se puede trabajar desde el primero momento con bases de datos relacionales, sin tener que preocuparnos por configurar adecuadamente ningún sistema gestor tradicional.

Como estos _frameworks_ suelen proveer soporte para diversos gestores en el momento de desplegar la aplicación se puede cambiar, prácticamente sin cambios en el código, a otro sistema gestor, si las necesidades de la aplicación así lo indican.

Además [SQLite](http://www.sqlite.org/) se adapta perfectamente a las necesidades de muchas aplicaciones de escritorio y de dispositivos móviles.
Por ese motivo es utilizada ámpliamente en los archivos de datos de aplicaciones como Mozilla Firefox o Google Chrome y se incluye por defecto en cualquier dispositivo Android, permitiendo que las aplicaciones creen sus propias bases de datos sin necesitar ningún tipo de configuración.

## Acceso a bases de datos mediante Qt SQL

[Qt](https://jmtorres.webs.ull.es/me/2013/01/proyecto-qt-framework-de-desarrollo-de-aplicaciones) integra el módulo [Qt SQL](http://qt-project.org/doc/qt-5.0/qtsql/qtsql-index.html) que provee acceso a diferentes gestores de bases de datos SQL, entre los que podemos destacar MySQL, PostgreSQL, Oracle, gestores compatibles con [ODBC](http://es.wikipedia.org/wiki/Open_Database_Connectivity) y [SQLite](http://www.sqlite.org/).

Para todos estos casos lo primero es instanciar un objeto de la clase `[QSqlDatabase](http://qt-project.org/doc/qt-5.0/qtsql/qsqldatabase.html)` indicando el gestor al que nos queremos conectar:
``QSqlDatabase *db = new QSqlDatabase("QSQLITE");``

para después indicar el nombre de la base de datos que nos interesa:
``db->setDatabaseName("data.sqlite");``

El formato del nombre de la base de datos depende del controlador del gestor que hayamos escogido.
Por ejemplo, para el driver `QODBC` el nombre puede ser un [DSN](http://es.wikipedia.org/wiki/Data_Source_Name), un archivo [DSN](http://es.wikipedia.org/wiki/Data_Source_Name) (en cuyo caso su nombre debe terminar en extensión `.dsn`) o una cadena de conexión [ODBC](http://es.wikipedia.org/wiki/Open_Database_Connectivity).
Mientras que para [SQLite](http://www.sqlite.org/) el nombre de la base de datos es directamente el del archivo que la contiene ---`data.sqlite` en nuestro ejemplo---.

Finalmente es necesario abrir la conexión a la base de datos usando el método `[QSqlDatabase](http://qt-project.org/doc/qt-5.0/qtsql/qsqldatabase.html)::[open](http://qt-project.org/doc/qt-5.0/qtsql/qsqldatabase.html#open)()`, del que es conveniente comprobar el valor de retorno para determinar si hemos tenido éxito.
``if (!db->open()) {  
    QMessageBox::critical(NULL, tr("Error"),  
        tr("No se pudo acceder a los datos.");  
    return false;  
}``

## Haciendo consultas SQL

La conexión creada de la manera que hemos descrito anteriormente se configura automáticamente como la conexión a base de datos por defecto de nuestra aplicación.
Así que hacer una consulta es tan sencillo como instanciar la clase `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)` y proporcionarle la sentencia SQL a dicho objeto a través del método `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)::[exec](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html#exec)()`:
``QSqlQuery query;  
query.exec("SELECT * FROM TABLE contactos");``

De esta forma `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)` puede utilizarse tanto para ejecutar sentencias de manipulación --- como `SELECT`, `INSERT`, `UPDATE` y `DELETE`--- como de definición ---por ejemplo `CREATE TABLE` y similares---.
``query.exec("CREATE TABLE IF NOT EXISTS contactos "  
            "(id INTEGER PRIMARY KEY AUTOINCREMENT,"  
            " nombre VARCHAR(50))");``

Además también pueden ejectuarse comandos específicos del gestor de base de datos que no formen parte del estándar SQL.

### SELECT

Al hacer una consulta que devuelve datos --- como es el caso de los `SELECT`--- se pueden usar los siguientes métodos sobre el mismo objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)` para posicionar la consulta en las distintas filas de resultados:

`bool next()`  
Recupera la siguiente fila en la lista de resultados y posiciona allí el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)`.

`bool previous()`  
Recupera la fila previa en la lista de resultados y posiciona allí el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)`.

`bool first()`  
Recupera la primera fila de la lista de resultados y posiciona allí el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)`.

`bool last()`  
Recupera la última fila de la lista de resultados y posiciona allí el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)`.

`seek(int index, bool relative = false)`  
Recupera la fila en la posición `index` y posiciona allí el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)`.
La primera fila es la 0.

Una vez el objeto `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)` ha sido posicionado en la fila que nos interesa, podemos recuperar el dato en la columna `index` empleando el método `value(index)`.
``query.exec("SELECT nombre FROM contactos");  
while (query.next()) {  
    QString nombre = query.value(0).toString();  
    doSomething(nombre);  
}``

Todos los datos recuperados de esta manera se devuelven usando instancias de la clase `[QVariant](http://qt-project.org/doc/qt-5.0/qtcore/qvariant.html)`, por lo que se pueden convertir al tipo que nos interese usando los métodos `QVariant::to*`.

### INPUT y UPDATE

`[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)` permite preparar la ejecución de la consulta para después sustituir parámetros en ciertos marcadores de posición antes de ejecutarla finalmente.
Esto es especialmente útil cuando se pretenden hacer inserciones y actualizaciones en la base de datos.

La sustitución puede indicarse tanto mediante nombres:
``QSqlQuery query;  
query.prepare("INSERT INTO contactos (nombre, apellido) "  
              "VALUES (:nombre, :apellido)");  
query.bindValue(":nombre", "Jesús");  
query.bindValue(":apellido", "Torres");  
query.exec();``

como usando posiciones:
``QSqlQuery query;  
query.prepare("INSERT INTO contactos (nombre, apellido) "  
              "VALUES (?, ?)");  
query.bindValue(0, "Jesús");  
query.bindValue(1, "Torres");  
query.exec();``

En cualquier caso, el método `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)::[numRowsAffected](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html#numRowsAffected)()` puede utilizarse para conocer cuantas filas se han visto afectadas por una sentencia no `SELECT`.
Mientras que para sentencias `SELECT` se puede determinar cuantas filas han sido recuperadas utilizando el método `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)::[size](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html#size)()`.

Finalmente, el método `[QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html)::[lastInsertId](http://qt-project.org/doc/qt-5/qsqlquery.html#lastInsertId)()` hace posible conocer el identificador de la última fila insertada, lo que es especialmente interesante cuando se usan tablas con [claves foráneas](https://es.wikipedia.org/wiki/Clave_for%C3%A1nea).
``QSqlQuery query;````// Insertar un nuevo contacto  
query.prepare("INSERT INTO contactos (nombre, apellido) "  
              "VALUES (:nombre, :apellido)");  
query.bindValue(":nombre", "Jesús");  
query.bindValue(":apellido", "Torres");  
query.exec();````// Obtener el identificador de la fila del nuevo contacto  
int contactoId = query.lastInsertId().toInt();````// Añadir una dirección de correo profesional vinculada  
// al nuevo contacto  
query.prepare("INSERT INTO emails (contacto_id, tipo, email) "  
              "VALUES (:contacto_id, :tipo, :email)");  
query.bindValue(":contacto_id", contactoId);  
query.bindValue(":tipo", "Profesional");  
query.bindValue(":email", "jmtorres@ull.es");  
query.exec();``

## Referencias

*   [Qt SQL](http://qt-project.org/doc/qt-5.0/qtsql/qtsql-index.html)
*   [QSqlDatabase](http://qt-project.org/doc/qt-5.0/qtsql/qsqldatabase.html).
*   [QSqlQuery](http://qt-project.org/doc/qt-5.0/qtsql/qsqlquery.html).
