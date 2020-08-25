---
title: "Dejando la terminal fina con YADR: ZSH, Prezto, Solarize…"
author: "Jesús Torres"
date: 2015-09-21T11:00:01.000Z

description: ""

subtitle: ""

image: "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/5.png" 
images:
 - "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/1.png" 
 - "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/2.png" 
 - "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/3.png" 
 - "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/4.png" 
 - "/posts/2015-09-21_dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize/images/5.png" 


aliases:
    - "/dejando-la-terminal-fina-con-yadr-zsh-prezto-solarize-284466f7601c"
---

Aprovechando que toca reinstalar el ordenador --- gracias a todo el tiempo que ha estado abandonada la [LMDE](http://www.linuxmint.com/download_lmde.php) --- me he animado a personalizar la terminal que utilizo.

Obviamente pienso seguir usando mi fiel compañero [Yakuake](https://es.wikipedia.org/wiki/Yakuake) --- hay que ver lo que se farda en tutorías al mostrar como se despliega tu terminal al toque de F12 --- pero me apetece meterme seriamente con [Zsh](http://www.zsh.org/), así como elegir un esquema de color y fuentes adecuadas para trabajar en la terminal.

## Zsh

[Zsh](http://www.zsh.org/) es una [shell](https://en.wikipedia.org/wiki/Unix_shell) que puede ser entendida como una extensión de una Bourne Shell (sh) en la que se han incorporado no sólo elementos propios sino también características de [bash](https://es.wikipedia.org/wiki/Bash), [ksh](https://es.wikipedia.org/wiki/Ksh) y [tcsh](https://es.wikipedia.org/wiki/Tcsh).
Aunque muchos usuarios de [bash](https://es.wikipedia.org/wiki/Bash) nos sentimos cómodos con esta shell, lo cierto es que no tienen un origen común.
El desarrollador de [Zsh](http://www.zsh.org/), Paul Faldstad, buscaba crear una shell similar a [ksh](https://es.wikipedia.org/wiki/Ksh) donde incorporar algunas funcionalidades de [csh](https://es.wikipedia.org/wiki/C_Shell)/[tcsh](https://es.wikipedia.org/wiki/Tcsh).
Por el contrario [bash](https://es.wikipedia.org/wiki/Bash) no intenta emular a [ksh](https://es.wikipedia.org/wiki/Ksh) pero sí cumplir con lo que dicen estándares como POSIX.
En todo caso tanto [Zsh](http://www.zsh.org/) como [bash](https://es.wikipedia.org/wiki/Bash) son proyectos vivos, por lo que en estos años se han ido intercambiado algunas funcionalidades, de ahí que en algunos aspectos se note cierto parecido.

Toda _shell_ UNIX tiene la doble función de servir tanto de intérprete de órdenes como de lenguaje de scripts con el que automatizar ciertas tareas.
Lo que hace tan interesante a [Zsh](http://www.zsh.org/) es que sus desarrolladores han hecho mucho hincapié en lo primero, incorporando fundamentalmente características para potenciar el uso interactivo de la misma:

*   Soporte para temas, con facilidades para mostrar información adicional en la línea de comandos.
*   Autocompletado programable de comandos.
*   Corrección ortográfica.
*   Historial compartido entre _shells_.
*   Comodines extendidos que permiten especificaciones de archivos complejas, sin tener que ejecutar programas externos como `find`.
*   Edición de comandos multilínea.
*   Módulos cargables con funcionalidades adicionales.
*   Completamente personalizable.

Supongo que en cierta medida es la flexibilidad a la hora de personalizar visualmente y de añadir nuevas funcionalidades lo que está causando tanto furor entre los usuarios.
Y no hablo sólo de usuarios de Linux.
La mayor parte de los tutoriales que he encontrado explicando algún detalle de lo que pretendía hacer eran para Mac OS X e iTerm2.




{{< figure src="https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/cobalt2-para-iterm2-y-zsh-1024x668.png" caption="Tema Cobalt2 para iTerm2 y Zsh en Mac OS X." >}}


## Prezto

El problema es que [Zsh](http://www.zsh.org/) tiene muchas posibilidades pero prácticamente no trae nada de serie.
Cuando lo iniciamos por primera vez nos pregunta si queremos crear los ficheros de configuración necesarios.
Después de eso nos quedamos en lo que parece una _shell_ corriente y moliente.
Así que ¿dónde están esos coloridos temas para la línea de comandos? ¿y los módulos que facilitan la integración con Git, Ruby o Python?

[Zsh](http://www.zsh.org/) pone la estructura necesaria para hacer cosas muy interesantes pero no trae lo mínimo.
Por fortuna existe una importante comunidad dedicada a crear módulos y temas para esta _shell_, en su mayor parte alrededor de proyectos como [Oh My Zsh](http://ohmyz.sh/) y [Prezto](https://github.com/sorin-ionescu/prezto).
Básicamente ambos proveen un framework diseñado para facilitar la gestión de la configuración de [Zsh](http://www.zsh.org/).
Dentro del marco de dichos frameworks, la comunidad se afana en crear nuevos temas y módulos.

A la hora de elegir uno u otro hay que tener en cuenta que [Oh My Zsh](http://ohmyz.sh/) tiene una comunidad inmensa, por lo que prácticamente ofrece todo lo que podríamos necesitar.
Sin embargo algunos usuarios se quejan de que enlentece demasiado la carga de la _shell_.
Precisamente por eso existe [Prezto](https://github.com/sorin-ionescu/prezto), un fork de [Oh My Zsh](http://ohmyz.sh/) que ha sido reescrito usando exclusivamente sintaxis de [Zsh](http://www.zsh.org/) con el objeto de ofrecer una solución más limpia y rápida.




![Tema Powerline para Prezto.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/prezto_powerline.png)

Tema Powerline para Prezto.



## Dotfiles

Vim, Git o Zsh, entre muchos otros, son los programas que solemos usar en la terminal.
Para que la experiencia de largas horas de trabajo sea satisfactoria es conveniente haberlos configurado según nuestras preferencias.
Para preservar estas configuraciones --- lo que, al menos la primera vez, pueden llevar varias horas --- controlar las versiones, compartirlas de forma sencilla entre los distintos equipos que utilizamos y --- ¿por qué no? --- ponerlas a disposición del resto de la comunidad, es muy común subirlas a [GitHub](https://github.com/).

Si no me crees solo tienes que visitar dicha web y buscar repositorios de nombre `dotfiles`.
Verás la cantidad ingente de usuarios que están compartiendo sus archivos de configuración, lo que es de agradecer si no tiene mucho tiempo para configurar los programas por ti mismo.

De entre todos esos repositorios yo voy a destacar [YADR](http://skwp.github.io/dotfiles), una completa solución que trae configuraciones para:

*   [Zsh](http://www.zsh.org/) usando [Prezto](https://github.com/sorin-ionescu/prezto).
*   Git y GitHub.
*   Diversos comandos para facilitar la gestión de los alias.
Por ejemplo el comando `ae` que permite editar todos los alias de forma sencilla.
*   Ruby Gem.
*   Tmux.
*   Vim y vimificación de otras utilidades de línea de comandos.
Por ejemplo `mysql` o `irb`.

En general el proyecto está muy orientado a Ruby y Mac OS X, por lo que también incluye temas de color para [iTerm2](https://www.iterm2.com/) e intenta instalar algunos paquetes con [Homebrew](http://brew.sh/).
En cualquier caso yo no me he encontrado muchos problemas al intentar utlizar [YADR](http://skwp.github.io/dotfiles) en Linux.

## Solarized

Una de las cosas que trae [YADR](http://skwp.github.io/dotfiles) es un tema de colores para [iTerm2](https://www.iterm2.com/) basado en [Solarized](http://ethanschoonover.com/solarized).
En parte porque dicho esquema de colores para la terminal es muy recomendado por algunos temas para [Zsh](http://www.zsh.org/).

[Solarized](http://ethanschoonover.com/solarized) es una paleta de 16 colores diseñada para ser utilizada en aplicaciones, tanto gráficas como en la terminal.
Su autor afirma que tiene propiedades únicas y que ha sido probada ampliamente en el mundo real, tanto en monitores calibrados como no calibrados y en distintas condiciones de iluminación.




![Solarized Yin Yang.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/solarized-yinyang.png)

Solarized Yin Yang.



El proyecto [Solarized](http://ethanschoonover.com/solarized) ofrece esquemas de color y temas en los formatos requeridos por una amplia variedad de aplicaciones.
Por ejemplo Mutt, Qt Creator, IntelliJ IDEA, Gedit, Netbeans, Emacs.
Texmate, Putty y muchas más.
Aunque parece que no ofrecen esquemas para ninguna aplicación de KDE, esto no es un problema porque ya vienen de serie con Konsole los esquemas de color [Solarized](http://ethanschoonover.com/solarized) Light y Dark.

## Instalación de YADR

El instalador de YADR utiliza Rake y Git --- al analizar el proyecto con algo más de profundidad es fácil darse cuenta de que el autor tiene cierta predilección por Ruby --- y también necesitamos un Vim con soporte para Lua, ya que algunos complementos instalados lo necesitan.
Así que eso será lo primero que haremos:
``# sudo apt-get install rake git vim-nox``

Después descargamos el instalador propiamente dicho para ejecutarlo.
Por ejemplo así:
``# wget [https://raw.githubusercontent.com/skwp/dotfiles/master/](https://raw.githubusercontent.com/skwp/dotfiles/master/%5C%5C)\  
install.sh  
chmod +x install.sh  
./install.sh``

Se puede ejecutar `install.sh -s ask` si queremos que el instalador nos pregunte sobre cada uno de los componentes que puede instalar.
Sin embargo, aunque no soy desarrollador de Ruby y se que muchas de esos componentes no los voy a aprovechar, no me pareció buena idea hacerlo así.
En mi opinión es un una pérdida de tiempo porque son muchísimos componentes, nunca se sabe si al final los acabarás necesitando y, en todo caso, apenas ocupan espacio.

Al final del proceso de instalación es normal que pida la contraseña del usuario actual para activar [Zsh](http://www.zsh.org/) como tu _shell_ por defecto.
Si el instalador no lo hace, siempre lo podemos hacer nosotros mismos a mano:
``# chsh -s /bin/zsh``

Obviamente este cambio surtirá efecto en el siguiente inicio de sesión.

## Configuración del entorno

Como he comentado, [YADR](http://skwp.github.io/dotfiles) trae [Prezto](https://github.com/sorin-ionescu/prezto).
Así que antes de seguir vamos a ver como debemos gestionar a partir de ahora la configuración de [Zsh](http://www.zsh.org/).

### Zsh

Estos son los archivos de configuración utilizados por cualquier instalación de [Zsh](http://www.zsh.org/):

*   `~/.zlogin
`Su contenido sólo se incluye en _shell_s _de login_ ---siempre después del de `.zshrc`--- por lo que debemos incluir aquí cosas que queremos que se ejecuten sólo cuando nos autenticamos.
*   `~/.zlogout`
 Su contenido sólo se incluye cuando una _shell de login_ termina y, por tanto, vamos a abandonar la sesión actual.
*   `~/.zprofile`
Es similar a `.zlogin` ---sólo se incluye en shells _de login_--- pero se incluye siempre antes que el contenido de `.zshrc`.
*   `~/.zshrc`
Se usa para la configuración de _shell_ interactivas.
Por lo tanto aquí es donde se deben cargar módulos, activar o desactivar las distintas opciones interactivas de [Zsh](http://www.zsh.org/), configurar el historial, cambiar el aspecto visual de la línea de comandos, configurar el autocompletado, etc.
*   `~/.zshenv`
 Siempre es incluido y debe contener las variables de entorno que debe estar disponibles para todos los programas.
Por ejemplo `$PATH`, `$EDITOR`, o `$PAGER`, entre muchas otras.

[Prezto](https://github.com/sorin-ionescu/prezto) toma el control de esos archivos poniendo sus propias versiones para, por ejemplo, ejecutarse a través de `.zshrc` en cualquier _shell_ interactiva que iniciemos ---si hemos instalado [Prezto](https://github.com/sorin-ionescu/prezto) sin la ayuda de [YADR](http://skwp.github.io/dotfiles) y queremos modificar algunos de los archivos anteriores, el desarrollador del proyecto nos anima a hacerle un _fork_ en GitHub y usar nuestro nuevo repositorio para subir los cambios que hagamos a los archivos de configuración, evitando que podamos perderlos---.

## Prezto

[Prezto](https://github.com/sorin-ionescu/prezto) introduce un nuevo archivo de configuración específico para sus opciones de configuración:

*   `~/.zpreztorc
`Se usa para indicar las opciones específicas de [Prezto](https://github.com/sorin-ionescu/prezto).
Por ejemplo los módulos que queremos utilizar ---el listado completo de módulos se puede visitar en la [web del proyecto en GitHub](https://github.com/sorin-ionescu/prezto/tree/master/modules)--- o el tema de la línea de comandos o _prompt_ que más nos gusta.
Sin embargo no utilizaremos `.zpreztorc` para esto último, sino que lo haremos de la manera propuesta por [YADR](http://skwp.github.io/dotfiles).

En mi caso me gusta editar el archivo `.zpreztorc` para activar el módulo `python` y desactivar `ruby` y `osx`.
Así que la configuración, en parte, debe quedar tal que así:
``# Set the Prezto modules to load (browse modules).  
# The order matters.  
zstyle ':prezto:load' pmodule \  
  'environment' \  
  'terminal' \  
  'editor' \  
  'history' \  
  'directory' \  
  'spectrum' \  
  'utility' \  
  'completion' \  
  'archive' \  
  'fasd' \  
  'git' \  
  'python' \  
  'syntax-highlighting' \  
  'history-substring-search' \  
  'ssh' \  
  'prompt'``

Como se puede observar, también he dejado activado el módulo `ssh`, que es muy cómodo porque, a parte de incorporar algunos alias, cargar nuestras identidades SSH en [ssh-agent](https://es.wikipedia.org/wiki/SSH-Agent).
Si nos molesta que nos pida la contraseñas que protegen nuestras identidades la primera vez que abrimos una terminal podemos:

*   Quitarles la contraseña, lo que es muy poco recomendable por motivos de seguridad.
*   Desactivar el módulo `ssh`, que es lo mejor si no se entiende que problema resuelve.
*   Instalar `libpam-ssh` y asegurarnos de que la contraseña de dichas identidades es la misma que la de nuestro sistema.
`libpam-ssh` permite que se use la contraseña de nuestra cuenta en el sistema para descifrar automáticamente las identidades SSH y cargarlas en [ssh-agent](https://es.wikipedia.org/wiki/SSH-Agent).

Si optamos por esta última opción sólo tendremos que ejecutar:
``# sudo apt-get install libpam-ssh  
sudo pam-auth-update``

asegurándonos de que en la _Configuración de PAM_ está marcado _Authenticate using SSH keys and start ssh-agent_.




{{< figure src="https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/pam-auth-update.png" caption="Diálogo de configuración de PAM." >}}


### YADR

Finalmente [YADR](http://skwp.github.io/dotfiles) ofrece una serie de ubicaciones adicionales pensadas para evitar en lo posible que toquemos los archivos de configuración anteriores:


{{< highlight >}}
~/.zsh.before
{{< / highlight >}}  
 Es un directorio donde podemos colocar archivos para personalizar cosas antes de que se apliquen las configuraciones incluidas en [YADR](http://skwp.github.io/dotfiles).
Nos sirve para indicar qué módulos se cargan y cuáles no porque eso ocurre mucho antes, cuando [Prezto](https://github.com/sorin-ionescu/prezto) se inicia desde `.zshrc` y lee `.zpreztorc`.
Por eso siempre tenemos que configurar los módulos en ese archivo.
 
 `~/.zsh.after`  
 Es un directorio donde podemos colocar archivos para personalizar cosas después de que se apliquen las configuraciones incluidas en [YADR](http://skwp.github.io/dotfiles).  
 `~/.zsh.prompts`  
 Es un directorio donde podemos colocar archivos con nuestros propios temas de línea de comandos.

Algo similar hace [YADR](http://skwp.github.io/dotfiles) con los otros programas que personaliza.
Por ejemplo toma el control de `~/.gitconfig`, por lo que se recomienda que las personalizaciones de Git ---como las credenciales de usuario--- se incluyan en `~/.gitconfig.user`.
O las personalizaciones de vim, que deben indicarse en los archivos `~/.vimrc.before` o `~/vimrc.after`.

El comando `prompt` nos permite obtener una lista de los temas de línea de comandos actualmente disponibles:
``# prompt -l  
Currently available prompt themes:  
agnoster cloud damoekri giddie kylewest minimal nicoulaj paradox peepcode powerline pure skwp smiley sorin steeef adam1 adam2 bart bigfade clint elite2 elite fade fire off oliver pws redhat suse walters zefram steeef_simplified``

Podemos tener una vista previa de alguno que nos interese:
``# prompt -p agnoster``

Podemos activarlo para la sesión actual:
``# prompt agnoster``

O configurarlo como tema por defecto de futuras sesiones:
``# echo 'prompt agnoster' > ~/.zsh.after/prompt.zsh``

En mi caso particular utilizo [una versión del tema _agnoster_](https://github.com/aplatanado/agnoster-zsh-theme) que utiliza el módulo `python` de Presto para mostrar el nombre del entorno virtual de Python activo en cada momento.
Para usarlo sólo hay que descargar el archivo `agnoster.zsh-theme` del tema en `~/.zsh.prompts/prompt_agnoster-aplatanado_setup` y activarlo tal y como he comentado anteriormente:
``# echo 'prompt agnoster-aplatanado' > ~/.zsh.after/prompt.zsh``



![Resultado final de YADR en Yakuake con el esquema de color Solarized Dark.](https://jmtorres.webs.ull.es/me/wp-content/uploads/2015/08/agnoster-aplatanado.png)

Resultado final en la terminar Yakuake con el esquema de color Solarized Dark.



### Fuentes y colores

Muchos temas usan caracteres especiales que requieren de una fuente parcheada con [powerline](https://github.com/powerline/fonts).
Por fortuna [YADR](http://skwp.github.io/dotfiles) ya las incorpora, así que sólo tenemos que escoger una de dichas fuentes como fuente monoespaciada por defecto del sistema.
Por ejemplo en KDE podemos ir a _Preferencias del sistema > Tipos de letra > Anchura fija_ y escoger _Menlo for Powerline_.

Como he comentado, algunos temas recomiendan [Solarized](http://ethanschoonover.com/solarized) como esquema de color de la terminal.
Así lo hago yo y suelo escoger la versión oscura.
Además también aprovecho para ajustar otras herramientas con las que trabajo con cierta frecuencia, como [Qt Creator](https://github.com/artm/qtcreator-solarized-syntax/) o [IntelliJ IDEA](https://github.com/jkaving/intellij-colors-solarized).
En el primer IDE uso la versión oscura y en el segundo la versión clara --- puesto que no he terminado de sentirme cómodo con la oscura --- y fuente Menlo para que todo mi entorno de trabajo tenga más o menos el mismo estilo.

Finalmente, aunque todo parezca estar bien lo cierto es que algunas personalizaciones requieren que la terminal informe adecuadamente de sus capacidades.
En concreto Konsole y Yakuake informan ser de tipo `xterm` cuando para que todo funcione correctamente debería ser `xterm-256color`.
Esto hace que, por ejemplo, no funcione correctamente el marcado del modo visual de Vim.
Esto se puede cambiar, tanto en Konsole como en Yakuake, yendo a _Gestionar perfiles > Editar perfil: Intérprete de órdenes... > Entorno: Editar..._ e indicar:
``TERM=xterm-256color``

Y ya tenemos nuestra terminal en perfecto, completo y precioso funcionamiento.
Ahora a usarla y mucho cuidado con acabar rompiendo algo ;)
