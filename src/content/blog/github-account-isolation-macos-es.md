---
title: "Aislamiento Multicuenta de GitHub en macOS y Linux"
description: "Guía definitiva para aislar N cuentas de GitHub en una misma máquina: SSH, Git con firma de commits (SSH + GPG), gh CLI separado por carpeta y endurecimiento contra supply chain. Cross-platform macOS y Linux."
pubDate: 2026-06-06T00:00:00-03:00
updatedDate: 2026-07-20T00:00:00-03:00
tags: ["Security", "Git", "GitHub", "macOS", "Linux", "DevOps"]
lang: es
postSlug: github-account-isolation-macos
---

> **Actualización 2026-07-20:** guía reescrita para soportar N cuentas (no solo 2), firma de commits con SSH y GPG, `allowed_signers` para verificación, cuenta principal como default seguro, soporte cross-platform (macOS y Linux), y corrección de la sección de credenciales (el token vive en Keychain/secret-service, no en disco).

Cuando usás la misma máquina para varios mundos —personal, trabajo, side-projects— es cuestión de tiempo terminar mezclando identidades: un commit firmado con el correo equivocado, un push a la organización corporativa desde tu cuenta personal o, en el peor de los casos, una credencial expuesta donde no debía estar.

Decidí reconstruir mi configuración desde cero. Esta es la guía paso a paso para lograr un **aislamiento total y automatizado** de Git y GitHub CLI (`gh`) apoyándome en una premisa simple: separar físicamente los entornos por carpetas y dejar que las herramientas resuelvan la identidad correcta de forma invisible.

> "La comodidad de una configuración global es exactamente la misma puerta que usa un atacante para moverse lateralmente entre tus cuentas."

El objetivo no es solo evitar errores tontos, sino reducir la superficie de ataque: que un proceso malicioso ejecutado en tu carpeta personal **no tenga forma** de tocar tus repositorios de trabajo, y viceversa.

## Prerrequisitos

Esta guía funciona en **macOS** y **Linux** (Debian/Ubuntu). Necesitás:

| Herramienta | macOS | Linux (Debian/Ubuntu) |
|---|---|---|
| Git | `brew install git` | `sudo apt-get install -y git` |
| GitHub CLI (`gh`) | `brew install gh` | [Instalación oficial](https://github.com/cli/cli#installation) (repo apt) |
| OpenSSH | incluido en macOS | `sudo apt-get install -y openssh-client` |
| GnuPG | `brew install gnupg` | `sudo apt-get install -y gnupg` |
| `direnv` | `brew install direnv` | `sudo apt-get install -y direnv` |
| Clipboard | `pbcopy` (incluido) | `sudo apt-get install -y xclip` |

> En Linux headless (SSH sin GUI), la generación de claves GPG requiere `--batch --passphrase ""` para evitar `pinentry-curses`. El script companion lo hace automáticamente.

## Manual o Automatizado: Elegí tu Camino

Esta guía te lleva paso a paso por cada archivo, comando y decisión, para que entendás **exactamente** qué está pasando en tu máquina. Si preferís ver la mecánica antes de confiarle nada a un script, seguí leyendo.

Si ya sabés cómo funciona la cadena o simplemente querés un setup rápido, hay una alternativa: un script interactivo que hace exactamente lo mismo que describo a continuación. Te pregunta cuántas cuentas querés configurar, emails, carpetas y claves de firma, detecta configuraciones previas, ofrece resetearlas con backup automático, y ejecuta cada paso sin que vos tengas que copiar y pegar comandos.

```bash
curl -sSL https://raw.githubusercontent.com/galiprandi/me/main/scripts/setup-github-isolation.sh | bash
```

> ⚠️  Por seguridad, revisá el contenido antes de ejecutarlo: `curl -sSL ... | cat`.

La guía a mano sigue siendo la mejor forma de interiorizar el mecanismo; el script es la mejor forma de no olvidar ningún paso cuando cambiás de máquina. Elegí la que prefieras.

## Convención de ejemplo: 3 cuentas

Para que la guía sea concreta sin atarse a un caso particular, vamos a usar **3 cuentas** como ejemplo a lo largo de todo el recorrido:

| Cuenta | Email | Carpeta | Host SSH | GH_CONFIG_DIR |
|---|---|---|---|---|
| **Work** (principal) | `work@mail.com` | `~/Github/Work` | `github.com` | `~/.config/gh-work` |
| **Personal** | `personal@mail.com` | `~/Github/Personal` | `github.com-personal` | `~/.config/gh-personal` |
| **Side-project** | `side@mail.com` | `~/Github/Side` | `github.com-side` | `~/.config/gh-side` |

La cuenta **principal** (Work) es la que vive como `Host github.com` real y como default global de git y `gh`. Las demás son overrides. Si tu principal es la personal, invertí los roles. El mecanismo es el mismo para 2, 3 o N cuentas: repetí el bloque por cada cuenta adicional.

## 1. Estructura de Carpetas

El pilar de esta configuración es separar físicamente tus repositorios. Toda la automatización posterior (Git, SSH, `gh`) se apoya en *dónde* está parado el repositorio. Creá un directorio limpio por cuenta en tu Home:

```bash
mkdir -p ~/Github/Work
mkdir -p ~/Github/Personal
mkdir -p ~/Github/Side
```

A partir de ahora la regla es inquebrantable: cada cuenta vive bajo su carpeta. La frontera entre los mundos es esa ruta.

## 2. Generación de Llaves SSH Seguras

No dependas de tokens HTTPS globales expuestos en variables de entorno. Vamos a usar llaves **SSH ED25519 protegidas por passphrase**, una por identidad. Generá una por cuenta asignando una *passphrase* fuerte cuando te la pida:

```bash
# Work (principal)
ssh-keygen -t ed25519 -C "work@mail.com" -f ~/.ssh/id_ed25519_work

# Personal
ssh-keygen -t ed25519 -C "personal@mail.com" -f ~/.ssh/id_ed25519_personal

# Side-project
ssh-keygen -t ed25519 -C "side@mail.com" -f ~/.ssh/id_ed25519_side
```

Agregá las llaves al agente SSH (con integración al Keychain en macOS para no reescribir la passphrase en cada sesión):

```bash
# macOS
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_side

# Linux
ssh-add ~/.ssh/id_ed25519_work
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_side
```

Finalmente, copiá el contenido de cada archivo `.pub` y cargalo en la cuenta de GitHub correspondiente (*Settings → SSH and GPG keys*):

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519_work.pub       # pegá en tu cuenta de trabajo
pbcopy < ~/.ssh/id_ed25519_personal.pub   # pegá en tu cuenta personal
pbcopy < ~/.ssh/id_ed25519_side.pub       # pegá en tu cuenta side-project

# Linux (xclip)
xclip -selection clipboard < ~/.ssh/id_ed25519_work.pub
# o: cat ~/.ssh/id_ed25519_work.pub  y copiar manualmente
```

## 3. Enrutamiento automático en SSH (`~/.ssh/config`)

Todas las cuentas viven en el mismo host (`github.com`), así que necesitamos un **alias** que le diga a SSH qué llave usar para cada identidad. La cuenta principal se queda con el host real; las demás reciben aliases. Editá o creá `~/.ssh/config`:

```ssh-config
# Cuenta principal (Work)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
    AddKeysToAgent yes

# Cuenta Personal
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
    AddKeysToAgent yes

# Cuenta Side-project
Host github.com-side
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_side
    IdentitiesOnly yes
    AddKeysToAgent yes
```

La directiva `IdentitiesOnly yes` es clave para la seguridad: obliga a SSH a usar **exclusivamente** la llave declarada y le prohíbe ofrecer todas las identidades del agente al servidor. Sin ella, SSH podría autenticarte con la llave equivocada y romper el aislamiento.

## 4. Configuración Inteligente de Git (`~/.gitconfig`)

A diferencia de guías anteriores que recomendaban un global sin email, acá vamos a definir la **cuenta principal como default seguro**: el global tiene email, firma habilitada y `allowed_signers` configurado. Así, cualquier repo clonado fuera de las carpetas cubiertas commitea con tu identidad principal, firmado, en lugar de quedar sin identidad. Las demás cuentas son overrides vía `includeIf`.

**Configuración Global** (`~/.gitconfig`):

```ini
[user]
    name = Tu Nombre
    email = work@mail.com
    signingkey = 2970AAB9B51D85F3   # tu GPG key ID (ver sección 5)

[commit]
    gpgsign = true

[gpg]
    format = openpgp
    program = gpg

[gpg "ssh"]
    allowedSignersFile = ~/.config/git/allowed_signers

# Overrides por carpeta
[includeIf "gitdir:~/Github/Personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/Github/Side/"]
    path = ~/.gitconfig-side
```

> La cuenta principal (Work) **no necesita `includeIf`**: ya es el default. Solo las cuentas secundarias se declaran como overrides.

**Configuración Personal** (`~/.gitconfig-personal`):

```ini
[user]
    name = Tu Nombre
    email = personal@mail.com
    signingkey = ~/.ssh/id_ed25519_personal.pub

[commit]
    gpgsign = true

[gpg]
    format = ssh

# Intercepta clones estándar y usa el alias SSH correcto
[url "git@github.com-personal:"]
    insteadOf = "git@github.com:"
```

**Configuración Side-project** (`~/.gitconfig-side`):

```ini
[user]
    name = Tu Nombre
    email = side@mail.com
    signingkey = ~/.ssh/id_ed25519_side.pub

[commit]
    gpgsign = true

[gpg]
    format = ssh

[url "git@github.com-side:"]
    insteadOf = "git@github.com:"
```

**Buenas prácticas:** la regla `insteadOf` automatiza todo lo demás. Cuando estés dentro de `~/Github/Personal/`, podés correr `git clone git@github.com:usuario/repo.git` y Git reescribirá la URL para usar el alias `github.com-personal`, eligiendo la llave personal de forma invisible. Nunca más vas a tener que recordar qué host usar.

Para verificar que la identidad se resuelve bien, parate en cada carpeta y preguntale a Git:

```bash
cd ~/Github/Work/algun-repo     && git config user.email   # work@mail.com
cd ~/Github/Personal/otro-repo  && git config user.email   # personal@mail.com
cd ~/Github/Side/otro-repo      && git config user.email   # side@mail.com
cd /tmp                         && git config user.email   # work@mail.com (default)
```

## 5. Firma de Commits (SSH + GPG)

Esta es la sección que diferencia a esta guía de cualquier otra "multi-account GitHub" que vas a encontrar. Firmar commits no es decorativo: es el mecanismo que prueba que un commit vino de quien dice venir. Sin firma, un atacante con acceso al repo puede inyectar commits y no hay forma de distinguirlos de los tuyos. Con firma, `git log --show-signature` te lo dice en segundos.

Git soporta dos formatos de firma: **SSH** (más simple, reusa tus llaves ed25519) y **GPG/OpenPGP** (más tradicional, requiere una clave GPG separada). Podés mezclar: una cuenta con GPG y otras con SSH. En el ejemplo, Work usa GPG y Personal/Side usan SSH.

### 5.1. Firma SSH (recomendado para empezar)

Si ya generaste tus llaves ed25519 en el paso 2, ya tenés todo. Solo necesitás:

1. **Subir la llave pública a GitHub** como *signing key* (no solo como SSH key): *Settings → SSH and GPG keys → New SSH key → Key type: Signing Key*. Subí el mismo `.pub` que cargaste antes, pero marcado como signing.

2. **Declarar la llave en tu perfil git** (ya lo hicimos en la sección 4):
   ```ini
   [user]
       signingkey = ~/.ssh/id_ed25519_personal.pub
   [gpg]
       format = ssh
   ```

3. **Configurar `allowed_signers`** para que git pueda **verificar** firmas SSH (no solo crearlas). Creá `~/.config/git/allowed_signers` con una línea por email:
   ```
   work@mail.com namespaces="git" ssh-ed25519 AAAAC3... work@mail.com
   personal@mail.com namespaces="git" ssh-ed25519 AAAAC3... personal@mail.com
   side@mail.com namespaces="git" ssh-ed25519 AAAAC3... side@mail.com
   ```
   El formato es: `email namespaces="git" <tipo> <clave> <comentario>`. La clave es el contenido del `.pub` correspondiente. Y declaralo en el global:
   ```ini
   [gpg "ssh"]
       allowedSignersFile = ~/.config/git/allowed_signers
   ```

### 5.2. Firma GPG/OpenPGP (para la cuenta principal)

Si querés firma GPG para tu cuenta principal (más tradicional, soportado por más herramientas):

1. **Generar una clave GPG** (si no tenés una):
   ```bash
   # macOS (usa pinentry-mac si está instalado, o prompt nativo)
   gpg --quick-generate-key "work@mail.com" ed25519 sign 0

   # Linux headless (SSH sin GUI): usar --batch para evitar pinentry-curses
   gpg --batch --passphrase "" --quick-generate-key "work@mail.com" ed25519 sign 0
   ```
   Listá tus claves y copiá el ID:
   ```bash
   gpg --list-secret-keys --keyid-format=long
   # sec   ed25519/2970AAB9B51D85F3 ...
   ```
   El ID es la parte después de `/` (ej: `2970AAB9B51D85F3`).

2. **Subir la clave pública a GitHub**: *Settings → SSH and GPG keys → New GPG key*.
   ```bash
   # macOS
   gpg --armor --export 2970AAB9B51D85F3 | pbcopy
   # Linux
   gpg --armor --export 2970AAB9B51D85F3 | xclip -selection clipboard
   ```

3. **Declarar en tu global** (ya lo hicimos en la sección 4):
   ```ini
   [user]
       signingkey = 2970AAB9B51D85F3
   [gpg]
       format = openpgp
       program = gpg
   ```

### 5.3. Verificación

Confirmá que las firmas se crean y se validan correctamente:

```bash
# En un repo personal, hacé un commit y verificá la firma
cd ~/Github/Personal/algun-repo
git commit --allow-empty -m "test firma SSH"
git log --show-signature -1
# Debe decir: Good "git" signature for personal@mail.com
# El status %G? debe ser "G" (good)

# En un repo de trabajo
cd ~/Github/Work/algun-repo
git commit --allow-empty -m "test firma GPG"
git log --show-signature -1
# Debe decir: Good signature from work@mail.com
```

Si el status es `U` (unknown) o `X` (expired), revisá que la clave esté subida a GitHub como signing key y que `allowed_signers` tenga la entrada correcta.

## 6. Separación Completa de GitHub CLI (`gh`)

El CLI de GitHub guarda las credenciales de forma **global** en `~/.config/gh`, lo que rompe el aislamiento apenas lo usás en varios mundos. La solución es darle a `gh` un directorio de configuración distinto por entorno mediante la variable `GH_CONFIG_DIR`, y automatizar el cambio con [`direnv`](https://direnv.net/).

**1. Crear carpetas de configuración separadas:**

```bash
mkdir -p ~/.config/gh-work
mkdir -p ~/.config/gh-personal
mkdir -p ~/.config/gh-side
```

**2. Autenticar cada entorno de forma aislada** (elegí SSH como protocolo en todos los casos):

```bash
# Autenticar Work (principal)
export GH_CONFIG_DIR=~/.config/gh-work
gh auth login

# Autenticar Personal
export GH_CONFIG_DIR=~/.config/gh-personal
gh auth login

# Autenticar Side-project
export GH_CONFIG_DIR=~/.config/gh-side
gh auth login
```

**3. Symlink del default a la cuenta principal:**

Para que `gh` fuera de las carpetas cubiertas use la cuenta principal (consistente con el default de git), creá un symlink:

```bash
ln -sfn gh-work ~/.config/gh
```

Ahora `~/.config/gh` apunta a `gh-work`. Cualquier `gh` ejecutado sin `direnv` usa la cuenta principal. Single source of truth: el token vive una sola vez en el Keychain (macOS) o en el almacén del sistema (Linux via `secret-service`/`pass`).

**4. Instalar y activar `direnv`:**

```bash
# macOS
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# Linux (Debian/Ubuntu)
sudo apt-get install -y direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc  # o zsh si usás zsh
```

**5. Automatizar el cambio de entorno** con un archivo `.envrc` por carpeta:

```bash
# Work (principal) — no necesita .envrc porque es el default vía symlink
# Personal
echo 'export GH_CONFIG_DIR=~/.config/gh-personal' > ~/Github/Personal/.envrc
direnv allow ~/Github/Personal/.envrc

# Side-project
echo 'export GH_CONFIG_DIR=~/.config/gh-side' > ~/Github/Side/.envrc
direnv allow ~/Github/Side/.envrc
```

A partir de acá, cada vez que tu terminal entre a una de esas carpetas, `direnv` exportará automáticamente el `GH_CONFIG_DIR` correcto y `gh` operará con la cuenta indicada. Comprobalo con `gh auth status` parado en cada carpeta.

```
cd ~/Github/Personal
  ↓
direnv lee .envrc
  ↓
export GH_CONFIG_DIR=~/.config/gh-personal
  ↓
git usa ~/.gitconfig-personal (includeIf)
gh  usa ~/.config/gh-personal
ssh usa github.com-personal (IdentityFile)
```

## 7. Manejo Seguro de Credenciales (Anti-Supply Chain)

Esta es la sección que de verdad importa después de un incidente. Los ataques modernos de **supply chain** no buscan tu contraseña: buscan **exfiltrar variables de entorno y tokens en texto plano** que cualquier dependencia maliciosa pueda leer durante un `npm install`, un `postinstall` o un script de build. La regla de oro es simple: **ninguna credencial debe vivir nunca en texto plano dentro de una variable de entorno o de un archivo legible.**

### 7.1. Nunca uses un `GITHUB_TOKEN` global

El antipatrón más peligroso es definir un helper en tu `.gitconfig` que lea un token desde una variable global, por ejemplo:

```ini
# ❌ NO HAGAS ESTO
[credential]
    helper = "!f() { echo \"password=${GITHUB_TOKEN}\"; }; f"
```

Si tenés esto, cualquier proceso que corra en tu sesión (incluida una dependencia comprometida) puede leer `$GITHUB_TOKEN` con un simple `echo $GITHUB_TOKEN` y robarse tu acceso a **todos** tus repositorios. Eliminá cualquier `export GITHUB_TOKEN=...` de tu `.zshrc`, `.bashrc` o `.env` y revocá los Personal Access Tokens que ya no necesites desde *Settings → Developer settings → Tokens*.

### 7.2. Delegá la autenticación HTTPS al `gh` CLI

Para los casos en que necesités HTTPS (algunos pipelines o repos que no soportan SSH), no inventes tu propio helper: delegá en el credential helper nativo de `gh`. Este lee el token desde el almacenamiento seguro de cada `GH_CONFIG_DIR` y **nunca lo expone como variable de entorno**. Agregá este bloque a tus configs de cuentas secundarias.

En `~/.gitconfig-personal` y `~/.gitconfig-side` añadí:

```ini
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
```

> La primera línea `helper =` (vacía) es intencional: resetea cualquier helper heredado de la configuración global antes de declarar el de `gh`, evitando que un helper inseguro definido más arriba siga activo.

La magia del aislamiento se mantiene: como `direnv` ya cambió el `GH_CONFIG_DIR` según la carpeta, `gh auth git-credential` entregará el token de la cuenta correcta sin que el secreto pase jamás por una variable de entorno.

> ⚠️ **Limitación importante:** este helper solo funciona si `GH_CONFIG_DIR` está cargado, lo cual depende de `direnv`. En contextos no-interactivos —IDEs (VS Code, IntelliJ), clientes git GUI (Tower, Fork), cron, hooks de CI local— `direnv` no se carga y `gh auth git-credential` usa el default (`~/.config/gh` → cuenta principal), entregando el token equivocado. Por eso la guía recomienda **SSH exclusivamente** para interacción manual: SSH no depende de `direnv` porque el routing vive en `~/.ssh/config` y `~/.gitconfig`, que sí se leen en todos los contextos. Para HTTPS en pipelines, seteá `GH_CONFIG_DIR` explícitamente en el entorno del pipeline.

### 7.3. Confirmá dónde viven realmente tus tokens

En macOS moderno, `gh` **no** guarda el token en `hosts.yml` del `GH_CONFIG_DIR`: lo guarda en el **Keychain** del sistema. En Linux, `gh` puede usar `secret-service` (D-Bus), `pass`, o guardar el token en texto plano en `hosts.yml` si no hay un gestor de secretos disponible. El archivo `hosts.yml` siempre contiene metadatos (usuario, protocolo). Verificá:

```bash
GH_CONFIG_DIR=~/.config/gh-personal gh auth status
# macOS:  ✓ Logged in to github.com account X (keyring)
# Linux:  ✓ Logged in to github.com account X (keyring)  ← si hay secret-service/pass
#         ✓ Logged in to github.com account X            ← si no hay gestor, token en hosts.yml
```

El hardening de tokens depende del OS:

**macOS (Keychain):**
- **No compartas el Keychain entre cuentas:** `gh` guarda cada token bajo un nombre distinto por `GH_CONFIG_DIR`, así que están naturalmente separados.
- **Auditá qué tokens hay:** `security find-generic-password -s "gh:github.com" -g 2>&1 | head` (pedirá permiso de Keychain).
- **Revocá tokens huérfanos:** si dejaste de usar una cuenta, `gh auth logout` dentro de su `GH_CONFIG_DIR` limpia el Keychain.

**Linux (secret-service / pass / texto plano):**
- **Instalá un gestor de secretos:** `sudo apt-get install -y gnome-keyring pass` para que `gh` use `secret-service` en lugar de texto plano.
- **Si no hay gestor:** el token vive en `hosts.yml`. Asegurate de `chmod 600 ~/.config/gh-*/hosts.yml`.
- **Auditá:** `cat ~/.config/gh-*/hosts.yml` para ver qué cuentas tienen tokens.
- **Revocá tokens huérfanos:** `gh auth logout` dentro de cada `GH_CONFIG_DIR`.

- **`chmod 600` sigue siendo útil** para `hosts.yml` y `config.yml` (metadatos), pero no protege el token en sí si no hay gestor de secretos.

Si querés un blindaje extra, podés usar `gh auth login` con `--with-token` leyendo desde un gestor de secretos (como `1Password CLI`) en lugar de dejar el token en el Keychain/almacén, de modo que ni siquiera el sistema lo guarde de forma persistente.

### 7.4. Protegé tus llaves SSH con passphrase

Las llaves SSH del paso 2 son tu última línea de defensa. Una llave privada sin passphrase es un archivo que cualquier malware puede copiar y reutilizar en otra máquina. Con una *passphrase* fuerte, aunque te roben el archivo `id_ed25519_personal`, no podrán usarlo sin descifrarlo.

El agente SSH con integración al Keychain (macOS, paso 2) o al agente nativo (Linux) te da lo mejor de ambos mundos: trabajás cómodo sin reescribir la frase, pero la llave **nunca queda utilizable en frío** sobre el disco. Para confirmar que el agente solo tiene cargadas las llaves esperadas:

```bash
ssh-add -l   # debería listar únicamente tus llaves ed25519
```

### 7.5. Resumen de las reglas estrictas

- **No uses tokens globales:** evitá `GITHUB_TOKEN` exportado y helpers que lean variables en texto plano.
- **Delegá en herramientas nativas:** `gh auth git-credential` resuelve HTTPS de forma segura y cambia de contexto según la carpeta gracias a `direnv` (con la limitación de contextos no-interactivos).
- **Preferí SSH sobre HTTPS:** SSH no depende de `direnv` y funciona en IDEs, GUIs y cron sin configuración adicional.
- **Firmá todos los commits:** SSH para cuentas secundarias, GPG para la principal. Configurá `allowed_signers` para verificación.
- **Usá passphrases:** ninguna llave SSH debe quedar utilizable sin descifrar sobre el disco.
- **Auditá el Keychain/almacén, no solo los archivos:** los tokens viven ahí, no en `hosts.yml`.

## Cierre: el aislamiento como hábito, no como evento

Reconstruir esta configuración después de un incidente me dejó una certeza: la seguridad no es un setup que hacés una vez, sino una **frontera que las herramientas defienden por vos**. Separás por carpetas, dejás que `includeIf`, `insteadOf` y `direnv` resuelvan la identidad, firmás cada commit, y eliminás cada lugar donde un secreto pudiera vivir en texto plano.

El resultado es un entorno donde es prácticamente imposible cometer el error de mezclar identidades, donde cada commit lleva una firma verificable, y donde una dependencia comprometida en tu mundo personal no tiene ningún camino hacia tus repositorios de trabajo. Esa es la verdadera comodidad: no la de un token global a mano, sino la de saber que el aislamiento trabaja solo, en silencio, cada vez que cambiás de carpeta.
