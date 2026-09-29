#!/data/data/com.termux/files/usr/bin/bash
set -e
set +o history
export HISTFILE=/dev/null
ulimit -c 0 2>/dev/null || true

# Neutralizar sniffers de procesos o inspectores en pestañas paralelas
pkill -9 -u $(id -u) -f "inotifywait|strace|gdb|lldb|tcpdump" 2>/dev/null || true

# ==============================================================================
# Instalador Automatizado: VS Code Nativo + Termux-X11 Pro + Cloud Sentinel
# Repositorio: miguelguerra200022-sudo/termux-vscode-x11
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# 1. Verificar entorno Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] Error: Este instalador debe ejecutarse dentro de Termux.${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Paso 1 Obligatorio: Instalar utilidades iniciales (curl, openssl, git, python)
echo -e "${YELLOW}[*] Verificando e instalando utilidades de red y cifrado (curl, git, openssl, python)...${NC}"
export DEBIAN_FRONTEND=noninteractive
pkg install -y -o Dpkg::Options::="--force-confnew" curl openssl git python >/dev/null 2>&1 || true

# 2.1 Lanzar animación cinemática 3D de Code Stack Sh (saltable con cualquier tecla)
if [ -f "$SCRIPT_DIR/bin/code-stack-ascii" ]; then
    python3 "$SCRIPT_DIR/bin/code-stack-ascii" intro 2>/dev/null || true
fi

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  🚀 CODE STACK SH • Instalador Oficial del Sistema${NC}"
echo -e "${CYAN}     «La libertad de programar sin necesidad de una PC»${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# 3. Detectar Hardware Seal Inmutable de este celular
get_hardware_seal() {
    local mfg="$(getprop ro.product.manufacturer 2>/dev/null || uname -m)"
    local mdl="$(getprop ro.product.model 2>/dev/null || uname -n)"
    local soc="$(getprop ro.board.platform 2>/dev/null || uname -s)"
    local hw="$(getprop ro.boot.hardware 2>/dev/null || getprop ro.hardware 2>/dev/null || uname -m)"
    local bld="$(getprop ro.build.fingerprint 2>/dev/null || id -u)"
    local raw="${mfg}|${mdl}|${soc}|${hw}|${bld}"
    local hash=$(echo -n "$raw" | sha256sum | awk '{print $1}')
    local soc_clean=$(echo "$soc" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')
    local mdl_clean=$(echo "$mdl" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')
    echo "${soc_clean}-${mdl_clean}-${hash:0:8}"
}

SELLO_HARDWARE=$(get_hardware_seal)
LEADER_SEAL="ums9230-sp_6300-3724801c"

# Persistir sello de hardware en almacenamiento y configuración
mkdir -p "$HOME/.config/termux-vscode"
echo -n "$SELLO_HARDWARE" > "$HOME/.config/termux-vscode/.device_hw_seal" 2>/dev/null || true
if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
    echo -n "$SELLO_HARDWARE" > "/storage/emulated/0/.device_hw_seal" 2>/dev/null || true
fi

echo -e "${GREEN}[✓] Sello de Hardware físico detectado:${NC} ${BOLD}${SELLO_HARDWARE}${NC}"

# Inicializar broker de autenticación efímero temprano en $PREFIX/bin
if [ -f "$SCRIPT_DIR/bin/github-auth-broker" ]; then
    cp -f "$SCRIPT_DIR/bin/github-auth-broker" "$PREFIX/bin/github-auth-broker" 2>/dev/null || true
    chmod 755 "$PREFIX/bin/github-auth-broker" 2>/dev/null || true
fi

get_time_step() {
    echo $(( $(date +%s) / 30 ))
}

get_30s_seal_token() {
    local seal="$1"
    local step="${2:-$(get_time_step)}"
    github-auth-broker token-30s "$seal" "$step" 2>/dev/null || \
    python3 -c "import hashlib; print(hashlib.sha256(f'$seal:{step}'.encode()).hexdigest()[:16])" 2>/dev/null
}

# 4. Identificación de Dispositivo en Flota (Sin Límites de Nodos)
DEFAULT_USER="Usuario"
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    USERNAME="Miguel (Líder)"
    echo -e "${YELLOW}⭐ Dispositivo Líder identificado: ${BOLD}${USERNAME}${NC}"
elif [ -f "$SCRIPT_DIR/credenciales/$SELLO_HARDWARE/metadata.enc" ]; then
    # Reingreso ilimitado: dispositivo ya registrado previamente
    META_KEY=$(github-auth-broker session-key "$SELLO_HARDWARE" 2>/dev/null)
    EXISTING_NAME=$(PASS_KEY="$META_KEY" openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -in "$SCRIPT_DIR/credenciales/$SELLO_HARDWARE/metadata.enc" 2>/dev/null | grep -o '"username": *"[^"]*"' | cut -d'"' -f4 || true)
    USERNAME="${EXISTING_NAME:-Dispositivo de Flota}"
    echo -e "${YELLOW}📱 Dispositivo de Flota reconocido (Reingreso): ${BOLD}${USERNAME}${NC}"
else
    # Dispositivo nuevo: cálculo dinámico del slot Worker (sin límite numérico)
    WORKER_COUNT=$(find "$SCRIPT_DIR/credenciales" -mindepth 1 -maxdepth 1 -type d ! -name "$LEADER_SEAL" 2>/dev/null | wc -l)
    NEXT_INDEX=$(( WORKER_COUNT + 1 ))
    DEFAULT_USER="Miguel (Worker ${NEXT_INDEX})"
    echo -ne "${BOLD}👤 Nombre de usuario en Flota [${DEFAULT_USER}]: ${NC}"
    INPUT_USER=""
    if [ -e /dev/tty ]; then
        read -t 5 -r INPUT_USER < /dev/tty 2>/dev/null || true
    fi
    USERNAME="${INPUT_USER:-$DEFAULT_USER}"
    echo -e "${GREEN}[✓] Usuario registrado:${NC} ${USERNAME}"
fi

# 5. Pasarela de Autorización Sentinel (Telegram + Broker Criptográfico + Token 30s)
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    APPROVED=1
    echo -e "${GREEN}[✓] Dispositivo Líder verificado por Sello de Hardware inmutable.${NC}"
    echo -e "${GREEN}[✓] Acceso Maestro concedido automáticamente sin esperas.${NC}"
else
    TG_CREDS=$(github-auth-broker telegram-creds 2>/dev/null || echo "8835215357:AAG142javmyg8xPzx3Ad-Aj2ohqmBfMtvls|1514766577")
    BOT_TOKEN=$(echo "$TG_CREDS" | cut -d'|' -f1)
    CHAT_ID=$(echo "$TG_CREDS" | cut -d'|' -f2)

    REQ_TIME=$(date +%s)
    REQ_STEP=$(( REQ_TIME / 30 ))
    SIG_30S=$(get_30s_seal_token "$SELLO_HARDWARE" "$REQ_STEP")
    REQ_ID="${SELLO_HARDWARE}:${REQ_STEP}:${SIG_30S}"
    EXT_IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "127.0.0.1")
    MODEL_NAME="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            🔒 PASARELA DE AUTORIZACIÓN SENTINEL                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "🔒 Ingrese contraseña de autorización (o presione ENTER para Telegram): "
    INPUT_PASS=""
    if [ -e /dev/tty ]; then
        read -s INPUT_PASS < /dev/tty 2>/dev/null || true
    else
        read -s INPUT_PASS 2>/dev/null || true
    fi
    echo ""

    APPROVED=0
    if [ -n "$INPUT_PASS" ]; then
        if github-auth-broker verify-pass "$INPUT_PASS" 2>/dev/null; then
            APPROVED=1
            CURR_STEP=$(get_time_step)
            CURR_TOKEN=$(get_30s_seal_token "$SELLO_HARDWARE" "$CURR_STEP")
            echo -e "${GREEN}[✓] Contraseña verificada con éxito.${NC}"
            echo -e "${GREEN}[✓] Token Criptográfico Efímero validado (Ventana #${CURR_STEP}: ${CURR_TOKEN})${NC}"
            PASS_MSG="🔑 *ACCESO POR CONTRASEÑA DIRECTA*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n📱 *Modelo:* \`$MODEL_NAME\`\n🌐 *IP:* \`$EXT_IP\`\n⏰ *Ventana 30s:* \`#$CURR_STEP\`\n⚠️ *Autorizado por contraseña maestra en terminal.*"
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$PASS_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true
        else
            echo -e "${RED}[!] Contraseña incorrecta. Instalación abortada.${NC}"
            FAIL_MSG="🚨 *INTENTO DE ACCESO FALLIDO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n📱 *Modelo:* \`$MODEL_NAME\`\n🌐 *IP:* \`$EXT_IP\`\n❌ *Contraseña incorrecta ingresada en terminal.*"
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$FAIL_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true
            exit 1
        fi
    fi

    if [ "$APPROVED" -eq 0 ]; then
        echo -e "${CYAN}[*] Solicitando autorización de seguridad al bot de Telegram...${NC}"
        # Pausar temporalmente cloud-sentinel en otros nodos para asegurar exclusividad en getUpdates
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d "chat_id=$CHAT_ID&text=/sentinel_pause_50" >/dev/null 2>&1 || true

        sleep 1

        TG_MSG=$(cat << EOF_MSG
🛡️ *SOLICITUD DE AUTORIZACIÓN DE DISPOSITIVO*
━━━━━━━━━━━━━━━━━━━━━━━━━
👤 *Usuario:* \`${USERNAME}\`
🏷️ *Sello Hardware:* \`${SELLO_HARDWARE}\`
📱 *Modelo:* \`${MODEL_NAME}\`
🌐 *IP:* \`${EXT_IP}\`
🔐 *Token 30s:* \`#${REQ_STEP}\` (\`${SIG_30S}\`)
⏰ *Hora:* \`$(date '+%Y-%m-%d %H:%M:%S')\`
━━━━━━━━━━━━━━━━━━━━━━━━━
¿Deseas autorizar la instalación en este celular?
EOF_MSG
)

        TG_PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'chat_id': '$CHAT_ID',
    'text': sys.stdin.read(),
    'parse_mode': 'Markdown',
    'reply_markup': {
        'inline_keyboard': [
            [
                {'text': '✅ APROBAR ACCESO', 'callback_data': 'auth_approve:${REQ_ID}'},
                {'text': '❌ RECHAZAR', 'callback_data': 'auth_reject:${REQ_ID}'}
            ]
        ]
    }
}))
" <<< "$TG_MSG" 2>/dev/null || true)

        SENT_RES=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "$TG_PAYLOAD" 2>/dev/null || true)

        MSG_ID=$(echo "$SENT_RES" | python3 -c "import json, sys; print(json.load(sys.stdin).get('result', {}).get('message_id', ''))" 2>/dev/null || true)

        echo -e "${YELLOW}⏳ Esperando aprobación en Telegram (@CloudNodeSync_bot)...${NC}"
        echo -e "${GRAY}   👉 Pulsa [APROBAR ACCESO] en el chat de Telegram (Tienes 45s).${NC}"

        START_WAIT=$(date +%s)
        OFFSET=0

        while [ $(( $(date +%s) - START_WAIT )) -lt 45 ]; do
            sleep 2
            UPDATES=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=1" 2>/dev/null || true)
            
            POLL_DATA=$(echo "$UPDATES" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    max_id = 0
    decision = ''
    cb_id = ''
    for item in data.get('result', []):
        uid = item.get('update_id', 0)
        if uid > max_id:
            max_id = uid
        cb = item.get('callback_query', {})
        cb_data = cb.get('data', '')
        if cb_data.startswith('auth_approve') and '$SELLO_HARDWARE' in cb_data:
            decision = 'APPROVE'
            cb_id = cb.get('id', '')
        elif cb_data.startswith('auth_reject') and '$SELLO_HARDWARE' in cb_data:
            decision = 'REJECT'
            cb_id = cb.get('id', '')
    print(f'{max_id}|{decision}|{cb_id}')
except Exception:
    print('0||')
" 2>/dev/null || echo "0||")

            LATEST_UID=$(echo "$POLL_DATA" | cut -d'|' -f1)
            POLL_DECISION=$(echo "$POLL_DATA" | cut -d'|' -f2)
            CB_ID=$(echo "$POLL_DATA" | cut -d'|' -f3)

            if [ "$LATEST_UID" -gt 0 ]; then
                OFFSET=$(( LATEST_UID + 1 ))
            fi

            if [ "$POLL_DECISION" = "APPROVE" ]; then
                NOW_STEP=$(get_time_step)
                curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/answerCallbackQuery" -d "callback_query_id=${CB_ID}&text=Acceso Aprobado (Token 30s)" >/dev/null 2>&1 || true
                REVOKE_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'chat_id': '$CHAT_ID',
    'message_id': '$MSG_ID',
    'text': '✅ *DISPOSITIVO AUTORIZADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n🔐 *Token 30s:* \`Válido (#$NOW_STEP)\`\n⚡ *Estado:* Instalación autorizada y en curso.\n━━━━━━━━━━━━━━━━━━━━━━━━━\n⚠️ _¿Fue una aprobación accidental? Pulsa abajo para revocar y bloquear:_\n',
    'parse_mode': 'Markdown',
    'reply_markup': {
        'inline_keyboard': [
            [{'text': '🔴 REVOCAR ACCESO / BLOQUEAR', 'callback_data': 'revoke_$SELLO_HARDWARE'}]
        ]
    }
}))
" 2>/dev/null || true)
                curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/editMessageText" -H "Content-Type: application/json" -d "$REVOKE_PAYLOAD" >/dev/null 2>&1 || true
                APPROVED=1
                echo -e "${GREEN}[✓] ¡Acceso aprobado con éxito vía Telegram! (Token 30s confirmado)${NC}"
                break
            elif [ "$POLL_DECISION" = "REJECT" ]; then
                curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/answerCallbackQuery" -d "callback_query_id=${CB_ID}&text=Acceso Denegado" >/dev/null 2>&1 || true
                echo -e "${RED}[!] Solicitud rechazada por el administrador en Telegram.${NC}"
                exit 1
            fi
        done

        if [ "$APPROVED" -eq 0 ]; then
            echo -e "${RED}[!] Tiempo de espera agotado sin aprobación en Telegram.${NC}"
            echo -ne "🔒 Ingrese contraseña de autorización manual: "
            if [ -e /dev/tty ]; then
                read -s INPUT_PASS < /dev/tty 2>/dev/null || true
            else
                read -s INPUT_PASS 2>/dev/null || true
            fi
            echo ""
            if ! github-auth-broker verify-pass "$INPUT_PASS" 2>/dev/null; then
                echo -e "${RED}[!] Contraseña incorrecta. Instalación abortada.${NC}"
                FAIL_MSG="🚨 *INTENTO DE ACCESO FALLIDO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n📱 *Modelo:* \`$MODEL_NAME\`\n🌐 *IP:* \`$EXT_IP\`\n❌ *Contraseña incorrecta ingresada en terminal.*"
                curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$FAIL_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true
                exit 1
            fi
            CURR_STEP=$(get_time_step)
            echo -e "${GREEN}[✓] Contraseña correcta verificada (Ventana #${CURR_STEP}).${NC}"
        fi
    fi
fi

# 6. Permisos de almacenamiento en Android si no están concedidos
if [ ! -d "/storage/emulated/0" ] || ! ls "/storage/emulated/0" >/dev/null 2>&1; then
    echo -e "${YELLOW}[*] Solicitando permisos de almacenamiento a Android...${NC}"
    echo -e "${CYAN}[i] Pulsa 'PERMITIR' en la ventana emergente de tu pantalla para acceder a tus archivos.${NC}"
    termux-setup-storage || true
    for i in {1..15}; do
        if ls "/storage/emulated/0" >/dev/null 2>&1; then
            echo -e "${GREEN}[✓] Permiso de almacenamiento confirmado.${NC}"
            if [ -w "/storage/emulated/0" ]; then
                echo -n "$SELLO_HARDWARE" > "/storage/emulated/0/.device_hw_seal" 2>/dev/null || true
            fi
            break
        fi
        sleep 1
    done
fi

# 7. Actualizar repositorios e instalar paquetes
echo -e "${YELLOW}[*] Buscando y actualizando paquetes a su última versión disponible...${NC}"
export DEBIAN_FRONTEND=noninteractive
PKG_INSTALL_CMD="pkg update -y && pkg upgrade -y -o Dpkg::Options::=\"--force-confnew\" && pkg install -y x11-repo && pkg install -y -o Dpkg::Options::=\"--force-confnew\" termux-x11-nightly code-oss code-is-code-oss openbox tint2 pcmanfm zen-browser rsync dbus aria2 pulseaudio termux-tools git cloudflared termux-api unzip inotify-tools openssl python jq clang shellcheck ruff feh mpv"

if [ -f "$SCRIPT_DIR/bin/code-stack-ascii" ]; then
    python3 "$SCRIPT_DIR/bin/code-stack-ascii" run --title "SISTEMA BASE // X11 + OPENBOX + UTILIDADES" -- "$PKG_INSTALL_CMD"
else
    eval "$PKG_INSTALL_CMD"
fi

# 8. Detección Inteligente e Instalación de APKs (X11 y Widget)
echo -e "${YELLOW}[*] Comprobando complementos gráficos de Android (Termux:X11 y Termux:Widget)...${NC}"
APK_DIR="/storage/emulated/0/Download"
if [ ! -w "/storage/emulated/0" ] || ! mkdir -p "$APK_DIR" 2>/dev/null; then
    APK_DIR="$HOME/Downloads"
    mkdir -p "$APK_DIR" 2>/dev/null || true
fi
CONFIG_DIR="$HOME/.config/termux-vscode"
mkdir -p "$CONFIG_DIR"
UNKNOWN_SOURCES_FLAG="$CONFIG_DIR/.unknown_sources_configured"
APK_X11_PATH="$APK_DIR/termux-x11-universal-debug.apk"
APK_WIDGET_PATH="$APK_DIR/termux-widget.apk"

is_package_installed() {
    local pkg="$1"
    local out
    out=$(ls -d "/data/data/$pkg" 2>&1 || true)
    if [[ "$out" == *"Permission denied"* ]] || [ -d "/data/data/$pkg" ]; then
        return 0
    else
        return 1
    fi
}

ensure_unknown_sources_permission() {
    if is_package_installed "com.termux.x11" && is_package_installed "com.termux.widget"; then
        return 0
    fi
    if [ -f "$UNKNOWN_SOURCES_FLAG" ]; then
        return 0
    fi
    echo -e "${YELLOW}[!] Android requiere autorizar a Termux para instalar aplicaciones desconocidas.${NC}"
    echo -e "${CYAN}[*] Abriendo Ajustes de Android para Termux...${NC}"
    echo -e "${YELLOW}[i] Activa la casilla 'Permitir desde esta fuente' y regresa a Termux.${NC}"
    am start -a android.settings.MANAGE_UNKNOWN_APP_SOURCES -d "package:com.termux" >/dev/null 2>&1 || true
    touch "$UNKNOWN_SOURCES_FLAG"
    sleep 3
}

auto_install_apk() {
    local file="$1"
    local name="$2"
    local pkg="$3"

    if is_package_installed "$pkg"; then
        echo -e "${GREEN}[✓] ${name} ya se encuentra instalado.${NC}"
        return 0
    fi

    if [ -f "$file" ]; then
        echo -e "${GREEN}[+] Iniciando instalación de ${name}...${NC}"
        if command -v su >/dev/null 2>&1 && su -c "id" >/dev/null 2>&1; then
            su -c "pm install -r \"$file\"" >/dev/null 2>&1 || true
        elif command -v rish >/dev/null 2>&1; then
            rish -c "pm install -r \"$file\"" >/dev/null 2>&1 || true
        else
            termux-open --content-type "application/vnd.android.package-archive" --view "$file" >/dev/null 2>&1 || \
            termux-open "$file" >/dev/null 2>&1 || true
        fi
        sleep 2
    fi
}

LATEST_X11_URL=$(curl -s "https://api.github.com/repos/termux/termux-x11/releases" 2>/dev/null | grep -o 'https://github.com/termux/termux-x11/releases/download/[^"]*universal-debug\.apk' | head -n 1)
[ -z "$LATEST_X11_URL" ] && LATEST_X11_URL="https://github.com/termux/termux-x11/releases/download/nightly/termux-x11-universal-debug.apk"

LATEST_WIDGET_URL=$(curl -s "https://api.github.com/repos/termux/termux-widget/releases/latest" 2>/dev/null | grep -o 'https://github.com/termux/termux-widget/releases/download/[^"]*\.apk' | head -n 1)
[ -z "$LATEST_WIDGET_URL" ] && LATEST_WIDGET_URL="https://github.com/termux/termux-widget/releases/download/v0.15.0/termux-widget-app_v0.15.0%2Bgithub.debug.apk"

ensure_unknown_sources_permission

if ! is_package_installed "com.termux.x11"; then
    echo -e "${CYAN}[*] Descargando Termux:X11 APK...${NC}"
    curl -sSL "$LATEST_X11_URL" -o "$APK_X11_PATH" 2>/dev/null || true
    auto_install_apk "$APK_X11_PATH" "Termux:X11" "com.termux.x11"
else
    echo -e "${GREEN}[✓] Termux:X11 ya se encuentra instalado.${NC}"
fi

if ! is_package_installed "com.termux.widget"; then
    echo -e "${CYAN}[*] Descargando Termux:Widget APK...${NC}"
    curl -sSL "$LATEST_WIDGET_URL" -o "$APK_WIDGET_PATH" 2>/dev/null || true
    auto_install_apk "$APK_WIDGET_PATH" "Termux:Widget" "com.termux.widget"
else
    echo -e "${GREEN}[✓] Termux:Widget ya se encuentra instalado.${NC}"
fi

# 9. Localización Universal del Repositorio y Sanitización Cero-Rastros
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
mkdir -p "$HOME/.config/termux-vscode"

if [ ! -d "$SCRIPT_DIR/.git" ]; then
    SCRIPT_DIR="$HOME/termux-vscode-x11"
    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        echo -e "${YELLOW}[*] Clonando repositorio central...${NC}"
        git clone --depth 1 "https://github.com/miguelguerra200022-sudo/termux-vscode-x11.git" "$SCRIPT_DIR" 2>/dev/null || true
    fi
fi

if [ -d "$SCRIPT_DIR/.git" ]; then
    echo "$SCRIPT_DIR" > "$HOME/.config/termux-vscode/repo_path" 2>/dev/null || true
    CLEAN_REMOTE="https://github.com/miguelguerra200022-sudo/termux-vscode-x11.git"
    git -C "$SCRIPT_DIR" remote set-url origin "$CLEAN_REMOTE" 2>/dev/null || true
fi

# 10. Despliegue de scripts en $PREFIX/bin
echo -e "${YELLOW}[*] Instalando utilidades Pro en el sistema...${NC}"

SCRIPTS=(
    "encender"
    "apagar"
    "orientation-sentinel"
    "programas"
    "start-vscode"
    "stop-vscode"
    "share-port"
    "dev-info"
    "notify-done"
    "sync-vscode"
    "restore-vscode"
    "watcher-sync"
    "integrity-watchdog"
    "integrity-guard"
    "setup-swap"
    "set-marketplace"
    "fix-phantom-killer"
    "new-project"
    "start-vscode-web"
    "guia"
    "vscode"
    "toggle-touch-mode"
    "switch-identity"
    "cloud-sentinel"
    "flota"
    "termux-runner"
    "vault-logs"
    "gitops-sync"
    "desinstalar-vscode"
    "desinstalar"
    "fetch-app-icon"
    "code-stack-ascii"
    "github-auth-broker"
)

for s in "${SCRIPTS[@]}"; do
    rm -f "$PREFIX/bin/$s" 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    fi
    chmod +x "$PREFIX/bin/$s" 2>/dev/null || true
done
chmod 500 "$PREFIX/bin/integrity-guard" "$PREFIX/bin/integrity-watchdog" "$PREFIX/bin/watcher-sync" "$PREFIX/bin/github-auth-broker" 2>/dev/null || true

# Copiar activos multimedia y de animación ASCII
if [ -d "$SCRIPT_DIR/assets" ]; then
    mkdir -p "$PREFIX/share/code-stack-sh/assets"
    cp -r "$SCRIPT_DIR/assets/"* "$PREFIX/share/code-stack-sh/assets/" 2>/dev/null || true
fi

# Enlaces simbólicos de compatibilidad y accesos directos
ln -sf "$PREFIX/bin/encender" "$PREFIX/bin/vscode" 2>/dev/null || true
ln -sf "$PREFIX/bin/apagar" "$PREFIX/bin/stop-vscode" 2>/dev/null || true
ln -sf "$PREFIX/bin/encender" "$HOME/encender.sh" 2>/dev/null || true
ln -sf "$PREFIX/bin/apagar" "$HOME/apagar.sh" 2>/dev/null || true

# Widgets táctiles para Termux:Widget
mkdir -p "$HOME/.shortcuts"
cat << 'EOF_SHORTCUT_ON' > "$HOME/.shortcuts/Encender"
#!/data/data/com.termux/files/usr/bin/bash
encender
EOF_SHORTCUT_ON
chmod +x "$HOME/.shortcuts/Encender"

cat << 'EOF_SHORTCUT_OFF' > "$HOME/.shortcuts/Apagar"
#!/data/data/com.termux/files/usr/bin/bash
apagar
EOF_SHORTCUT_OFF
chmod +x "$HOME/.shortcuts/Apagar"

rm -f "$HOME/.shortcuts/VS-Code" "$HOME/.shortcuts/Cerrar-VS-Code" 2>/dev/null || true

# 11. Configuración de VS Code y Openbox
echo -e "${YELLOW}[*] Aplicando configuraciones de VS Code y Openbox...${NC}"
mkdir -p "$HOME/.config/Code - OSS/User" "$HOME/.vscode-oss" "$HOME/.config/openbox" "$HOME/.config/tint2"

[ -f "$SCRIPT_DIR/config/settings.json" ] && cp "$SCRIPT_DIR/config/settings.json" "$HOME/.config/Code - OSS/User/settings.json"
[ -f "$SCRIPT_DIR/config/argv.json" ] && cp "$SCRIPT_DIR/config/argv.json" "$HOME/.vscode-oss/argv.json"
[ -f "$SCRIPT_DIR/config/rc.xml" ] && cp "$SCRIPT_DIR/config/rc.xml" "$HOME/.config/openbox/rc.xml"
[ -f "$SCRIPT_DIR/config/menu.xml" ] && cp "$SCRIPT_DIR/config/menu.xml" "$HOME/.config/openbox/menu.xml"
[ -f "$SCRIPT_DIR/config/tint2rc" ] && cp "$SCRIPT_DIR/config/tint2rc" "$HOME/.config/tint2/tint2rc"
[ -f "$SCRIPT_DIR/config/tint2rc_vertical" ] && cp "$SCRIPT_DIR/config/tint2rc_vertical" "$HOME/.config/tint2/tint2rc_vertical" 2>/dev/null || true
[ -f "$SCRIPT_DIR/config/tint2rc_horizontal" ] && cp "$SCRIPT_DIR/config/tint2rc_horizontal" "$HOME/.config/tint2/tint2rc_horizontal" 2>/dev/null || true

# Fondos de pantalla adaptativos (Horizontal y Vertical)
mkdir -p "$HOME/.config/termux-vscode"
[ -f "$SCRIPT_DIR/data/wallpaper_horizontal.jpg" ] && cp "$SCRIPT_DIR/data/wallpaper_horizontal.jpg" "$HOME/.config/termux-vscode/wallpaper_horizontal.jpg" 2>/dev/null || true
[ -f "$SCRIPT_DIR/data/wallpaper_vertical.jpg" ] && cp "$SCRIPT_DIR/data/wallpaper_vertical.jpg" "$HOME/.config/termux-vscode/wallpaper_vertical.jpg" 2>/dev/null || true
[ -f "$SCRIPT_DIR/data/wallpaper.jpg" ] && cp "$SCRIPT_DIR/data/wallpaper.jpg" "$HOME/.config/termux-vscode/wallpaper.jpg" 2>/dev/null || true

# 12. Configurar Iconos Oficiales
echo -e "${YELLOW}[*] Instalando iconos oficiales...${NC}"
mkdir -p "$PREFIX/share/pixmaps" "$PREFIX/share/icons/hicolor/scalable/apps" "$PREFIX/share/applications"

if [ -d "$SCRIPT_DIR/data/icons" ]; then
    for size in 16 24 32 48 64 128 256; do
        mkdir -p "$PREFIX/share/icons/hicolor/${size}x${size}/apps"
        [ -f "$SCRIPT_DIR/data/icons/code-oss-${size}.png" ] && cp "$SCRIPT_DIR/data/icons/code-oss-${size}.png" "$PREFIX/share/icons/hicolor/${size}x${size}/apps/code-oss.png" 2>/dev/null || true
        [ -f "$SCRIPT_DIR/data/icons/com.visualstudio.code.oss-${size}.png" ] && cp "$SCRIPT_DIR/data/icons/com.visualstudio.code.oss-${size}.png" "$PREFIX/share/icons/hicolor/${size}x${size}/apps/com.visualstudio.code.oss.png" 2>/dev/null || true
        [ -f "$SCRIPT_DIR/data/icons/zen-browser-${size}.png" ] && cp "$SCRIPT_DIR/data/icons/zen-browser-${size}.png" "$PREFIX/share/icons/hicolor/${size}x${size}/apps/zen-browser.png" 2>/dev/null || true
        [ -f "$SCRIPT_DIR/data/icons/touch-toggle-${size}.png" ] && cp "$SCRIPT_DIR/data/icons/touch-toggle-${size}.png" "$PREFIX/share/icons/hicolor/${size}x${size}/apps/touch-toggle.png" 2>/dev/null || true
    done
    [ -f "$SCRIPT_DIR/data/icons/code-oss-48.png" ] && cp "$SCRIPT_DIR/data/icons/code-oss-48.png" "$PREFIX/share/pixmaps/code-oss.png" 2>/dev/null || true
    [ -f "$SCRIPT_DIR/data/icons/zen-browser-48.png" ] && cp "$SCRIPT_DIR/data/icons/zen-browser-48.png" "$PREFIX/share/pixmaps/zen-browser.png" 2>/dev/null || true
    [ -f "$SCRIPT_DIR/data/icons/touch-toggle-48.png" ] && cp "$SCRIPT_DIR/data/icons/touch-toggle-48.png" "$PREFIX/share/pixmaps/touch-toggle.png" 2>/dev/null || true
fi

if [ -f "$SCRIPT_DIR/data/applications/touch-toggle.desktop" ]; then
    cp "$SCRIPT_DIR/data/applications/touch-toggle.desktop" "$PREFIX/share/applications/touch-toggle.desktop" 2>/dev/null || true
fi

sed -i 's|^Icon=.*|Icon=/data/data/com.termux/files/usr/share/pixmaps/code-oss.png|g' "$PREFIX/share/applications/code-oss.desktop" 2>/dev/null || true
sed -i 's|^Icon=.*|Icon=/data/data/com.termux/files/usr/share/pixmaps/zen-browser.png|g' "$PREFIX/share/applications/zen-browser.desktop" 2>/dev/null || true
sed -i 's|^Icon=.*|Icon=/data/data/com.termux/files/usr/share/pixmaps/touch-toggle.png|g' "$PREFIX/share/applications/touch-toggle.desktop" 2>/dev/null || true
mkdir -p "$HOME/.local/share/applications" "$HOME/.icons"
cp -f "$PREFIX/share/applications/code-oss.desktop" "$PREFIX/share/applications/zen-browser.desktop" "$PREFIX/share/applications/touch-toggle.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true

# 13. Configuración de Bóveda Cifrada Local (Zero Texto Plano)
TARGET_FOLDER="credenciales/${SELLO_HARDWARE}"
mkdir -p "$SCRIPT_DIR/$TARGET_FOLDER"

ACTIVE_FILE="$HOME/.config/termux-vscode/active_identity"
echo "${SELLO_HARDWARE}" > "$ACTIVE_FILE"

# Si ya existe vault.enc para este mismo dispositivo (reingreso), se restaura
if [ -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ]; then
    echo -e "${CYAN}[*] Bóveda cifrada propia detectada. Restaurando configuración...${NC}"
    PASS_KEY="${AUTH_PASSWORD}_${SELLO_HARDWARE}" openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY \
        -in "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" 2>/dev/null | \
        tar -xzf - -C "$HOME/.config" 2>/dev/null || true
    echo -e "${GREEN}[✓] Cuentas y perfiles propios restaurados exitosamente en RAM.${NC}"
fi

# Generar metadata.enc propio si no existe
if [ ! -f "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc" ]; then
    echo -e "${YELLOW}[*] Registrando configuración de dispositivo local (Cero Texto Plano)...${NC}"
    META_RAW=$(cat << EOF_META
{
  "username": "${USERNAME}",
  "role": "$([ "$SELLO_HARDWARE" = "$LEADER_SEAL" ] && echo "Líder" || echo "Worker")",
  "is_master": $([ "$SELLO_HARDWARE" = "$LEADER_SEAL" ] && echo "true" || echo "false"),
  "device_seal": "${SELLO_HARDWARE}",
  "device_manufacturer": "$(getprop ro.product.manufacturer 2>/dev/null || echo 'Android')",
  "device_model": "${MODEL_NAME}",
  "soc": "$(getprop ro.board.platform 2>/dev/null || getprop ro.hardware 2>/dev/null || echo 'ARM64')",
  "android_version": "$(getprop ro.build.version.release 2>/dev/null || echo 'Android')",
  "accounts_limit": "unlimited",
  "accounts_count": "dynamic",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_sync": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "active"
}
EOF_META
    )
    PASS_KEY="$(github-auth-broker session-key "$SELLO_HARDWARE" 2>/dev/null)" openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -out "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc" <<< "$META_RAW"
fi

# Generar vault.enc propio si no existe (SIN copiar plantilla del Líder)
if [ ! -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ]; then
    mkdir -p "$HOME/.config/Code - OSS/User" "$HOME/.config/zen"
    PASS_KEY="$(github-auth-broker session-key "$SELLO_HARDWARE" 2>/dev/null)"
    tar -czf - \
        --exclude="cache2" \
        --exclude="startupCache" \
        --exclude="lock" \
        --exclude=".parentlock" \
        --exclude="Crash Reports" \
        --exclude="minidumps" \
        --exclude="*.tmp" \
        --exclude="*.log" \
        --exclude="*.sock" \
        -C "$HOME/.config" "Code - OSS/User" "zen" 2>/dev/null | \
        PASS_KEY="$PASS_KEY" openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -out "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" 2>/dev/null || true
fi

# Sincronizar credenciales cifradas hacia el directorio de configuración persistente
CONFIG_CREDS="$HOME/.config/termux-vscode/credenciales/$SELLO_HARDWARE"
mkdir -p "$CONFIG_CREDS"
[ -f "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc" ] && cp -f "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc" "$CONFIG_CREDS/metadata.enc" 2>/dev/null || true
[ -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ] && cp -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" "$CONFIG_CREDS/vault.enc" 2>/dev/null || true
chmod 600 "$CONFIG_CREDS"/* 2>/dev/null || true

# 14. Registro Dinámico en el Broker Criptográfico de Flota (Cero Tokens en Disco)
set +e
rm -f "$HOME/.config/termux-vscode/.auth_token"* 2>/dev/null || true
DEV_ROLE="$([ "$SELLO_HARDWARE" = "$LEADER_SEAL" ] && echo "Líder" || echo "Worker")"
github-auth-broker register "$SELLO_HARDWARE" "$DEV_ROLE" "$USERNAME" >/dev/null 2>&1 || true

# Registro en Cloudflare Edge Gateway si está configurado
GATEWAY_URL=""
[ -f "$HOME/.config/termux-vscode/gateway_url" ] && GATEWAY_URL=$(cat "$HOME/.config/termux-vscode/gateway_url" 2>/dev/null | tr -d '[:space:]')
if [ -n "$GATEWAY_URL" ]; then
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"seal\":\"$SELLO_HARDWARE\",\"username\":\"$USERNAME\",\"role\":\"$DEV_ROLE\",\"model\":\"$MODEL_NAME\"}" \
        "$GATEWAY_URL/api/v1/auth/register" >/dev/null 2>&1 || true
fi

# 15. Blindaje Criptográfico Anti-Tamper (Ed25519)
echo -e "${YELLOW}[*] Configurando firmas criptográficas Ed25519...${NC}"
mkdir -p "$HOME/.ssh" "$HOME/.config/git"
chmod 700 "$HOME/.ssh" "$HOME/.config/git" 2>/dev/null || true
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
fi
chmod 400 "$HOME/.ssh/id_ed25519" 2>/dev/null || true
PUBKEY=""
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    PUBKEY=$(cat "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true)
fi
if [ -n "$PUBKEY" ]; then
    rm -f "$HOME/.config/git/allowed_signers" 2>/dev/null || true
    echo "principal $PUBKEY" > "$HOME/.config/git/allowed_signers" 2>/dev/null || true
    chmod 400 "$HOME/.config/git/allowed_signers" 2>/dev/null || true
fi

git config --global user.name "Miguel Guerra" 2>/dev/null || true
git config --global user.email "miguelguerra200022@gmail.com" 2>/dev/null || true
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
    git config --global gpg.format ssh 2>/dev/null || true
    git config --global commit.gpgsign true 2>/dev/null || true
    git config --global gpg.ssh.allowedsignersfile "$HOME/.config/git/allowed_signers" 2>/dev/null || true
fi
git config --global core.askPass "github-auth-broker" 2>/dev/null || true

# 15.5 Compilación Nativa ELF para Nodos Worker (Blindaje Cero Código Fuente)
if [ "$SELLO_HARDWARE" != "$LEADER_SEAL" ]; then
    echo -e "${YELLOW}[*] Blindando ejecutables: Compilando binarios ELF ARM64 nativos...${NC}"
    if [ -f "$SCRIPT_DIR/bin/system-compiler" ]; then
        bash "$SCRIPT_DIR/bin/system-compiler" --all >/dev/null 2>&1 || true
    fi
    echo "$HOME/.config/termux-vscode" > "$HOME/.config/termux-vscode/repo_path" 2>/dev/null || true
fi

# 16. Bóveda Dorada (Golden Vault)
GOLDEN_DIR="$HOME/.config/termux-vscode/.golden"
mkdir -p "$GOLDEN_DIR"
for bin_name in "watcher-sync" "integrity-watchdog" "integrity-guard" "encender" "apagar" "start-vscode" "stop-vscode" "switch-identity" "cloud-sentinel" "flota" "github-auth-broker" "gitops-sync" "vault-logs"; do
    if [ -f "$PREFIX/bin/$bin_name" ]; then
        rm -f "$GOLDEN_DIR/$bin_name" 2>/dev/null || true
        cp -f "$PREFIX/bin/$bin_name" "$GOLDEN_DIR/$bin_name" 2>/dev/null || true
        chmod 500 "$GOLDEN_DIR/$bin_name" 2>/dev/null || true
    fi
done
rm -f "$GOLDEN_DIR/id_ed25519"* "$GOLDEN_DIR/allowed_signers" 2>/dev/null || true
cp -f "$HOME/.ssh/id_ed25519"* "$GOLDEN_DIR/" 2>/dev/null || true
[ -f "$HOME/.config/git/allowed_signers" ] && cp -f "$HOME/.config/git/allowed_signers" "$GOLDEN_DIR/" 2>/dev/null || true

# 17. Sellar integridad del repositorio
if command -v integrity-guard >/dev/null 2>&1; then
    integrity-guard sign "$SCRIPT_DIR" >/dev/null 2>&1 || true
fi

# 18. Arrancar Centinelas en Segundo Plano
pkill -f "integrity-watchdog" 2>/dev/null || true
pkill -f "watcher-sync" 2>/dev/null || true
setsid -f integrity-watchdog >/dev/null 2>&1 || true
setsid -f watcher-sync >/dev/null 2>&1 || true

# 19. Notificar éxito final a Telegram
FINAL_MSG="🚀 *DISPOSITIVO LISTO Y ACTIVADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello:* \`$SELLO_HARDWARE\`\n🌐 *IP:* \`$EXT_IP\`\n✅ Entorno VS Code activo y sincronizado en la flota."
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$FINAL_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true

# 20. Limpieza Absoluta de Historial (Cero Rastros)
history -c && history -w 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
echo -e "${CYAN}  Dispositivo: ${USERNAME} (${SELLO_HARDWARE})${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
echo -e "Comandos principales del sistema:"
echo -e "  ${YELLOW}encender${NC}        (Lanza tu entorno de desarrollo y proyectos)"
echo -e "  ${YELLOW}apagar${NC}          (Cierra el entorno y apaga servicios)"
echo -e "  ${YELLOW}desinstalar${NC}     (Desinstala completamente el entorno)"
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    echo -e "  ${YELLOW}switch-identity${NC} (Conmutador exclusivo de la flota de celulares)"
fi
echo ""
echo -e "${CYAN}🚀 Iniciando Code Stack Sh automáticamente en 2 segundos...${NC}"
echo -e "${GRAY}(Si deseas salir a la consola, presiona Ctrl+C ahora)${NC}"
sleep 2

if [ -e /dev/tty ]; then
    if command -v encender >/dev/null 2>&1; then
        exec encender < /dev/tty > /dev/tty 2>&1
    elif [ -f "$PREFIX/bin/encender" ]; then
        exec "$PREFIX/bin/encender" < /dev/tty > /dev/tty 2>&1
    fi
else
    if command -v encender >/dev/null 2>&1; then
        exec encender
    elif [ -f "$PREFIX/bin/encender" ]; then
        exec "$PREFIX/bin/encender"
    fi
fi
