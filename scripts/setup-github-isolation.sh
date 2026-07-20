#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# GitHub Multi-Account Isolation Setup — macOS & Linux
# https://github.com/galiprandi/me/scripts/setup-github-isolation.sh
#
# Soporta N cuentas. Cuenta principal = default global con firma.
# Cuentas secundarias = overrides via includeIf.
# Firma: SSH por default, GPG opcional para la principal.
# Cross-platform: detecta macOS vs Linux y adapta prerrequisitos.
# ─────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────
log_info()  { echo -e "${CYAN}ℹ  $1${NC}"; }
log_ok()    { echo -e "${GREEN}✅ $1${NC}"; }
log_warn()  { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_err()   { echo -e "${RED}❌ $1${NC}"; }
log_step()  { echo -e "${BOLD}${CYAN}── $1 ──${NC}"; }

separator() { echo -e "${CYAN}────────────────────────────────────────${NC}"; }

# ── Deteccion de OS ──────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      log_err "OS no soportado: $OS (solo macOS y Linux)"; exit 1 ;;
esac

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

prompt_str() {
  local msg="$1"
  local default="${2:-}"
  local allow_empty="${3:-0}"
  local input
  if [ -n "$default" ]; then
    read -rp "${msg} [${default}]: " input
    echo "${input:-$default}"
  elif [ "$allow_empty" = "1" ]; then
    read -rp "${msg}: " input
    echo "$input"
  else
    while true; do
      read -rp "${msg}: " input
      [ -n "$input" ] && echo "$input" && return
      echo "  No puede ser vacio."
    done
  fi
}

# copy_to_clipboard: multi-OS
copy_to_clipboard() {
  local file="$1"
  if [ "$OS" = "macos" ]; then
    pbcopy < "$file" && echo "(copiado al portapapeles via pbcopy)"
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard < "$file" && echo "(copiado al portapapeles via xclip)"
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy < "$file" && echo "(copiado al portapapeles via wl-copy)"
  else
    echo "(instala xclip o wl-copy para copiar automaticamente; contenido en $file)"
  fi
}

# ssh_add_key: multi-OS (macOS usa --apple-use-keychain)
ssh_add_key() {
  local key="$1"
  if [ "$OS" = "macos" ]; then
    ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null || true
  else
    ssh-add "$key" 2>/dev/null || true
  fi
}

# install_package: multi-OS
install_package() {
  local pkg="$1"
  if [ "$OS" = "macos" ]; then
    brew install "$pkg"
  else
    sudo apt-get update -qq && sudo apt-get install -y "$pkg"
  fi
}

# ── Estructura de datos: arrays paralelos ────────────────────
declare -a ACC_NAME ACC_EMAIL ACC_DIR ACC_SSH_KEY ACC_SSH_HOST ACC_GH_DIR ACC_IS_PRIMARY ACC_SIGN_FORMAT ACC_GPG_KEYID
ACC_COUNT=0
PRIMARY_IDX=-1

add_account() {
  local name="$1" email="$2" dir="$3" ssh_key="$4" ssh_host="$5" gh_dir="$6" is_primary="$7" sign_format="$8" gpg_keyid="$9"
  ACC_NAME+=("$name")
  ACC_EMAIL+=("$email")
  ACC_DIR+=("$dir")
  ACC_SSH_KEY+=("$ssh_key")
  ACC_SSH_HOST+=("$ssh_host")
  ACC_GH_DIR+=("$gh_dir")
  ACC_IS_PRIMARY+=("$is_primary")
  ACC_SIGN_FORMAT+=("$sign_format")
  ACC_GPG_KEYID+=("$gpg_keyid")
  if [ "$is_primary" = "1" ]; then
    PRIMARY_IDX=$ACC_COUNT
  fi
  ACC_COUNT=$((ACC_COUNT + 1))
}

# ── Prerrequisitos ───────────────────────────────────────────
separator
log_info "Detectando OS: $OS"
log_info "Verificando prerrequisitos..."

MISSING=()
command -v ssh-keygen >/dev/null 2>&1 || MISSING+=("ssh-keygen (OpenSSH)")
command -v git         >/dev/null 2>&1 || MISSING+=("git")
command -v gh          >/dev/null 2>&1 || MISSING+=("gh (GitHub CLI)")

if [ "$OS" = "macos" ]; then
  command -v brew >/dev/null 2>&1 || MISSING+=("brew (Homebrew)")
else
  command -v apt-get >/dev/null 2>&1 || MISSING+=("apt-get (Debian/Ubuntu)")
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  log_err "Faltan herramientas requeridas:"
  for m in "${MISSING[@]}"; do echo "   - $m"; done
  echo ""
  if [ "$OS" = "macos" ]; then
    log_info "Instalalas con:"
    echo "   brew install gh openssh direnv"
  else
    log_info "Instalalas con:"
    echo "   sudo apt-get update && sudo apt-get install -y gh openssh-client direnv gnupg xclip"
    echo "   (gh en Ubuntu/Debian puede requerir el repo oficial: https://github.com/cli/cli#installation)"
  fi
  exit 1
fi

# Instalar direnv si falta
if ! command -v direnv >/dev/null 2>&1; then
  log_warn "direnv no esta instalado."
  if prompt_yn "Instalar direnv ahora?"; then
    install_package direnv
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

RESET_GIT=false
RESET_SSH=false
RESET_GH=false
RESET_ENVRC=false

if [ -f ~/.gitconfig ] || ls ~/.gitconfig-* >/dev/null 2>&1; then
  if prompt_yn "Encontre configuracion previa de Git. Eliminarla y empezar desde cero?"; then
    RESET_GIT=true
  fi
fi

if ls ~/.ssh/id_ed25519_* >/dev/null 2>&1; then
  if prompt_yn "Encontre llaves SSH previas (id_ed25519_*). Regenerarlas?"; then
    RESET_SSH=true
  fi
fi

if ls -d ~/.config/gh-* >/dev/null 2>&1; then
  if prompt_yn "Encontre configuracion previa de gh (gh-*). Eliminarla?"; then
    RESET_GH=true
  fi
fi

# ── Inputs del usuario: N cuentas ────────────────────────────
separator
echo ""
log_step "PASO 1: Datos de configuracion"
echo ""

read -rp "Cuantas cuentas queres configurar? [2]: " N_ACCOUNTS
N_ACCOUNTS="${N_ACCOUNTS:-2}"
if ! [[ "$N_ACCOUNTS" =~ ^[0-9]+$ ]] || [ "$N_ACCOUNTS" -lt 2 ]; then
  log_err "Debe ser un numero entero >= 2."
  exit 1
fi

GIT_NAME="$(prompt_str "Tu nombre completo (para Git)")"

echo ""
log_info "Vamos a configurar $N_ACCOUNTS cuenta(s)."
log_info "La PRIMERA cuenta que ingreses sera la PRINCIPAL (default global con firma)."
echo ""

for i in $(seq 1 "$N_ACCOUNTS"); do
  separator
  if [ "$i" -eq 1 ]; then
    echo -e "${BOLD}Cuenta $i/$N_ACCOUNTS — PRINCIPAL (default)${NC}"
  else
    echo -e "${BOLD}Cuenta $i/$N_ACCOUNTS${NC}"
  fi
  echo ""

  NAME="$(prompt_str "  Nombre corto (ej: work, personal, side)")"
  EMAIL="$(prompt_str "  Email de GitHub")"

  # Validacion de email
  if [[ ! "$EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    log_err "Email invalido: $EMAIL"
    exit 1
  fi

  DEFAULT_DIR="$HOME/repos/${NAME}"
  DIR="$(prompt_str "  Carpeta para repos" "$DEFAULT_DIR")"
  DIR="${DIR/#\~/$HOME}"

  # Validar email unico
  for prev in "${ACC_EMAIL[@]:-}"; do
    if [ "$prev" = "$EMAIL" ]; then
      log_err "Email duplicado: $EMAIL. Cada cuenta debe tener un email distinto."
      exit 1
    fi
  done

  # SSH key path
  SSH_KEY="$HOME/.ssh/id_ed25519_${NAME}"

  # SSH host alias
  if [ "$i" -eq 1 ]; then
    SSH_HOST="github.com"
    IS_PRIMARY=1
  else
    SSH_HOST="github.com-${NAME}"
    IS_PRIMARY=0
  fi

  # GH config dir
  GH_DIR="$HOME/.config/gh-${NAME}"

  # Firma
  if [ "$IS_PRIMARY" = "1" ]; then
    echo ""
    log_info "  Cuenta principal: elegir formato de firma."
    echo "    1) SSH (reusa llave ed25519, mas simple)"
    echo "    2) GPG/OpenPGP (tradicional, clave separada)"
    read -rp "  Formato de firma [1=SSH]: " SIGN_CHOICE
    SIGN_CHOICE="${SIGN_CHOICE:-1}"
    case "$SIGN_CHOICE" in
      2)
        SIGN_FORMAT="openpgp"
        echo ""
        log_info "  Vamos a generar una clave GPG para la cuenta principal."
        GPG_KEYID="$(prompt_str "  Si ya tenes una clave GPG, pegá su ID (ej: 2970AAB9B51D85F3). Vacio = generar nueva" "" 1)"
        if [ -z "$GPG_KEYID" ]; then
          log_info "  Generando nueva clave GPG..."
          # Usar --batch con %no-protection para evitar pinentry (TUI) en SSH/headless
          # Funciona en macOS y Linux. La clave queda sin passphrase (aceptable para signing keys)
          gpg --batch --passphrase "" --quick-generate-key "$EMAIL" ed25519 sign 0 >/dev/null 2>&1 || {
            log_err "  Fallo la generacion de clave GPG. Generela manualmente con:"
            echo "    gpg --batch --passphrase \"\" --quick-generate-key \"$EMAIL\" ed25519 sign 0"
            exit 1
          }
          GPG_KEYID="$(gpg --list-secret-keys --keyid-format=long --with-colons 2>/dev/null | grep '^sec' | tail -1 | cut -d: -f5)"
          log_ok "  Clave GPG generada: $GPG_KEYID"
          log_info "  Subila a GitHub: gpg --armor --export $GPG_KEYID | pbcopy  →  Settings → SSH and GPG keys → New GPG key"
        fi
        ;;
      *)
        SIGN_FORMAT="ssh"
        GPG_KEYID=""
        ;;
    esac
  else
    SIGN_FORMAT="ssh"
    GPG_KEYID=""
  fi

  add_account "$NAME" "$EMAIL" "$DIR" "$SSH_KEY" "$SSH_HOST" "$GH_DIR" "$IS_PRIMARY" "$SIGN_FORMAT" "$GPG_KEYID"
done

# Confirmacion final
echo ""
separator
echo "Resumen de configuracion:"
echo "  OS      : $OS"
echo "  Git name: $GIT_NAME"
echo ""
for i in "${!ACC_NAME[@]}"; do
  tag=""
  [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && tag=" (PRINCIPAL)"
  echo "  Cuenta: ${ACC_NAME[$i]}${tag}"
  echo "    email     : ${ACC_EMAIL[$i]}"
  echo "    carpeta   : ${ACC_DIR[$i]}"
  echo "    ssh key   : ${ACC_SSH_KEY[$i]}"
  echo "    ssh host  : ${ACC_SSH_HOST[$i]}"
  echo "    gh dir    : ${ACC_GH_DIR[$i]}"
  echo "    firma     : ${ACC_SIGN_FORMAT[$i]}${ACC_GPG_KEYID[$i]:+ (key: ${ACC_GPG_KEYID[$i]})}"
  echo ""
done

if ! prompt_yn "Confirmas y procedemos?"; then
  log_info "Cancelado por el usuario."
  exit 0
fi

# ── 1. Carpetas ──────────────────────────────────────────────
separator
log_step "PASO 2: Creando carpetas..."
for i in "${!ACC_NAME[@]}"; do
  mkdir -p "${ACC_DIR[$i]}"
done
log_ok "Carpetas creadas."

# ── 2. Llaves SSH ────────────────────────────────────────────
separator
log_step "PASO 3: Generando llaves SSH ED25519..."

if [ "$RESET_SSH" = true ]; then
  for i in "${!ACC_NAME[@]}"; do
    rm -f "${ACC_SSH_KEY[$i]}" "${ACC_SSH_KEY[$i]}.pub"
  done
fi

for i in "${!ACC_NAME[@]}"; do
  KEY="${ACC_SSH_KEY[$i]}"
  if [ ! -f "$KEY" ]; then
    ssh-keygen -t ed25519 -C "${ACC_EMAIL[$i]}" -f "$KEY"
  else
    log_warn "Llave ${ACC_NAME[$i]} ya existe, se omite: $KEY"
  fi
done

log_info "Agregando llaves al agente SSH..."
# Asegurar que el agente está corriendo (Linux no lo auto-inicia)
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  eval "$(ssh-agent -s)" 2>/dev/null || true
fi
for i in "${!ACC_NAME[@]}"; do
  ssh_add_key "${ACC_SSH_KEY[$i]}"
done

log_ok "Llaves generadas. Recorda cargar los .pub en GitHub (Settings → SSH and GPG keys):"
for i in "${!ACC_NAME[@]}"; do
  echo "  ${ACC_SSH_KEY[$i]}.pub  → cuenta ${ACC_NAME[$i]}"
done

# ── 3. SSH Config ────────────────────────────────────────────
separator
log_step "PASO 4: Configurando ~/.ssh/config..."

if [ ! -d ~/.ssh ]; then mkdir -p ~/.ssh && chmod 700 ~/.ssh; fi

if [ "$RESET_SSH" = true ] && [ -f ~/.ssh/config ]; then
  cp ~/.ssh/config ~/.ssh/config.backup.$(date +%s)
  if [ "$OS" = "macos" ]; then
    sed -i '' '/# === GitHub Isolation ===/,/# === End GitHub Isolation ===/d' ~/.ssh/config 2>/dev/null || true
  else
    sed -i '/# === GitHub Isolation ===/,/# === End GitHub Isolation ===/d' ~/.ssh/config 2>/dev/null || true
  fi
fi

if ! grep -q "# === GitHub Isolation ===" ~/.ssh/config 2>/dev/null; then
  {
    echo ""
    echo "# === GitHub Isolation ==="
    for i in "${!ACC_NAME[@]}"; do
      TAG="Cuenta"
      [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && TAG="Cuenta principal"
      echo "# $TAG: ${ACC_NAME[$i]}"
      echo "Host ${ACC_SSH_HOST[$i]}"
      echo "    HostName github.com"
      echo "    User git"
      echo "    IdentityFile ${ACC_SSH_KEY[$i]}"
      echo "    IdentitiesOnly yes"
      echo "    AddKeysToAgent yes"
      echo ""
    done
    echo "# === End GitHub Isolation ==="
  } >> ~/.ssh/config
  log_ok "~/.ssh/config actualizado."
else
  log_warn "Bloque de aislamiento ya existe en ~/.ssh/config, se omite."
fi

chmod 600 ~/.ssh/config

# ── 4. Git Config ────────────────────────────────────────────
separator
log_step "PASO 5: Configurando Git (~/.gitconfig + perfiles)..."

if [ "$RESET_GIT" = true ]; then
  for f in ~/.gitconfig ~/.gitconfig-*; do
    [ -f "$f" ] && mv "$f" "$f.backup.$(date +%s)" && log_warn "Backup: $f.backup.*"
  done
fi

# Global: cuenta principal con firma
PRIMARY="${PRIMARY_IDX}"
if [ ! -f ~/.gitconfig ] || [ "$RESET_GIT" = true ]; then
  SIGNKEY_LINE=""
  if [ "${ACC_SIGN_FORMAT[$PRIMARY]}" = "openpgp" ] && [ -n "${ACC_GPG_KEYID[$PRIMARY]}" ]; then
    SIGNKEY_LINE="    signingkey = ${ACC_GPG_KEYID[$PRIMARY]}"
  elif [ "${ACC_SIGN_FORMAT[$PRIMARY]}" = "ssh" ]; then
    SIGNKEY_LINE="    signingkey = ${ACC_SSH_KEY[$PRIMARY]}.pub"
  fi

  GPG_FORMAT="${ACC_SIGN_FORMAT[$PRIMARY]}"
  GPG_PROGRAM_LINE=""
  if [ "$GPG_FORMAT" = "openpgp" ]; then
    GPG_PROGRAM_LINE="    program = gpg"
  fi

  cat > ~/.gitconfig <<EOF
[user]
    name = $GIT_NAME
    email = ${ACC_EMAIL[$PRIMARY]}
${SIGNKEY_LINE}

[commit]
    gpgsign = true

[gpg]
    format = $GPG_FORMAT
${GPG_PROGRAM_LINE}

[gpg "ssh"]
    allowedSignersFile = ~/.config/git/allowed_signers

EOF

  # includeIf solo para cuentas secundarias
  for i in "${!ACC_NAME[@]}"; do
    [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && continue
    cat >> ~/.gitconfig <<EOF
[includeIf "gitdir:${ACC_DIR[$i]}/"]
    path = ~/.gitconfig-${ACC_NAME[$i]}

EOF
  done

  # filter lfs (preservar si ya existia)
  if ! grep -q 'filter "lfs"' ~/.gitconfig 2>/dev/null; then
    cat >> ~/.gitconfig <<'EOF'
[filter "lfs"]
    process = git-lfs filter-process
    required = true
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
EOF
  fi

  log_ok "~/.gitconfig creado con cuenta principal como default."
else
  log_warn "~/.gitconfig ya existe. Revisalo manualmente para alinearlo con esta guia."
fi

# Perfiles secundarios
for i in "${!ACC_NAME[@]}"; do
  [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && continue
  NAME="${ACC_NAME[$i]}"
  CFG="$HOME/.gitconfig-${NAME}"
  cat > "$CFG" <<EOF
[user]
    name = $GIT_NAME
    email = ${ACC_EMAIL[$i]}
    signingkey = ${ACC_SSH_KEY[$i]}.pub

[commit]
    gpgsign = true

[gpg]
    format = ssh

[url "git@github.com-${NAME}:"]
    insteadOf = "git@github.com:"

[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
EOF
  log_ok "Perfil creado: $CFG"
done

# ── 5. allowed_signers ───────────────────────────────────────
separator
log_step "PASO 6: Configurando allowed_signers..."

mkdir -p ~/.config/git
ALLOWED=~/.config/git/allowed_signers
> "$ALLOWED"  # truncar

for i in "${!ACC_NAME[@]}"; do
  EMAIL="${ACC_EMAIL[$i]}"
  PUBKEY="$(cat "${ACC_SSH_KEY[$i]}.pub" 2>/dev/null)"
  if [ -n "$PUBKEY" ]; then
    echo "${EMAIL} namespaces=\"git\" ${PUBKEY}" >> "$ALLOWED"
  fi
done

chmod 600 "$ALLOWED"
log_ok "allowed_signers creado con ${#ACC_NAME[@]} entradas: $ALLOWED"

# ── 6. direnv ────────────────────────────────────────────────
separator
log_step "PASO 7: Configurando direnv..."

# Hook en shell rc
SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
  zsh)
    if [ -f ~/.zshrc ] && ! grep -q 'eval "$(direnv hook zsh)"' ~/.zshrc; then
      echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
      log_ok "Hook de direnv agregado a ~/.zshrc."
    else
      log_warn "Hook de direnv ya presente u omitido en ~/.zshrc."
    fi
    ;;
  bash)
    if [ -f ~/.bashrc ] && ! grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
      echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
      log_ok "Hook de direnv agregado a ~/.bashrc."
    else
      log_warn "Hook de direnv ya presente u omitido en ~/.bashrc."
    fi
    ;;
  *)
    log_warn "Shell $SHELL_NAME no soportado para auto-hook. Agregá manualmente: eval \"\$(direnv hook $SHELL_NAME)\""
    ;;
esac

# .envrc solo para cuentas secundarias (la principal usa el symlink)
for i in "${!ACC_NAME[@]}"; do
  [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && continue
  DIR="${ACC_DIR[$i]}"
  GHDIR="${ACC_GH_DIR[$i]}"
  if [ "$RESET_ENVRC" = true ] || [ ! -f "$DIR/.envrc" ]; then
    echo "export GH_CONFIG_DIR=$GHDIR" > "$DIR/.envrc"
    direnv allow "$DIR/.envrc" 2>/dev/null || true
    log_ok ".envrc creado en ${ACC_NAME[$i]}."
  fi
done

# ── 7. gh CLI ────────────────────────────────────────────────
separator
log_step "PASO 8: Configurando gh CLI..."

if [ "$RESET_GH" = true ]; then
  for i in "${!ACC_NAME[@]}"; do
    rm -rf "${ACC_GH_DIR[$i]}"
  done
  rm -f ~/.config/gh  # symlink si existia
fi

for i in "${!ACC_NAME[@]}"; do
  mkdir -p "${ACC_GH_DIR[$i]}"
done

# Symlink default -> cuenta principal
PRIMARY_GH_DIR="${ACC_GH_DIR[$PRIMARY]}"
if [ -L ~/.config/gh ] || [ -e ~/.config/gh ]; then
  if [ -L ~/.config/gh ]; then
    rm ~/.config/gh
  elif [ -d ~/.config/gh ]; then
    log_warn "~/.config/gh ya existe como directorio (no symlink). Se reemplazara por symlink a la cuenta principal."
    rm -rf ~/.config/gh
  fi
fi
ln -sfn "$(basename "$PRIMARY_GH_DIR")" ~/.config/gh
log_ok "Symlink ~/.config/gh → $(basename "$PRIMARY_GH_DIR") (cuenta principal)"

# Autenticar cada cuenta
for i in "${!ACC_NAME[@]}"; do
  separator
  log_info "Autenticando cuenta: ${ACC_NAME[$i]} (${ACC_EMAIL[$i]})"
  log_info "Selecciona SSH como protocolo cuando se te pregunte."
  GH_CONFIG_DIR="${ACC_GH_DIR[$i]}" gh auth login
  chmod 600 "${ACC_GH_DIR[$i]}/hosts.yml" 2>/dev/null || true
done

# ── 8. Verificacion ──────────────────────────────────────────
separator
log_step "PASO 9: Verificacion rapida..."

echo ""
echo "OS: $OS"
echo ""
echo "Git identity por carpeta:"
for i in "${!ACC_NAME[@]}"; do
  DIR="${ACC_DIR[$i]}"
  if [ -d "$DIR" ]; then
    EMAIL_IN_DIR="$(cd "$DIR" && git config user.email 2>/dev/null || echo '(no repo, usa default)')"
    echo "  ${ACC_NAME[$i]}: $EMAIL_IN_DIR"
  fi
done

echo ""
echo "Default global (carpeta neutra):"
cd /tmp && echo "  user.email: $(git config user.email)"
echo "  signingkey: $(git config user.signingkey 2>/dev/null || echo '(none)')"
echo "  gpg.format: $(git config gpg.format)"

echo ""
echo "gh auth status por carpeta:"
for i in "${!ACC_NAME[@]}"; do
  DIR="${ACC_DIR[$i]}"
  GHDIR="${ACC_GH_DIR[$i]}"
  echo "  ${ACC_NAME[$i]}:"
  GH_CONFIG_DIR="$GHDIR" gh auth status 2>&1 | grep -E "Logged in|not logged" | sed 's/^/    /'
done

echo ""
echo "Default gh (sin direnv):"
gh auth status 2>&1 | grep -E "Logged in|not logged" | sed 's/^/  /'

echo ""
echo "Llaves en agente SSH:"
ssh-add -l 2>&1 | sed 's/^/  /'

echo ""
echo "allowed_signers:"
wc -l < "$ALLOWED" | xargs echo "  Lineas:"
cat "$ALLOWED" | awk '{print "    " $1}' | sort -u

# ── Resumen final ────────────────────────────────────────────
separator
log_ok "Configuracion completada."
echo ""
echo -e "${GREEN}Resumen:${NC}"
echo "  OS                  : $OS"
echo "  Cuentas configuradas: $ACC_COUNT"
echo "  Cuenta principal    : ${ACC_NAME[$PRIMARY]} (${ACC_EMAIL[$PRIMARY]})"
echo "  Firma principal     : ${ACC_SIGN_FORMAT[$PRIMARY]}"
echo ""
echo "Archivos generados/modificados:"
echo "  ~/.gitconfig"
for i in "${!ACC_NAME[@]}"; do
  [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && continue
  echo "  ~/.gitconfig-${ACC_NAME[$i]}"
done
echo "  ~/.ssh/config"
for i in "${!ACC_NAME[@]}"; do
  echo "  ${ACC_SSH_KEY[$i]} + .pub"
done
echo "  ~/.config/git/allowed_signers"
for i in "${!ACC_NAME[@]}"; do
  echo "  ${ACC_GH_DIR[$i]}/"
  [ "${ACC_IS_PRIMARY[$i]}" = "1" ] && echo "  ~/.config/gh -> $(basename "${ACC_GH_DIR[$i]}") (symlink)"
  [ "${ACC_IS_PRIMARY[$i]}" = "0" ] && echo "  ${ACC_DIR[$i]}/.envrc"
done
echo ""
log_warn "Pendientes manuales:"
echo "  1. Carga las llaves .pub en GitHub (Settings → SSH and GPG keys)"
echo "     — marcalas como 'Signing Key' ademas de 'Authentication Key' para firma SSH"
if [ "${ACC_SIGN_FORMAT[$PRIMARY]}" = "openpgp" ] && [ -n "${ACC_GPG_KEYID[$PRIMARY]}" ]; then
  echo "  2. Subi la clave GPG pública: gpg --armor --export ${ACC_GPG_KEYID[$PRIMARY]} | pbcopy"
  echo "     → Settings → SSH and GPG keys → New GPG key"
  echo "  3. Reinicia tu terminal o corre: source ~/.${SHELL_NAME}rc"
else
  echo "  2. Reinicia tu terminal o corre: source ~/.${SHELL_NAME}rc"
fi
echo ""
echo "  Verifica el aislamiento:"
for i in "${!ACC_NAME[@]}"; do
  echo "    cd ${ACC_DIR[$i]} && gh auth status && git config user.email"
done
echo ""
log_ok "Listo. Tu entorno esta aislado y endurecido."
