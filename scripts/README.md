# GitHub Account Isolation — One-Click Setup

Script de configuración para aislar completamente tus cuentas de GitHub (personal y trabajo) en macOS, con SSH, Git y `gh` CLI, endurecido contra ataques de supply chain.

## Requisitos

- macOS (probado en Sonoma / Sequoia)
- [Homebrew](https://brew.sh)
- [GitHub CLI](https://cli.github.com) (`gh`)
- OpenSSH (incluido en macOS)

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

1. **Reset opcional:** pregunta si deseás eliminar la configuración previa de Git, SSH o `gh` para empezar desde cero.
2. **Solicita datos:** carpetas de repos, emails y nombre para Git.
3. **Genera llaves SSH:** ED25519 con passphrase, una por cuenta.
4. **Configura `~/.ssh/config`:** alias `github.com-work` con `IdentitiesOnly yes`.
5. **Configura `~/.gitconfig`:** `includeIf` por carpeta + regla `insteadOf`.
6. **Separa `gh` CLI:** directorios `~/.config/gh-personal` y `~/.config/gh-work` vía `direnv`.
7. **Endurece credenciales:** agrega `gh auth git-credential` sin exponer tokens en variables de entorno.
8. **Verifica:** muestra identidades activas en cada carpeta.

## Post-instalación

- Cargá las llaves `.pub` en cada cuenta de GitHub (*Settings → SSH and GPG keys*).
- Reiniciá la terminal o ejecutá `source ~/.zshrc` para activar `direnv`.
- Verificá el aislamiento:
  ```bash
  cd ~/Repos/Work    && gh auth status && git config user.email
  cd ~/Repos/Personal && gh auth status && git config user.email
  ```

## Licencia

MIT © Germán Aliprandi
