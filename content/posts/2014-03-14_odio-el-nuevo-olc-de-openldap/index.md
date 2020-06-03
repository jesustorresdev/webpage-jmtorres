---
title: "Odio el nuevo OLC de OpenLDAP"
author: "Jesús Torres"
date: 2014-03-14T09:35:03.000Z
lastmod: 2020-06-03T11:41:49+01:00

description: ""

subtitle: ""

image: "/posts/2014-03-14_odio-el-nuevo-olc-de-openldap/images/1.png" 
images:
 - "/posts/2014-03-14_odio-el-nuevo-olc-de-openldap/images/1.png" 


aliases:
    - "/odio-el-nuevo-olc-de-openldap-86d3d51a9724"
---

> Odio el formato de configuración OLC de #OpenLDAP. Menos mal que existe #ldapvi He dicho :-P — [@susotorres](https://twitter.com/susotorres/status/441179272498012160)

Hace años que administro máquinas. Nada importante. Sólo algunos sistemas aquí y allá. Como no es mi trabajo y ya no resulta tan estimulante como antes, me he ido apartando de estos asuntos. Aunque aun tengo algún lastre del que me temo que va a ser muy difícil que me deshaga.

Precisamente uno de esos “cáncamos” pendientes es el servidor de mi departamento en la universidad. Creo que la primera vez que me hice cargo de una encarnación de [_teno_](http://es.wikipedia.org/wiki/Macizo_de_Teno) — así se llama nuestro servidor, ya que solemos hacer uso de topónimos canarios para los nombres — le puse una Debian Woody que años más tarde se convirtió en una Debian Etch. Dentro los huésped típicos: Samba, OpenLDAP, Qmail, Postfix, Sympa, Apache, PostgreSQL, MySQL, PHP, Drupal, Python, Plone, Trac, Subversion, Git, Java, etc. Alguno de los cuales, en estos doce años, se fue reemplazado por otro, según las necesidades del momento.

En Debian Etch estaba la cosa cuando hace casi un año los discos comenzaron a fallar y decidimos migrar a una nueva infraestructura. Así que varias sorpresas me he llevado cuando, oxidado por los años dedicado a mal mantener lo que había, me he dado de bruces al montar algunos de estos servicios en una distribución Debian moderna. El primer traspiés, y seguramente el que más me molesta, es la nueva forma de configurar OpenLDAP.

#### On-Line Configuration (OLC)

Hasta donde yo sabía [OpenLDAP](http://www.openldap.org/) se configuraba estáticamente a través de un fichero de texto. Cada vez que se cambiaba algo simplemente había que reiniciar el servicio y listo. Algo rápido y sencillo para quienes están acostumbrados a entrar a su servidor por SSH, hacer un par de cambios con ayuda del Vim, reiniciar y salir como alma que lleva el diablo.

El problema es que parece que en sistemas con muchos usuarios esto es inaceptablemente lento. Así que OpenLDAP 2.3 introdujo un nuevo árbol de información de directorio (DIT) cuya base es `cn=config`.




![Arbol de información de directorio cn=config de OpenLDAP ](https://jmtorres.webs.ull.es/me/wp-content/uploads/2014/03/openldap-dit.png)

Arbol de información de directorio cn=config de OpenLDAP — por [ZYTRAX](http://www.zytrax.com/books/ldap/)



A través de este DIT se controla la configuración del servicio, de tal forma que modificando sus entradas se provocan cambios inmediatos en el comportamiento de OpenLDAP, sin tener que reiniciarlo.

Mi problema es que para 30 usuarios esto no representa una ventaja. Mientras que dejar de lado Vim para usar:
``# ldapsearch -Y EXTERNAL -H ldapi:/// -b &#34;cn=config&#34;``

cuando quiero consultar la configuración y:
``# ldapmodify -Y EXTERNAL -H ldapi:/// -f &lt;file.ldif``

para modificarla — después de haber creado el correspondiente fichero LDIF con los cambios — es más que nada un incordio.

No dudo de las ventajas del nuevo formato, pero no es la primera aplicación que abandona la versatilidad de los ficheros de configuración de texto por algún formato binario — ¿a alguien le suena el [registro de Windows](http://es.wikipedia.org/wiki/Registro_de_windows) o los [archivos de propiedades](http://es.wikipedia.org/wiki/Lista_de_propiedades) de MAC OS X? — introduciendo la necesidad de usar herramientas especiales que, entre otras cosas, dificultan la edición y recuperación en caso de desastre. A fin de cuentas, los diversos formatos de fichero de configuración usados en los sistemas UNIX y Linux serán muy viejos, pero nadie puede negar que también son muy cómodos y robustos.

Además la situación se agrava por el hecho de que de por sí las herramientas que acompañan a OpenLDAP — todas de línea de comandos — no son muy cómodas para buscar o modificar los contenidos del LDAP. Así que tampoco lo son para modificar el DIT de configuración. Y menos cuando uno está inmerso en el típico bucle de prueba y error mientras configura el servicio. Por lo que te ves obligado a instalar alguna otra herramienta, siendo muy pocas las que están diseñadas para ser usadas desde la consola.

En ausencia de una buena herramienta de configuración propia de los chicos de OpenLDAP, al final he optado por crearme un alias para usar Ldapvi para estos menesteres:
``alias ldap-config=&#39;ldapvi -Y EXTERNAL -h ldapi:/// -b &#34;cn=config&#34;``

Aun así me sigo preguntado si hubiera sido tan difícil construir un script — por ejemplo de nombre `update-slapdconf` o similar— que al invocarlo procesara e importara en el DIT de configuración las opciones indicadas en el clásico archivo de configuración en texto plano —como el ahora obsoleto `slapd.conf`—.
