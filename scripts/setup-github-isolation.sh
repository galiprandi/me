#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# GitHub Account Isolation Setup — macOS
# https://github.com/galiprandi/me/scripts/setup-github-isolation.sh
# ─────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────
log_info()  { echo -e "${CYAN}ℹ  $1${NC}"; }
log_ok()    { echo -e "${GREEN}✅ $1${NC}"; }
log_warn()  { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_err()   { echo -e "${RED}❌ $1${NC}"; }

separator() { echo -e "${CYAN}────────────────────────────────────────${NC}"; }

prompt_yn() {
  local msg="$1"
  local default="${2:-N}"
  local input
  while true; do
    read -rp "${msg} [y/N]: " input
    input="${input:-$default}"
    case "$input" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Por favor responde y o n." ;;
    esac
  done
}

# ── Prerrequisitos ───────────────────────────────────────────
separator
log_info "Verificando prerrequisitos..."

MISSING=()
command -v ssh-keygen >/dev/null 2>&1 || MISSING+=("ssh-keygen (OpenSSH)")
command -v gh         >/dev/null 2>&1 || MISSING+=("gh (GitHub CLI)")
command -v brew       >/dev/null 2>&1 || MISSING+=("brew (Homebrew)")

if [ ${#MISSING[@]} -gt 0 ]; then
  log_err "Faltan herramientas requeridas:"
  for m in "${MISSING[@]}"; do echo "   - $m"; done
  echo ""
  log_info "Instalalas con:"
  echo "   brew install gh openssh"
  echo "   brew install direnv  # tambien necesario mas adelante"
  exit 1
fi

# Verificar direnv
if ! command -v direnv >/dev/null 2>&1; then
  log_warn "direnv no esta instalado."
  if prompt_yn "Instalar direnv ahora via Homebrew?"; then
    brew install direnv
  else
    log_err "direnv es requerido. Instalalo manualmente y reintenta."
    exit 1
  fi
fi

log_ok "Todos los prerrequisitos cumplidos."
echo ""

# ── Reset de config existente ────────────────────────────────
separator
log_warn "PASO 0: Configuracion previa"

RESET_KEYS=false
RESET_GIT=false
RESET_SSH=false
RESET_GH=false
RESET_ENVRC=false

if [ -f ~/.gitconfig ] || [ -f ~/.gitconfig-personal ] || [ -f ~/.gitconfig-work ]; then
  if prompt_yn "Encontré configuracion previa de Git. Eliminarla y empezar desde cero?"; then
    RESET_GIT=true
  fi
fi

if [ -f ~/.ssh/id_ed25519_personal ] || [ -f ~/.ssh/id_ed25519_work ]; then
  if prompt_yn "Encontré llaves SSH previas (personal/work). Regenerarlas?"; then
    RESET_KEYS=true
  fi
fi

if [ -f ~/.ssh/config ] && grep -q "github.com-work" ~/.ssh/config 2>/dev/null; then
  if prompt_yn "Encontré alias github.com-work en ~/.ssh/config. Reemplazarlo?"; then
    RESET_SSH=true
  fi
fi

if [ -d ~/.config/gh-personal ] || [ -d ~/.config/gh-work ]; then
  if prompt_yn "Encontré configuracion previa de gh (personal/work). Eliminarla?"; then
    RESET_GH=true
  fi
fi

# ── Inputs del usuario ───────────────────────────────────────
separator
echo ""
log_info "PASO 1: Datos de configuracion"
echo ""

read -rp "Carpeta para repos PERSONALES [~/Repos/Personal]: " PERSONAL_DIR
PERSONAL_DIR="${PERSONAL_DIR:-~/Repos/Personal}"
PERSONAL_DIR="${PERSONAL_DIR/#\~/$HOME}"

read -rp "Carpeta para repos de TRABAJO [~/Repos/Work]: " WORK_DIR
WORK_DIR="${WORK_DIR:-~/Repos/Work}"
WORK_DIR="${WORK_DIR/#\~/$HOME}"

read -rp "Email PERSONAL: " PERSONAL_EMAIL
read -rp "Email de TRABAJO: " WORK_EMAIL
read -rp "Tu nombre completo (para Git): " GIT_NAME

# Validacion basica de emails
for email in "$PERSONAL_EMAIL" "$WORK_EMAIL"; do
  if [[ ! "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    log_err "Email invalido: $email"
    exit 1
  fi
  if [ "$PERSONAL_EMAIL" = "$WORK_EMAIL" ]; then
    log_err "Los emails personal y de trabajo deben ser distintos."
    exit 1
  fi
done

# Confirmacion final
echo ""
separator
echo "Resumen de configuracion:"
echo "  Personal dir : $PERSONAL_DIR"
echo "  Work dir     : $WORK_DIR"
echo "  Personal mail: $PERSONAL_EMAIL"
echo "  Work mail    : $WORK_EMAIL"
echo "  Git name     : $GIT_NAME"
echo ""

if ! prompt_yn "Confirmas y procedemos?"; then
  log_info "Cancelado por el usuario."
  exit 0
fi

# ── 1. Carpetas ──────────────────────────────────────────────
separator
log_info "PASO 2: Creando carpetas..."
mkdir -p "$PERSONAL_DIR" "$WORK_DIR"
log_ok "Carpetas creadas:"
echo "  $PERSONAL_DIR"
echo "  $WORK_DIR"

# ── 2. Llaves SSH ────────────────────────────────────────────
separator
log_info "PASO 3: Generando llaves SSH ED25519..."

if [ "$RESET_KEYS" = true ]; then
  rm -f ~/.ssh/id_ed25519_personal ~/.ssh/id_ed25519_personal.pub
  rm -f ~/.ssh/id_ed25519_work ~/.ssh/id_ed25519_work.pub
fi

# Personal
if [ ! -f ~/.ssh/id_ed25519_personal ]; then
  ssh-keygen -t ed25519 -C "$PERSONAL_EMAIL" -f ~/.ssh/id_ed25519_personal
else
  log_warn "Llave personal ya existe, se omite."
fi

# Work
if [ ! -f ~/.ssh/id_ed25519_work ]; then
  ssh-keygen -t ed25519 -C "$WORK_EMAIL" -f ~/.ssh/id_ed25519_work
else
  log_warn "Llave de trabajo ya existe, se omite."
fi

# Agregar al agente
log_info "Agregando llaves al agente SSH..."
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal 2>/dev/null || ssh-add ~/.ssh/id_ed25519_personal 2>/dev/null || true
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work 2>/dev/null || ssh-add ~/.ssh/id_ed25519_work 2>/dev/null || true

log_ok "Llaves generadas. Recorda cargar los archivos .pub en GitHub:"
echo "  ~/.ssh/id_ed25519_personal.pub  → tu cuenta personal"
echo "  ~/.ssh/id_ed25519_work.pub      → tu cuenta de trabajo"

# ── 3. SSH Config ────────────────────────────────────────────
separator
log_info "PASO 4: Configurando ~/.ssh/config..."

if [ ! -d ~/.ssh ]; then mkdir -p ~/.ssh && chmod 700 ~/.ssh; fi

if [ "$RESET_SSH" = true ] && [ -f ~/.ssh/config ]; then
  # Hacer backup del config anterior
  cp ~/.ssh/config ~/.ssh/config.backup.$(date +%s)
  # Eliminar bloques anteriores de nuestro script
  sed -i '' '/# === GitHub Isolation ===/,/# === End GitHub Isolation ===/d' ~/.ssh/config 2>/dev/null || true
fi

# Verificar si ya existe nuestro bloque
if ! grep -q "# === GitHub Isolation ===" ~/.ssh/config 2>/dev/null; then
  cat >> ~/.ssh/config <<EOF

# === GitHub Isolation ===
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
# === End GitHub Isolation ===
EOF
  log_ok "~/.ssh/config actualizado."
else
  log_warn "Bloque de aislamiento ya existe en ~/.ssh/config, se omite."
fi

chmod 600 ~/.ssh/config

# ── 4. Git Config ────────────────────────────────────────────
separator
log_info "PASO 5: Configurando Git (~/.gitconfig + perfiles)..."

if [ "$RESET_GIT" = true ]; then
  for f in ~/.gitconfig ~/.gitconfig-personal ~/.gitconfig-work; do
    [ -f "$f" ] && mv "$f" "$f.backup.$(date +%s)" && log_warn "Backup creado: $f.backup.*"
  done
fi

# Global
if [ ! -f ~/.gitconfig ] || [ "$RESET_GIT" = true ]; then
  cat > ~/.gitconfig <<EOF
[user]
    name = $GIT_NAME

[pull]
    rebase = true

[includeIf "gitdir:${PERSONAL_DIR}/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:${WORK_DIR}/"]
    path = ~/.gitconfig-work
EOF
  log_ok "~/.gitconfig creado."
else
  log_warn "~/.gitconfig ya existe. Agregando includeIf si faltan..."
  if ! grep -q "gitdir:${PERSONAL_DIR}/" ~/.gitconfig; then
    cat >> ~/.gitconfig <<EOF
[includeIf "gitdir:${PERSONAL_DIR}/"]
    path = ~/.gitconfig-personal
EOF
  fi
  if ! grep -q "gitdir:${WORK_DIR}/" ~/.gitconfig; then
    cat >> ~/.gitconfig <<EOF
[includeIf "gitdir:${WORK_DIR}/"]
    path = ~/.gitconfig-work
EOF
  fi
fi

# Personal
cat > ~/.gitconfig-personal <<EOF
[user]
    email = $PERSONAL_EMAIL
EOF

# Work
cat > ~/.gitconfig-work <<EOF
[user]
    email = $WORK_EMAIL

[url "git@github.com-work:"]
    insteadOf = "git@github.com:"
EOF

log_ok "Perfiles de Git creados."

# ── 5. direnv ────────────────────────────────────────────────
separator
log_info "PASO 6: Configurando direnv..."

# Hook en .zshrc
if [ -f ~/.zshrc ] && ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  log_ok "Hook de direnv agregado a ~/.zshrc."
else
  log_warn "Hook de direnv ya presente u omitido."
fi

# .envrc por carpeta
if [ "$RESET_ENVRC" = true ] || [ ! -f "$PERSONAL_DIR/.envrc" ]; then
  echo 'export GH_CONFIG_DIR=~/.config/gh-personal' > "$PERSONAL_DIR/.envrc"
  direnv allow "$PERSONAL_DIR/.envrc" 2>/dev/null || true
  log_ok ".envrc creado en Personal."
fi

if [ "$RESET_ENVRC" = true ] || [ ! -f "$WORK_DIR/.envrc" ]; then
  echo 'export GH_CONFIG_DIR=~/.config/gh-work' > "$WORK_DIR/.envrc"
  direnv allow "$WORK_DIR/.envrc" 2>/dev/null || true
  log_ok ".envrc creado en Work."
fi

# ── 6. gh CLI ────────────────────────────────────────────────
separator
log_info "PASO 7: Configurando gh CLI..."

mkdir -p ~/.config/gh-personal ~/.config/gh-work

if [ "$RESET_GH" = true ]; then
  rm -rf ~/.config/gh-personal/* ~/.config/gh-work/*
fi

log_info "Autenticando cuenta PERSONAL (selecciona SSH cuando se te pregunte)..."
GH_CONFIG_DIR=~/.config/gh-personal gh auth login

log_info "Autenticando cuenta de TRABAJO (selecciona SSH cuando se te pregunte)..."
GH_CONFIG_DIR=~/.config/gh-work gh auth login

# Permisos restrictivos
chmod 600 ~/.config/gh-personal/hosts.yml 2>/dev/null || true
chmod 600 ~/.config/gh-work/hosts.yml 2>/dev/null || true

# ── 7. Credential helper en perfiles Git ─────────────────────
separator
log_info "PASO 8: Agregando credential helper seguro a los perfiles..."

for cfg in ~/.gitconfig-personal ~/.gitconfig-work; do
  if ! grep -q "gh auth git-credential" "$cfg" 2>/dev/null; then
    cat >> "$cfg" <<EOF

[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
EOF
    log_ok "Credential helper agregado a $(basename $cfg)."
  fi
done

# ── 8. Verificacion ──────────────────────────────────────────
separator
log_info "PASO 9: Verificacion rapida..."

echo ""
echo "Git identity en Personal:"
cd "$PERSONAL_DIR" && git config --show-origin --get user.email || true

echo ""
echo "Git identity en Work:"
cd "$WORK_DIR" && git config --show-origin --get user.email || true

echo ""
echo "gh status Personal:"
GH_CONFIG_DIR=~/.config/gh-personal gh auth status || true

echo ""
echo "gh status Work:"
GH_CONFIG_DIR=~/.config/gh-work gh auth status || true

echo ""
echo "Llaves en agente:"
ssh-add -l || true

# ── Resumen final ────────────────────────────────────────────
separator
log_ok "Configuracion completada."
echo ""
echo -e "${GREEN}Resumen:${NC}"
echo "  Personal dir : $PERSONAL_DIR"
echo "  Work dir     : $WORK_DIR"
echo "  Personal mail: $PERSONAL_EMAIL"
echo "  Work mail    : $WORK_EMAIL"
echo ""
echo "Archivos generados/modificados:"
echo "  ~/.gitconfig"
echo "  ~/.gitconfig-personal"
echo "  ~/.gitconfig-work"
echo "  ~/.ssh/config"
echo "  ~/.ssh/id_ed25519_personal + .pub"
echo "  ~/.ssh/id_ed25519_work + .pub"
echo "  $PERSONAL_DIR/.envrc"
echo "  $WORK_DIR/.envrc"
echo "  ~/.config/gh-personal/"
echo "  ~/.config/gh-work/"
echo ""
log_warn "Pendientes manuales:"
echo "  1. Carga las llaves .pub en GitHub (Settings → SSH and GPG keys)"
echo "  2. Reinicia tu terminal o corre: source ~/.zshrc"
echo "  3. Proba: cd $WORK_DIR && gh auth status && git config user.email"
echo ""
log_ok "Listo. Tu entorno esta aislado y endurecido."
