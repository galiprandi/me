# GitHub Multi-Account Isolation — One-Click Setup

Script de configuración para aislar **N cuentas** de GitHub en una misma máquina, con SSH, Git con firma de commits (SSH + GPG), `gh` CLI separado por carpeta, y endurecimiento contra ataques de supply chain.

**Cross-platform:** macOS y Linux (Debian/Ubuntu).

## Requisitos

| Herramienta | macOS | Linux (Debian/Ubuntu) |
|---|---|---|
| Git | `brew install git` | `sudo apt-get install -y git` |
| GitHub CLI (`gh`) | `brew install gh` | [Instalación oficial](https://github.com/cli/cli#installation) |
| OpenSSH | incluido | `sudo apt-get install -y openssh-client` |
| GnuPG | `brew install gnupg` | `sudo apt-get install -y gnupg` |
| `direnv` | `brew install direnv` | `sudo apt-get install -y direnv` |
| Clipboard | `pbcopy` (incluido) | `sudo apt-get install -y xclip` |

> El script detecta el OS automáticamente y adapta los comandos (brew vs apt, `--apple-use-keychain` vs `ssh-add` plano, `pbcopy` vs `xclip`).

## Instalación rápida

```bash
curl -sSL https://raw.githubusercontent.com/galiprandi/me/main/scripts/setup-github-isolation.sh | bash
```

> ⚠️  Por seguridad, siempre revisá el contenido del script antes de ejecutarlo:
> `curl -sSL ... | cat` para leerlo primero.

## Instalación manual (recomendado)

```bash
git clone https://github.com/galiprandi/me.git
cd me/scripts
chmod +x setup-github-isolation.sh
./setup-github-isolation.sh
```

## Qué hace el script

1. **Detecta el OS:** macOS o Linux, y adapta los prerrequisitos y comandos accordingly.
2. **Reset opcional:** pregunta si deseás eliminar la configuración previa de Git, SSH o `gh` para empezar desde cero (con backup automático).
3. **Solicita N cuentas:** cantidad de cuentas, nombre, email, carpeta y formato de firma por cada una. La primera cuenta es la **principal** (default global con firma).
4. **Genera llaves SSH:** ED25519 con passphrase, una por cuenta.
5. **Configura `~/.ssh/config`:** un `Host` por cuenta con `IdentitiesOnly yes`. La principal usa `github.com` real; las demás usan aliases `github.com-<name>`.
6. **Configura `~/.gitconfig`:** global con la cuenta principal (email + firma + `allowed_signers`), e `includeIf` por carpeta para las cuentas secundarias.
7. **Configura firma de commits:** SSH por default para secundarias; GPG/OpenPGP opcional para la principal. En Linux headless, genera la clave GPG con `--batch --passphrase ""` para evitar `pinentry-curses`. Genera `~/.config/git/allowed_signers` automáticamente con todas las claves públicas.
8. **Separa `gh` CLI:** directorios `~/.config/gh-<name>` por cuenta vía `direnv`, y un symlink `~/.config/gh → gh-<principal>` para el default.
9. **Endurece credenciales:** agrega `gh auth git-credential` a los perfiles secundarios (sin exponer tokens en variables de entorno).
10. **Verifica:** muestra identidades activas, firmas, `gh auth status` y `allowed_signers` al final.

## Post-instalación

- Cargá las llaves `.pub` en cada cuenta de GitHub (*Settings → SSH and GPG keys*). Marcá cada clave como **Authentication Key** y **Signing Key**.
- Si la cuenta principal usa GPG, subí la clave pública:
  ```bash
  # macOS
  gpg --armor --export <KEY_ID> | pbcopy
  # Linux
  gpg --armor --export <KEY_ID> | xclip -selection clipboard
  ```
  → *Settings → SSH and GPG keys → New GPG key*.
- Reiniciá la terminal o ejecutá `source ~/.zshrc` (macOS) o `source ~/.bashrc` (Linux) para activar `direnv`.
- Verificá el aislamiento:
  ```bash
  cd ~/Github/Work     && gh auth status && git config user.email
  cd ~/Github/Personal && gh auth status && git config user.email
  cd /tmp              && git config user.email   # debe ser la cuenta principal
  ```

## Probado en

- macOS (Sonoma / Sequoia) con Homebrew
- Linux Ubuntu 7.0 (Lenovo) con apt — test end-to-end con 2 cuentas (Cenco GPG + Personal SSH), firma de commits verificada con `git log --show-signature`

## Licencia

MIT © Germán Aliprandi
