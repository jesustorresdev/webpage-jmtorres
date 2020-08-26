# webpages-jmtorres

Mi sitio web personal, hecho con Hugo y el tema Loveit.<br />

Copyright 2020 Jesús Torres \<jmtorres@ull.es\><br />
Esta obra está bajo [Licencia Creative Commons Reconocimiento 4.0 Internacional](http://creativecommons.org/licenses/by/4.0/) excepto en aquellos contenidos dónde se indique lo contrario.

## Tema

El tema escogido es [LoveIt](https://hugoloveit.com/).
Su configuración, opciones y características soportadas están documentadas [aquí](https://hugoloveit.com/categories/)

## Server

El tema LoveIt usa `.Scratch` para implementar algunas características, por lo que se recomienda añadir `--disableFastRender` a  `hugo server` durante la previsualización:

```.bash
$ ./hugo server --disableFastRender
```

## Estilos

_Markdown_ soporta algunos estilos básicos pero no permite etiquetar semánticamente los elementos del contenido, para aplicar posteriormente los estilos adecuados.
Esto hace que sea difícil mantener un estilo consistente a lo largo del tiempo en diferentes artículos. 
Por eso es conveniente establecer unas reglas sobre los estilos a aplicar en cada caso y usarlas de forma consistente en todos los artículos de la web.

 * \_Aplicación\_.
 * \*\*Elemento de la GUI\*\*: \*\*Etiqueta\*\* \*\*Menú\*\* \*\*Submenú\*\* \*\*Botón\*\* \*\*Icono\*\* \*\*Ventana\*\* \*\*Interfaz\*\*.
 Para facilitar la aplicación de este estilo, está disponible el _shortcode_ `{{< gui "Elemento/Subelemento/..." >}}`.
 * \`nombre_de_archivo\`, \`ruta\`, \`VARIABLE_DE_ENTORNO\`, \`comando\` o \`--argumento\`.
 * Entrada de teclado: `{{< kbd "Tecla1+Tecla2+..." >}}`.

Algunas de estas reglas están basadas en:

 * [GNOME Handbook of Writing Software Documentation — 4. DocBook Basics](https://developer.gnome.org/gdp-handbook/stable/docbook.html.en).

### Coloreado de sintaxis

En lo posible se debe hacer uso del coloreado de sintaxis con el _shortcode_ highlight.
Algunas reglas a tener en cuenta:

 * Si un archivo es pequeño y no se encuentra un estilo adecuado de coloreado de sintaxis, se puede valorar optar por usar simplemente _code fences_ (\`\`\`).

 * Para comandos ejecutados en la terminar, que además suelen tener unas pocas líneas, es mejor optar por _code fences_.
 Además es importante recordar utilizar los indicadores de _prompt_: '\#' (_root_), '\$' (usuario) y '>' (en Windows); para señalar que se entrada de comandos en una terminal interactiva.
 