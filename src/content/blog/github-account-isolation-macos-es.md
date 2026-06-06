---
title: "Aislando GitHub Personal y Trabajo en macOS"
description: "Guía paso a paso para lograr un aislamiento total y automatizado de tus cuentas de GitHub (personal y laboral) en macOS, con SSH, Git y gh CLI, endurecido contra ataques de supply chain."
pubDate: 2026-06-06T00:00:00-03:00
tags: ["Security", "Git", "GitHub", "macOS", "DevOps"]
lang: es
postSlug: github-account-isolation-macos
---

Cuando usás la misma máquina para tus proyectos personales y para el trabajo, es cuestión de tiempo terminar mezclando identidades: un commit firmado con el correo equivocado, un push a la organización corporativa desde tu cuenta personal o, en el peor de los casos, una credencial expuesta donde no debía estar.

Tras sufrir un incidente de seguridad de **supply chain** en mi entorno laboral, decidí reconstruir mi configuración desde cero. Esta es la guía paso a paso para lograr un **aislamiento total y automatizado** de Git y GitHub CLI (`gh`) apoyándome en una premisa simple: separar físicamente los entornos por carpetas y dejar que las herramientas resuelvan la identidad correcta de forma invisible.

> "La comodidad de una configuración global es exactamente la misma puerta que usa un atacante para moverse lateralmente entre tus cuentas."

El objetivo no es solo evitar errores tontos, sino reducir la superficie de ataque: que un proceso malicioso ejecutado en tu carpeta personal **no tenga forma** de tocar tus repositorios de trabajo, y viceversa.

## Manual o Automatizado: Elegí tu Camino

Esta guía te lleva paso a paso por cada archivo, comando y decisión, para que entendás **exactamente** qué está pasando en tu máquina. Si preferís ver la mecánica antes de confiarle nada a un script, seguí leyendo.

Si ya sabés cómo funciona la cadena o simplemente querés un setup rápido, hay una alternativa: un script interactivo que hace exactamente lo mismo que describo a continuación. Te pregunta emails y carpetas, detecta configuraciones previas, ofrece resetearlas con backup automático, y ejecuta cada paso sin que vos tengas que copiar y pegar comandos.

```bash
curl -sSL https://raw.githubusercontent.com/galiprandi/me/main/scripts/setup-github-isolation.sh | bash
```

> ⚠️  Por seguridad, revisá el contenido antes de ejecutarlo: `curl -sSL ... | cat`.

La guía a mano sigue siendo la mejor forma de interiorizar el mecanismo; el script es la mejor forma de no olvidar ningún paso cuando cambiás de máquina. Elegí la que prefieras.

## 1. Estructura de Carpetas

El pilar de esta configuración es separar físicamente tus repositorios. Toda la automatización posterior (Git, SSH, `gh`) se apoya en *dónde* está parado el repositorio. Creá dos directorios limpios en tu Home:

```bash
mkdir -p ~/Repos/Personal
mkdir -p ~/Repos/Work
```

A partir de ahora la regla es inquebrantable: lo personal vive bajo `~/Repos/Personal`, lo laboral bajo `~/Repos/Work`. La frontera entre ambos mundos es esa ruta.

## 2. Generación de Llaves SSH Seguras

No dependas de tokens HTTPS globales expuestos en variables de entorno. Vamos a usar llaves **SSH ED25519 protegidas por contraseña**, una por identidad. Generá ambas asignando una *passphrase* fuerte cuando te la pida:

```bash
# Llave Personal
ssh-keygen -t ed25519 -C "personal@mail.com" -f ~/.ssh/id_ed25519_personal

# Llave de Trabajo
ssh-keygen -t ed25519 -C "work@mail.com" -f ~/.ssh/id_ed25519_work
```

Agregá las llaves al agente SSH de tu Mac (con integración al Keychain para no reescribir la passphrase en cada sesión):

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
```

Finalmente, copiá el contenido de cada archivo `.pub` y cargalo en la cuenta de GitHub correspondiente (*Settings → SSH and GPG keys*):

```bash
pbcopy < ~/.ssh/id_ed25519_personal.pub   # pegá en tu cuenta personal
pbcopy < ~/.ssh/id_ed25519_work.pub       # pegá en tu cuenta de trabajo
```

## 3. Enrutamiento automático en SSH (`~/.ssh/config`)

Ambas cuentas viven en el mismo host (`github.com`), así que necesitamos un **alias** que le diga a SSH qué llave usar para cada identidad. La cuenta personal se queda con el host real; la de trabajo recibe un alias `github.com-work`. Editá o creá `~/.ssh/config`:

```ssh-config
# Cuenta Personal
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
    AddKeysToAgent yes

# Cuenta de Trabajo
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    AddKeysToAgent yes
```

La directiva `IdentitiesOnly yes` es clave para la seguridad: obliga a SSH a usar **exclusivamente** la llave declarada y le prohíbe ofrecer todas las identidades del agente al servidor. Sin ella, SSH podría autenticarte con la llave equivocada y romper el aislamiento.

## 4. Configuración Inteligente de Git (`~/.gitconfig`)

En lugar de definir un email global (la fuente número uno de commits firmados con la identidad incorrecta), usaremos la directiva `includeIf` para que Git aplique la identidad correcta **según la carpeta donde estés parado**.

**Configuración Global** (`~/.gitconfig`):

```ini
[user]
    name = Tu Nombre

[pull]
    rebase = true

# Aplicar config según el directorio
[includeIf "gitdir:~/Repos/Personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/Repos/Work/"]
    path = ~/.gitconfig-work
```

**Configuración Personal** (`~/.gitconfig-personal`):

```ini
[user]
    email = personal@mail.com
```

**Configuración de Trabajo** (`~/.gitconfig-work`):

```ini
[user]
    email = work@mail.com

# Intercepta clones estándar de la empresa y usa el alias SSH correcto
[url "git@github.com-work:"]
    insteadOf = "git@github.com:"
```

**Buenas prácticas:** la regla `insteadOf` automatiza todo lo demás. Cuando estés dentro de `~/Repos/Work/`, podés correr `git clone git@github.com:organizacion/repo.git` y Git reescribirá la URL para usar el alias `github.com-work`, eligiendo la llave de trabajo de forma invisible. Nunca más vas a tener que recordar qué host usar.

Para verificar que la identidad se resuelve bien, parate en cada carpeta y preguntale a Git:

```bash
cd ~/Repos/Work/algun-repo && git config user.email   # work@mail.com
cd ~/Repos/Personal/otro-repo && git config user.email # personal@mail.com
```

## 5. Separación Completa de GitHub CLI (`gh`)

El CLI de GitHub guarda las credenciales de forma **global** en `~/.config/gh`, lo que rompe el aislamiento apenas lo usás en ambos mundos. La solución es darle a `gh` un directorio de configuración distinto por entorno mediante la variable `GH_CONFIG_DIR`, y automatizar el cambio con [`direnv`](https://direnv.net/).

**1. Crear carpetas de configuración separadas:**

```bash
mkdir -p ~/.config/gh-personal
mkdir -p ~/.config/gh-work
```

**2. Autenticar cada entorno de forma aislada** (elegí SSH como protocolo en ambos casos):

```bash
# Autenticar Personal
export GH_CONFIG_DIR=~/.config/gh-personal
gh auth login

# Autenticar Trabajo
export GH_CONFIG_DIR=~/.config/gh-work
gh auth login
```

**3. Instalar y activar `direnv`:**

```bash
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

**4. Automatizar el cambio de entorno** con un archivo `.envrc` por carpeta:

```bash
# Para la carpeta Personal
echo 'export GH_CONFIG_DIR=~/.config/gh-personal' > ~/Repos/Personal/.envrc
direnv allow ~/Repos/Personal/.envrc

# Para la carpeta de Trabajo
echo 'export GH_CONFIG_DIR=~/.config/gh-work' > ~/Repos/Work/.envrc
direnv allow ~/Repos/Work/.envrc
```

A partir de acá, cada vez que tu terminal entre a una de esas carpetas, `direnv` exportará automáticamente el `GH_CONFIG_DIR` correcto y `gh` operará con la cuenta indicada. Comprobalo con `gh auth status` parado en cada carpeta.

## 6. Manejo Seguro de Credenciales (Anti-Supply Chain)

Esta es la sección que de verdad importa después de un incidente. Los ataques modernos de **supply chain** no buscan tu contraseña: buscan **exfiltrar variables de entorno y tokens en texto plano** que cualquier dependencia maliciosa pueda leer durante un `npm install`, un `postinstall` o un script de build. La regla de oro es simple: **ninguna credencial debe vivir nunca en texto plano dentro de una variable de entorno o de un archivo legible.**

### 6.1. Nunca uses un `GITHUB_TOKEN` global

El antipatrón más peligroso es definir un helper en tu `.gitconfig` que lea un token desde una variable global, por ejemplo:

```ini
# ❌ NO HAGAS ESTO
[credential]
    helper = "!f() { echo \"password=${GITHUB_TOKEN}\"; }; f"
```

Si tenés esto, cualquier proceso que corra en tu sesión (incluida una dependencia comprometida) puede leer `$GITHUB_TOKEN` con un simple `echo $GITHUB_TOKEN` y robarse tu acceso a **todos** tus repositorios. Eliminá cualquier `export GITHUB_TOKEN=...` de tu `.zshrc`, `.bashrc` o `.env` y revocá los Personal Access Tokens que ya no necesites desde *Settings → Developer settings → Tokens*.

### 6.2. Delegá la autenticación HTTPS al `gh` CLI

Para los casos en que necesités HTTPS (algunos pipelines o repos que no soportan SSH), no inventes tu propio helper: delegá en el credential helper nativo de `gh`. Este lee el token desde el almacenamiento seguro de cada `GH_CONFIG_DIR` y **nunca lo expone como variable de entorno**. Agregá este bloque a tus configs por entorno.

En `~/.gitconfig-personal` y `~/.gitconfig-work` añadí:

```ini
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
```

> La primera línea `helper =` (vacía) es intencional: resetea cualquier helper heredado de la configuración global antes de declarar el de `gh`, evitando que un helper inseguro definido más arriba siga activo.

La magia del aislamiento se mantiene: como `direnv` ya cambió el `GH_CONFIG_DIR` según la carpeta, `gh auth git-credential` entregará el token de la cuenta personal en `~/Repos/Personal` y el de trabajo en `~/Repos/Work`, sin que vos toques nada y sin que el secreto pase jamás por una variable de entorno.

### 6.3. Confirmá dónde viven realmente tus tokens

En macOS, `gh` puede almacenar el token en el archivo `hosts.yml` dentro de su `GH_CONFIG_DIR`. Endurecé los permisos para que solo tu usuario pueda leerlos y auditá su contenido:

```bash
chmod 600 ~/.config/gh-personal/hosts.yml ~/.config/gh-work/hosts.yml
# Verificá qué cuenta y scopes tiene cada entorno
GH_CONFIG_DIR=~/.config/gh-work gh auth status
```

Si querés un blindaje extra, podés usar `gh auth login` con `--with-token` leyendo desde un gestor de secretos (como el Keychain de macOS o `1Password CLI`) en lugar de dejar el token en disco, de modo que ni siquiera `hosts.yml` lo contenga de forma persistente.

### 6.4. Protegé tus llaves SSH con passphrase

Las llaves SSH del paso 2 son tu última línea de defensa. Una llave privada sin passphrase es un archivo que cualquier malware puede copiar y reutilizar en otra máquina. Con una *passphrase* fuerte, aunque te roben el archivo `id_ed25519_work`, no podrán usarlo sin descifrarlo.

El agente SSH con integración al Keychain (paso 2) te da lo mejor de ambos mundos: trabajás cómodo sin reescribir la frase, pero la llave **nunca queda utilizable en frío** sobre el disco. Para confirmar que el agente solo tiene cargadas las llaves esperadas:

```bash
ssh-add -l   # debería listar únicamente tus dos llaves ed25519
```

### 6.5. Resumen de las reglas estrictas

- **No uses tokens globales:** evitá `GITHUB_TOKEN` exportado y helpers que lean variables en texto plano.
- **Delegá en herramientas nativas:** `gh auth git-credential` resuelve HTTPS de forma segura y cambia de contexto según la carpeta gracias a `direnv`.
- **Usá passphrases:** ninguna llave SSH debe quedar utilizable sin descifrar sobre el disco.
- **Auditá permisos:** `chmod 600` sobre archivos sensibles y `ssh-add -l` / `gh auth status` como chequeo periódico.

## Cierre: el aislamiento como hábito, no como evento

Reconstruir esta configuración después de un incidente me dejó una certeza: la seguridad no es un setup que hacés una vez, sino una **frontera que las herramientas defienden por vos**. Separás por carpetas, dejás que `includeIf`, `insteadOf` y `direnv` resuelvan la identidad, y eliminás cada lugar donde un secreto pudiera vivir en texto plano.

El resultado es un entorno donde es prácticamente imposible cometer el error de mezclar identidades, y donde una dependencia comprometida en tu mundo personal no tiene ningún camino hacia tus repositorios de trabajo. Esa es la verdadera comodidad: no la de un token global a mano, sino la de saber que el aislamiento trabaja solo, en silencio, cada vez que cambiás de carpeta.
