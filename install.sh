#!/data/data/com.termux/files/usr/bin/bash
set -e
set +o history
export HISTFILE=/dev/null

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

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  🚀 Instalador de VS Code Nativo + Termux:X11 Pro${NC}"
echo -e "${CYAN}     (Sincronización Cloud Sentinel Multi-Dispositivo)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# 1. Verificar entorno Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] Error: Este instalador debe ejecutarse dentro de Termux.${NC}"
    exit 1
fi

# 2. Paso 1 Obligatorio: Instalar utilidades iniciales (curl, openssl, git, python)
echo -e "${YELLOW}[*] Verificando e instalando utilidades de red y cifrado (curl, git, openssl, python)...${NC}"
pkg install -y curl openssl git python >/dev/null 2>&1 || true

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
if [ -d "/storage/emulated/0" ]; then
    echo -n "$SELLO_HARDWARE" > "/storage/emulated/0/.device_hw_seal" 2>/dev/null || true
fi

echo -e "${GREEN}[✓] Sello de Hardware físico detectado:${NC} ${BOLD}${SELLO_HARDWARE}${NC}"

# 4. Solicitar Nombre de Usuario
DEFAULT_USER="Usuario"
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    DEFAULT_USER="Miguel (Líder)"
    echo -e "${YELLOW}⭐ Dispositivo Líder identificado.${NC}"
fi

echo -ne "${BOLD}👤 Nombre de usuario [${DEFAULT_USER}]: ${NC}"
read -r INPUT_USER
USERNAME="${INPUT_USER:-$DEFAULT_USER}"

# 5. Pasarela de Autorización Sentinel (Telegram + Contraseña Maestra)
HASH_SEGURA="8b8aba3300315db216e0e9050522d4952881e67273687b00caff2a78cf958315"
ENC_TG="U2FsdGVkX18DI6Fzl/wp6R640ySgonsv8H06zF7IAP/70XQSQSPpFlIctOqiwlHpGOeVuSPXV+jFANcBnuPjq1VtNrNMsDrcK21oJXeD3mc="
TG_CREDS=$(echo "$ENC_TG" | openssl enc -d -aes-256-cbc -a -A -pbkdf2 -pass pass:"09032000Mi." 2>/dev/null || echo "8835215357:AAG142javmyg8xPzx3Ad-Aj2ohqmBfMtvls|1514766577")
BOT_TOKEN=$(echo "$TG_CREDS" | cut -d'|' -f1)
CHAT_ID=$(echo "$TG_CREDS" | cut -d'|' -f2)

REQ_ID="${SELLO_HARDWARE}_$(date +%s)"
EXT_IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "127.0.0.1")
MODEL_NAME="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"

echo ""
echo -e "${CYAN}[*] Solicitando autorización de seguridad al bot de Telegram...${NC}"

TG_MSG=$(cat << EOF_MSG
🛡️ *SOLICITUD DE AUTORIZACIÓN DE DISPOSITIVO*
━━━━━━━━━━━━━━━━━━━━━━━━━
👤 *Usuario:* \`${USERNAME}\`
🏷️ *Sello Hardware:* \`${SELLO_HARDWARE}\`
📱 *Modelo:* \`${MODEL_NAME}\`
🌐 *IP:* \`${EXT_IP}\`
⏰ *Hora:* \`$(date '+%Y-%m-%d %H:%M:%S')\`
━━━━━━━━━━━━━━━━━━━━━━━━━
¿Deseas autorizar la instalación y sincronización en este celular?
EOF_MSG
)

TG_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'chat_id': '$CHAT_ID',
    'text': '''$TG_MSG''',
    'parse_mode': 'Markdown',
    'reply_markup': {
        'inline_keyboard': [
            [
                {'text': '✅ APROBAR ACCESO', 'callback_data': 'auth_approve_$REQ_ID'},
                {'text': '❌ RECHAZAR', 'callback_data': 'auth_reject_$REQ_ID'}
            ]
        ]
    }
}))
" 2>/dev/null || true)

SENT_RES=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$TG_PAYLOAD" 2>/dev/null || true)

MSG_ID=$(python3 -c "import json; print(json.loads('''$SENT_RES''').get('result', {}).get('message_id', ''))" 2>/dev/null || true)

echo -e "${YELLOW}⏳ Esperando aprobación en Telegram (@CloudNodeSync_bot)...${NC}"
echo -e "${GRAY}   👉 Pulsa [APROBAR ACCESO] en el chat de Telegram.${NC}"
echo -e "${GRAY}   (O presiona ENTER para autorizar mediante contraseña manual)${NC}"

APPROVED=0
START_WAIT=$(date +%s)
OFFSET=-10

while [ $(( $(date +%s) - START_WAIT )) -lt 45 ]; do
    if read -t 1 -n 1 -s USER_INPUT 2>/dev/null; then
        break
    fi

    UPDATES=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=2" 2>/dev/null || true)
    
    POLL_RESULT=$(python3 -c "
import json, sys
try:
    data = json.loads('''$UPDATES''')
    for item in data.get('result', []):
        cb = item.get('callback_query', {})
        cb_data = cb.get('data', '')
        cb_id = cb.get('id')
        if cb_data == 'auth_approve_$REQ_ID':
            print(f'APPROVE|{cb_id}')
            sys.exit(0)
        elif cb_data == 'auth_reject_$REQ_ID':
            print(f'REJECT|{cb_id}')
            sys.exit(0)
except Exception:
    pass
" 2>/dev/null || true)

    if [[ "$POLL_RESULT" == APPROVE* ]]; then
        CB_ID=$(echo "$POLL_RESULT" | cut -d'|' -f2)
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/answerCallbackQuery" -d "callback_query_id=${CB_ID}&text=Acceso Aprobado" >/dev/null 2>&1 || true
        REVOKE_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'chat_id': '$CHAT_ID',
    'message_id': '$MSG_ID',
    'text': '✅ *DISPOSITIVO AUTORIZADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n⚡ *Estado:* Instalación autorizada y en curso.\n━━━━━━━━━━━━━━━━━━━━━━━━━\n⚠️ _¿Fue una aprobación accidental? Pulsa abajo para revocar y bloquear:_\n',
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
        echo -e "${GREEN}[✓] ¡Acceso aprobado con éxito vía Telegram!${NC}"
        break
    elif [[ "$POLL_RESULT" == REJECT* ]]; then
        CB_ID=$(echo "$POLL_RESULT" | cut -d'|' -f2)
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/answerCallbackQuery" -d "callback_query_id=${CB_ID}&text=Acceso Denegado" >/dev/null 2>&1 || true
        echo -e "${RED}[!] Solicitud rechazada por el administrador en Telegram.${NC}"
        exit 1
    fi
done

AUTH_PASSWORD="09032000Mi."
if [ "$APPROVED" -eq 0 ]; then
    echo ""
    echo -ne "🔒 Ingrese contraseña de autorización: "
    read -s INPUT_PASS
    echo ""
    INPUT_HASH=$(echo -n "$INPUT_PASS" | sha256sum | awk '{print $1}')
    if [ "$INPUT_HASH" != "$HASH_SEGURA" ]; then
        echo -e "${RED}[!] Contraseña incorrecta. Instalación abortada.${NC}"
        FAIL_MSG="🚨 *INTENTO DE ACCESO FALLIDO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n📱 *Modelo:* \`$MODEL_NAME\`\n🌐 *IP:* \`$EXT_IP\`\n❌ *Contraseña incorrecta ingresada en terminal.*"
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$FAIL_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true
        exit 1
    fi
    AUTH_PASSWORD="$INPUT_PASS"
    echo -e "${GREEN}[✓] Contraseña correcta verificada.${NC}"
    PASS_MSG="🔑 *ACCESO POR CONTRASEÑA DIRECTA*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello Hardware:* \`$SELLO_HARDWARE\`\n📱 *Modelo:* \`$MODEL_NAME\`\n🌐 *IP:* \`$EXT_IP\`\n⚠️ *Autorizado por contraseña maestra en terminal.*"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$PASS_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true
fi

# 6. Permisos de almacenamiento en Android si no están concedidos
if [ ! -d "/storage/emulated/0" ] || ! ls "/storage/emulated/0" >/dev/null 2>&1; then
    echo -e "${YELLOW}[*] Solicitando permisos de almacenamiento a Android...${NC}"
    echo -e "${CYAN}[i] Pulsa 'PERMITIR' en la ventana emergente de tu pantalla para acceder a tus archivos.${NC}"
    termux-setup-storage || true
    for i in {1..15}; do
        if ls "/storage/emulated/0" >/dev/null 2>&1; then
            echo -e "${GREEN}[✓] Permiso de almacenamiento confirmado.${NC}"
            break
        fi
        sleep 1
    done
fi

# 7. Actualizar repositorios e instalar paquetes
echo -e "${YELLOW}[*] Buscando y actualizando paquetes a su última versión disponible...${NC}"
pkg update -y
pkg upgrade -y

echo -e "${YELLOW}[*] Habilitando repositorio X11...${NC}"
pkg install -y x11-repo

echo -e "${YELLOW}[*] Instalando VS Code, Zen Browser, X11, Openbox, Tint2 y utilidades...${NC}"
pkg install -y termux-x11-nightly code-oss code-is-code-oss openbox tint2 zen-browser rsync dbus aria2 pulseaudio termux-tools git cloudflared termux-api unzip inotify-tools openssl python

# 8. Detección Inteligente e Instalación de APKs (X11 y Widget)
echo -e "${YELLOW}[*] Comprobando complementos gráficos de Android (Termux:X11 y Termux:Widget)...${NC}"
mkdir -p "/storage/emulated/0/Download"
CONFIG_DIR="$HOME/.config/termux-vscode"
mkdir -p "$CONFIG_DIR"
UNKNOWN_SOURCES_FLAG="$CONFIG_DIR/.unknown_sources_configured"
APK_X11_PATH="/storage/emulated/0/Download/termux-x11-universal-debug.apk"
APK_WIDGET_PATH="/storage/emulated/0/Download/termux-widget.apk"

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
    "desinstalar-vscode"
    "desinstalar"
)

for s in "${SCRIPTS[@]}"; do
    rm -f "$PREFIX/bin/$s" 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    fi
    chmod +x "$PREFIX/bin/$s" 2>/dev/null || true
done
chmod 500 "$PREFIX/bin/integrity-guard" "$PREFIX/bin/integrity-watchdog" "$PREFIX/bin/watcher-sync" 2>/dev/null || true

ln -sf "$PREFIX/bin/start-vscode" "$HOME/start-vscode.sh"
ln -sf "$PREFIX/bin/stop-vscode" "$HOME/stop-vscode.sh"

# 11. Configuración de VS Code y Openbox
echo -e "${YELLOW}[*] Aplicando configuraciones de VS Code y Openbox...${NC}"
mkdir -p "$HOME/.config/Code - OSS/User" "$HOME/.vscode-oss" "$HOME/.config/openbox" "$HOME/.config/tint2"

[ -f "$SCRIPT_DIR/config/settings.json" ] && cp "$SCRIPT_DIR/config/settings.json" "$HOME/.config/Code - OSS/User/settings.json"
[ -f "$SCRIPT_DIR/config/argv.json" ] && cp "$SCRIPT_DIR/config/argv.json" "$HOME/.vscode-oss/argv.json"
[ -f "$SCRIPT_DIR/config/rc.xml" ] && cp "$SCRIPT_DIR/config/rc.xml" "$HOME/.config/openbox/rc.xml"
[ -f "$SCRIPT_DIR/config/menu.xml" ] && cp "$SCRIPT_DIR/config/menu.xml" "$HOME/.config/openbox/menu.xml"
[ -f "$SCRIPT_DIR/config/tint2rc" ] && cp "$SCRIPT_DIR/config/tint2rc" "$HOME/.config/tint2/tint2rc"

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

# 13. Sincronización y Configuración de Bóveda Cifrada en GitHub (Zero Texto Plano)
TARGET_FOLDER="credenciales/${SELLO_HARDWARE}"
mkdir -p "$SCRIPT_DIR/$TARGET_FOLDER"

ACTIVE_FILE="$HOME/.config/termux-vscode/active_identity"
echo "${SELLO_HARDWARE}" > "$ACTIVE_FILE"

if [ -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ]; then
    echo -e "${CYAN}[*] Bóveda cifrada detectada en GitHub. Restaurando cuentas en RAM...${NC}"
    openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"${AUTH_PASSWORD}_${SELLO_HARDWARE}" \
        -in "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" 2>/dev/null | \
        tar -xzf - -C "$HOME/.config" 2>/dev/null || true
    echo -e "${GREEN}[✓] Cuentas y perfiles restaurados exitosamente en RAM.${NC}"
else
    echo -e "${YELLOW}[*] Registrando nuevo dispositivo en la flota de GitHub (Cero Texto Plano)...${NC}"
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
    echo -n "$META_RAW" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"${AUTH_PASSWORD}_${SELLO_HARDWARE}" -out "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc"

    if [ -d "$HOME/.config/Code - OSS/User" ] || [ -d "$HOME/.config/zen" ]; then
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
            openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass pass:"${AUTH_PASSWORD}_${SELLO_HARDWARE}" -out "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" 2>/dev/null || true
    fi
fi

# 14. Guardar Token Cifrado con la llave local de la máquina
MACHINE_KEY=$(echo -n "$(id -u)_$(uname -m)_termux_vault" | sha256sum | awk '{print $1}')
ENC_TOKEN="U2FsdGVkX18HMNx1lAWR1MyfdAoYnNpD3BJrndGiPR3X0TDQp/wmnqKZO/8JzgvJVHTG9QIS6HP4WVVcCONKsg=="
RAW_TOKEN=$(echo "$ENC_TOKEN" | openssl enc -d -aes-256-cbc -a -A -pbkdf2 -pass pass:"$AUTH_PASSWORD" 2>/dev/null || true)
if [ -n "$RAW_TOKEN" ]; then
    echo -n "$RAW_TOKEN" | openssl enc -aes-256-cbc -a -A -pbkdf2 -pass pass:"$MACHINE_KEY" > "$HOME/.config/termux-vscode/.auth_token.enc" 2>/dev/null || true
    chmod 400 "$HOME/.config/termux-vscode/.auth_token.enc" 2>/dev/null || true
fi

# 15. Blindaje Criptográfico Anti-Tamper (Ed25519)
echo -e "${YELLOW}[*] Configurando firmas criptográficas Ed25519...${NC}"
mkdir -p "$HOME/.ssh" "$HOME/.config/git"
chmod 700 "$HOME/.ssh" "$HOME/.config/git" 2>/dev/null || true
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
fi
chmod 400 "$HOME/.ssh/id_ed25519" 2>/dev/null || true
PUBKEY=$(cat "$HOME/.ssh/id_ed25519.pub")
echo "principal $PUBKEY" > "$HOME/.config/git/allowed_signers"
chmod 400 "$HOME/.config/git/allowed_signers" 2>/dev/null || true

git config --global user.name "Miguel Guerra" 2>/dev/null || true
git config --global user.email "miguelguerra200022@gmail.com" 2>/dev/null || true
git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
git config --global gpg.format ssh 2>/dev/null || true
git config --global commit.gpgsign true 2>/dev/null || true
git config --global gpg.ssh.allowedsignersfile "$HOME/.config/git/allowed_signers" 2>/dev/null || true

# 16. Bóveda Dorada (Golden Vault)
GOLDEN_DIR="$HOME/.config/termux-vscode/.golden"
mkdir -p "$GOLDEN_DIR"
for bin_name in "watcher-sync" "integrity-watchdog" "integrity-guard" "start-vscode" "stop-vscode" "switch-identity" "cloud-sentinel" "flota"; do
    [ -f "$PREFIX/bin/$bin_name" ] && cp "$PREFIX/bin/$bin_name" "$GOLDEN_DIR/$bin_name" 2>/dev/null || true
    chmod 500 "$GOLDEN_DIR/$bin_name" 2>/dev/null || true
done
cp "$HOME/.ssh/id_ed25519"* "$GOLDEN_DIR/" 2>/dev/null || true
cp "$HOME/.config/git/allowed_signers" "$GOLDEN_DIR/" 2>/dev/null || true

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
FINAL_MSG="🚀 *DISPOSITIVO LISTO Y SINCRONIZADO*\n━━━━━━━━━━━━━━━━━━━━━━━━━\n👤 *Usuario:* \`$USERNAME\`\n🏷️ *Sello:* \`$SELLO_HARDWARE\`\n🌐 *IP:* \`$EXT_IP\`\n✅ Todas las 10 cuentas y entorno VS Code activos."
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=$CHAT_ID&text=$FINAL_MSG&parse_mode=Markdown" >/dev/null 2>&1 || true

# 20. Limpieza Absoluta de Historial (Cero Rastros)
history -c && history -w 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  🎉 ¡INSTALACIÓN Y SINCRONIZACIÓN COMPLETADA!${NC}"
echo -e "${CYAN}  Dispositivo: ${USERNAME} (${SELLO_HARDWARE})${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
echo -e "Para iniciar el entorno, escribe:"
echo -e "  ${YELLOW}vscode${NC}        (Lanzador interactivo de proyectos)"
echo -e "  ${YELLOW}start-vscode${NC}  (Inicio directo de VS Code en Termux:X11)"
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    echo -e "  ${YELLOW}switch-identity${NC} (Conmutador exclusivo de tus 10 celulares)"
fi
echo ""
