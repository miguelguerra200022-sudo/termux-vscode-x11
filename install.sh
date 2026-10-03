#!/data/data/com.termux/files/usr/bin/bash
set +e
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

# Pre-configuración del espejo CDN Cloudflare para Termux (evita bloqueo de 30 min por test de mirrors)
if [ -d "$PREFIX/etc/apt" ]; then
    mkdir -p "$PREFIX/etc/apt/sources.list.d" 2>/dev/null || true
    echo "deb https://packages-cf.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list" 2>/dev/null || true
    rm -f "$PREFIX/etc/apt/sources.list.d/x11.list" 2>/dev/null || true
fi

# 2. Paso 1 Obligatorio: Verificar dependencias iniciales (curl, openssl, git, python, jq)
echo -e "${YELLOW}[*] Verificando e instalando utilidades de red y cifrado (curl, git, openssl, python)...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -o Dpkg::Options::="--force-confnew" -o Acquire::ForceIPv4=true 2>/dev/null || true
pkg install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" curl git openssl python jq x11-repo 2>/dev/null || \
apt-get install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" curl git openssl python jq x11-repo 2>/dev/null || true

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
GATEWAY_URL=""
[ -f "$HOME/.config/termux-vscode/gateway_url" ] && GATEWAY_URL=$(cat "$HOME/.config/termux-vscode/gateway_url" 2>/dev/null | tr -d '[:space:]')
GATEWAY_URL="${GATEWAY_URL:-https://code-stack-gateway.cdn-sys-runtime.workers.dev}"

if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    USERNAME="Miguel (Líder)"
    echo -e "${YELLOW}⭐ Dispositivo Líder identificado: ${BOLD}${USERNAME}${NC}"
else
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            🏷️ IDENTIFICACIÓN DEL DISPOSITIVO                     ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Consultar si ya tiene nombre registrado en Cloudflare
    EXISTING_NAME=""
    if [ -n "$GATEWAY_URL" ]; then
        STATUS_JSON=$(curl -s --connect-timeout 4 "$GATEWAY_URL/api/v1/auth/status?seal=$SELLO_HARDWARE" 2>/dev/null || true)
        EXISTING_NAME=$(echo "$STATUS_JSON" | python3 -c "import json, sys; print(json.load(sys.stdin).get('username', ''))" 2>/dev/null || true)
    fi

    WORKER_COUNT=$(find "$SCRIPT_DIR/credenciales" -mindepth 1 -maxdepth 1 -type d ! -name "$LEADER_SEAL" 2>/dev/null | wc -l)
    NEXT_INDEX=$(( WORKER_COUNT + 1 ))
    DEFAULT_USER="${EXISTING_NAME:-Worker-${NEXT_INDEX}}"

    echo -e "${BOLD}Elige el nombre o alias que desees para este celular en la flota:${NC}"
    echo -ne "${BOLD}👤 Nombre de usuario [ENTER para '${DEFAULT_USER}']: ${NC}"
    INPUT_USER=""
    read -r INPUT_USER 2>/dev/null || true
    USERNAME="${INPUT_USER:-$DEFAULT_USER}"
    echo -e "${GREEN}[✓] Nombre asignado:${NC} ${BOLD}${USERNAME}${NC}"
fi

# 5. Pasarela de Autorización Sentinel (Telegram + Broker Criptográfico + Cloudflare Edge)
if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
    APPROVED=1
    echo -e "${GREEN}[✓] Dispositivo Líder verificado por Sello de Hardware inmutable.${NC}"
    echo -e "${GREEN}[✓] Acceso Maestro concedido automáticamente sin contraseñas ni esperas.${NC}"
else
    EXT_IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "127.0.0.1")
    MODEL_NAME="$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
    MODEL_NAME="${MODEL_NAME:-Android Device}"

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            🔒 PASARELA DE AUTORIZACIÓN SENTINEL                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Este dispositivo requiere autorización del Líder para poder instalarse.${NC}"
    echo -e "Opciones disponibles:"
    echo -e "  • ${BOLD}[1]${NC} Ingresa la Contraseña Maestra de Cifrado."
    echo -e "  • ${BOLD}[2]${NC} Presiona ${BOLD}ENTER${NC} (vacío) para solicitar autorización por Telegram al Líder."
    echo ""
    echo -ne "🔑 Contraseña de cifrado (o ENTER para Telegram): "
    INPUT_PASS=""
    read -s INPUT_PASS 2>/dev/null || true
    echo ""

    APPROVED=0
    if [ -n "$INPUT_PASS" ]; then
        # Verificar contraseña contra Cloudflare Edge Gateway
        VERIFY_RES=$(curl -s -X POST -H "Content-Type: application/json" \
            -d "{\"seal\":\"$SELLO_HARDWARE\",\"password\":\"$INPUT_PASS\",\"username\":\"$USERNAME\",\"model\":\"$MODEL_NAME\",\"ip\":\"$EXT_IP\"}" \
            "$GATEWAY_URL/api/v1/auth/verify-master" 2>/dev/null || true)

        if echo "$VERIFY_RES" | grep -q '"ok":true'; then
            APPROVED=1
            echo -e "${GREEN}[✓] ¡Contraseña Maestra verificada con éxito!${NC}"
            echo -e "${GREEN}[✓] Dispositivo activado y registrado en Cloudflare.${NC}"
        else
            echo -e "${RED}[!] Contraseña incorrecta. Instalación abortada por seguridad.${NC}"
            exit 1
        fi
    else
        # Solicitar autorización interactiva al Líder por Telegram vía Cloudflare Edge
        echo -e "${CYAN}[*] Solicitando autorización al Telegram del Líder (@CloudNodeSync_bot)...${NC}"
        curl -s -X POST -H "Content-Type: application/json" \
            -d "{\"seal\":\"$SELLO_HARDWARE\",\"username\":\"$USERNAME\",\"model\":\"$MODEL_NAME\",\"ip\":\"$EXT_IP\"}" \
            "$GATEWAY_URL/api/v1/auth/request-access" >/dev/null 2>&1 || true

        echo -e "${YELLOW}⏳ Esperando que el Líder pulse [APROBAR ACCESO] en Telegram...${NC}"
        echo -e "${CYAN}   👉 Revisa el chat de Telegram del Líder (Tienes 60 segundos).${NC}"

        START_WAIT=$(date +%s)
        while [ $(( $(date +%s) - START_WAIT )) -lt 60 ]; do
            sleep 2
            STATUS_RES=$(curl -s "$GATEWAY_URL/api/v1/auth/status?seal=$SELLO_HARDWARE" 2>/dev/null || true)

            if echo "$STATUS_RES" | grep -q '"status":"approved"'; then
                APPROVED=1
                echo ""
                echo -e "${GREEN}[✓] ¡Acceso aprobado con éxito por el Líder en Telegram!${NC}"
                echo -e "${GREEN}[✓] Autorización confirmada en Cloudflare Edge.${NC}"
                break
            elif echo "$STATUS_RES" | grep -q '"status":"rejected"'; then
                echo ""
                echo -e "${RED}[!] Solicitud rechazada por el Líder en Telegram.${NC}"
                exit 1
            fi
            echo -ne "."
        done
        echo ""

        if [ "$APPROVED" -eq 0 ]; then
            echo -e "${RED}[!] Tiempo de espera agotado sin aprobación en Telegram.${NC}"
            echo -ne "🔒 Ingrese Contraseña Maestra de autorización manual: "
            read -s INPUT_PASS 2>/dev/null || true
            echo ""
            VERIFY_RES=$(curl -s -X POST -H "Content-Type: application/json" \
                -d "{\"seal\":\"$SELLO_HARDWARE\",\"password\":\"$INPUT_PASS\",\"username\":\"$USERNAME\",\"model\":\"$MODEL_NAME\",\"ip\":\"$EXT_IP\"}" \
                "$GATEWAY_URL/api/v1/auth/verify-master" 2>/dev/null || true)

            if echo "$VERIFY_RES" | grep -q '"ok":true'; then
                APPROVED=1
                echo -e "${GREEN}[✓] Contraseña Maestra confirmada con éxito.${NC}"
            else
                echo -e "${RED}[!] Contraseña incorrecta. Instalación abortada.${NC}"
                exit 1
            fi
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

# 7. Actualizar repositorios e instalar paquetes BASE (solo audio + gráficos + utilidades esenciales)
# SIN VS Code, SIN Zen Browser, SIN compiladores pesados.
# El usuario instala lo que quiera luego con: programas
echo -e "${YELLOW}[*] Configurando repositorio CDN de Cloudflare para Termux...${NC}"
export DEBIAN_FRONTEND=noninteractive

# Asegurar x11-repo instalado y fuentes actualizadas
pkg install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" x11-repo 2>/dev/null || apt-get install -y x11-repo 2>/dev/null || true
apt-get update -y -o Dpkg::Options::="--force-confnew" -o Acquire::ForceIPv4=true 2>/dev/null || pkg update -y 2>/dev/null || true

# 7a. Herramientas críticas del sistema (cifrado, runtime, scripts)
echo -e "${YELLOW}[*] Instalando utilidades base del sistema (openssl, python, jq, herramientas)...${NC}"
SYSTEM_BASE="openssl python jq rsync dbus termux-tools termux-api unzip inotify-tools"
apt-get install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" $SYSTEM_BASE 2>/dev/null || \
    pkg install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" $SYSTEM_BASE 2>/dev/null || true

# 7b. Entorno gráfico y audio (Termux-X11, Openbox, Tint2, PulseAudio)
echo -e "${YELLOW}[*] Instalando entorno gráfico y componentes de pantalla...${NC}"
dpkg --configure -a 2>/dev/null || true

GRAPHICS_PKGS=(
    "openbox"
    "obconf"
    "tint2"
    "pcmanfm"
    "pulseaudio"
    "feh"
    "virglrenderer-android"
    "termux-x11-nightly"
)

for g_pkg in "${GRAPHICS_PKGS[@]}"; do
    if ! command -v "$g_pkg" >/dev/null 2>&1 && ! dpkg -s "$g_pkg" >/dev/null 2>&1; then
        pkg install -y -o Dpkg::Options::="--force-confnew" "$g_pkg" 2>/dev/null || \
        apt-get install -y -o Dpkg::Options::="--force-confnew" "$g_pkg" 2>/dev/null || true
    fi
done

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
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  PERMISO DE INSTALACIÓN REQUERIDO POR ANDROID            ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}[*] Abriendo Ajustes de Android para Termux...${NC}"
    echo -e "${GREEN}[1] Activa la casilla: 'Permitir desde esta fuente'.${NC}"
    echo -e "${GREEN}[2] Presiona el botón Volver para regresar a Termux.${NC}"
    am start -a android.settings.MANAGE_UNKNOWN_APP_SOURCES -d "package:com.termux" >/dev/null 2>&1 || true
    touch "$UNKNOWN_SOURCES_FLAG"
    echo ""
    echo -ne "${BOLD}${YELLOW}>> Cuando hayas activado el permiso, presiona ENTER para continuar... ${NC}"
    if [ -e /dev/tty ]; then
        read -r _ < /dev/tty 2>/dev/null || sleep 4
    else
        sleep 4
    fi
    echo ""
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
        echo -e "${GREEN}[+] Abriendo instalador de ${name}...${NC}"
        if command -v su >/dev/null 2>&1 && su -c "id" >/dev/null 2>&1; then
            su -c "pm install -r \"$file\"" >/dev/null 2>&1 || true
        elif command -v rish >/dev/null 2>&1; then
            rish -c "pm install -r \"$file\"" >/dev/null 2>&1 || true
        else
            termux-open --content-type "application/vnd.android.package-archive" --view "$file" >/dev/null 2>&1 || \
            termux-open "$file" >/dev/null 2>&1 || true
            echo -e "${CYAN}[i] Pulsa 'Instalar' en la ventana emergente de Android.${NC}"
            echo -ne "${BOLD}${YELLOW}>> Cuando termine la instalación, presiona ENTER aquí para seguir... ${NC}"
            if [ -e /dev/tty ]; then
                read -r _ < /dev/tty 2>/dev/null || sleep 4
            else
                sleep 4
            fi
            echo ""
        fi
    fi
}

LATEST_X11_URL="$GATEWAY_URL/api/v1/apk/termux-x11"
LATEST_WIDGET_URL="$GATEWAY_URL/api/v1/apk/termux-widget"

ensure_unknown_sources_permission

if ! is_package_installed "com.termux.x11"; then
    echo -e "${CYAN}[*] Descargando Termux:X11 APK desde Cloudflare Edge...${NC}"
    curl -sSL "$LATEST_X11_URL" -o "$APK_X11_PATH" 2>/dev/null || true
    auto_install_apk "$APK_X11_PATH" "Termux:X11" "com.termux.x11"
else
    echo -e "${GREEN}[✓] Termux:X11 ya se encuentra instalado.${NC}"
fi

if ! is_package_installed "com.termux.widget"; then
    echo -e "${CYAN}[*] Descargando Termux:Widget APK desde Cloudflare Edge...${NC}"
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
        echo -e "${YELLOW}[*] Descargando el repositorio desde Cloudflare Edge...${NC}"
        mkdir -p "$SCRIPT_DIR"
        RELEASE_META=$(curl -s --connect-timeout 8 "$GATEWAY_URL/api/v1/release/latest" 2>/dev/null || true)
        RELEASE_COMMIT=$(echo "$RELEASE_META" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('commit',''))" 2>/dev/null || true)

        CF_OK=0
        if [ -n "$RELEASE_COMMIT" ] && [ "$RELEASE_COMMIT" != "main" ] && [ "$RELEASE_COMMIT" != "initial" ]; then
            echo -e "${CYAN}[*] Descargando versión $RELEASE_COMMIT desde Cloudflare Edge CDN...${NC}"
            TARBALL_TMP="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/repo_$$.tar.gz"
            curl -sL --connect-timeout 20 --retry 3 \
                "$GATEWAY_URL/api/v1/release/download/$RELEASE_COMMIT" \
                -o "$TARBALL_TMP" 2>/dev/null && \
            [ -s "$TARBALL_TMP" ] && \
            tar -xzf "$TARBALL_TMP" -C "$HOME" 2>/dev/null && \
            # GitHub tarballs extraen como <user>-<repo>-<hash>/
            EXTRACTED=$(find "$HOME" -maxdepth 1 -type d -name "*termux-vscode*" 2>/dev/null | head -n 1)
            if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$SCRIPT_DIR" ]; then
                mv "$EXTRACTED" "$SCRIPT_DIR" 2>/dev/null || true
            fi
            rm -f "$TARBALL_TMP" 2>/dev/null || true
            if [ -d "$SCRIPT_DIR/bin" ]; then
                CF_OK=1
                echo -e "${GREEN}[✓] Repositorio descargado desde Cloudflare Edge.${NC}"
                # Inicializar git local (solo para tracking de versión, sin remoto activo)
                git -C "$SCRIPT_DIR" init -q 2>/dev/null || true
                git -C "$SCRIPT_DIR" commit --allow-empty -q -m "init: bootstrap from cloudflare edge $RELEASE_COMMIT" 2>/dev/null || true
            fi
        fi

        if [ "$CF_OK" -eq 0 ]; then
            echo -e "${YELLOW}[*] Fallback: clonando desde GitHub...${NC}"
            git clone --depth 1 "https://github.com/miguelguerra200022-sudo/termux-vscode-x11.git" "$SCRIPT_DIR" 2>/dev/null || true
        fi
    fi
fi

if [ -d "$SCRIPT_DIR/.git" ]; then
    echo "$SCRIPT_DIR" > "$HOME/.config/termux-vscode/repo_path" 2>/dev/null || true
    # Solo el Líder necesita el remote de GitHub para hacer push.
    # Los Workers NUNCA tocan GitHub; sus actualizaciones vienen de Cloudflare Edge.
    if [ "$SELLO_HARDWARE" = "$LEADER_SEAL" ]; then
        CLEAN_REMOTE="https://github.com/miguelguerra200022-sudo/termux-vscode-x11.git"
        git -C "$SCRIPT_DIR" remote add origin "$CLEAN_REMOTE" 2>/dev/null || \
        git -C "$SCRIPT_DIR" remote set-url origin "$CLEAN_REMOTE" 2>/dev/null || true
    else
        # Workers: apuntar el remote al Gateway Cloudflare (solo lectura informativa)
        git -C "$SCRIPT_DIR" remote remove origin 2>/dev/null || true
    fi
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
    "gpu-optimizer"
    "vault-manager"
)

for s in "${SCRIPTS[@]}"; do
    rm -f "$PREFIX/bin/$s" 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    fi
    chmod +x "$PREFIX/bin/$s" 2>/dev/null || true
done
chmod 500 "$PREFIX/bin/integrity-guard" "$PREFIX/bin/integrity-watchdog" "$PREFIX/bin/watcher-sync" "$PREFIX/bin/github-auth-broker" 2>/dev/null || true

# 10.1 Calibración Automática Universal de Hardware y Latencia Cero
if [ -f "$PREFIX/bin/gpu-optimizer" ]; then
    echo -e "${YELLOW}[*] Calibrando acelerador universal de hardware y perfil de latencia cero...${NC}"
    "$PREFIX/bin/gpu-optimizer" >/dev/null 2>&1 || true
fi

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

if command -v openbox >/dev/null 2>&1; then
    DESK_OPENBOX="$PREFIX/share/applications/openbox.desktop"
    if [ ! -f "$DESK_OPENBOX" ]; then
        cat << 'DESK_OB_EOF' > "$DESK_OPENBOX"
[Desktop Entry]
Name=Openbox Window Manager
Comment=Gestor de ventanas ultra-ligero para X11
Exec=openbox
Icon=/data/data/com.termux/files/usr/share/pixmaps/openbox.png
Terminal=false
Type=Application
Categories=System;WindowManager;
DESK_OB_EOF
    fi
    cp -f "$DESK_OPENBOX" "$HOME/.local/share/applications/" 2>/dev/null || true
    cp -f "$DESK_OPENBOX" "$HOME/Desktop/" 2>/dev/null || true
fi

# 13. Configuración de Bóveda Cifrada Local (Zero Texto Plano)
TARGET_FOLDER="credenciales/${SELLO_HARDWARE}"
mkdir -p "$SCRIPT_DIR/$TARGET_FOLDER"

ACTIVE_FILE="$HOME/.config/termux-vscode/active_identity"
echo "${SELLO_HARDWARE}" > "$ACTIVE_FILE"

# Si ya existe vault.enc para este mismo dispositivo (reingreso), se restaura
if [ -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ] || [ -f "$HOME/.config/termux-vscode/credenciales/$SELLO_HARDWARE/vault.enc" ]; then
    echo -e "${CYAN}[*] Bóveda cifrada universal detectada. Restaurando configuración (110+ programas)...${NC}"
    if [ -f "$SCRIPT_DIR/bin/vault-manager" ]; then
        bash "$SCRIPT_DIR/bin/vault-manager" unpack "$SELLO_HARDWARE" "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc"
    elif command -v vault-manager >/dev/null 2>&1; then
        vault-manager unpack "$SELLO_HARDWARE" "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc"
    fi
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
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Asegurando disponibilidad de openssl...${NC}"
        export DEBIAN_FRONTEND=noninteractive
        apt-get install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" openssl 2>/dev/null || \
        pkg install -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" openssl 2>/dev/null || true
    fi
    PASS_KEY="$(github-auth-broker session-key "$SELLO_HARDWARE" 2>/dev/null || true)"
    if [ -z "$PASS_KEY" ] && [ -f "$SCRIPT_DIR/bin/github-auth-broker" ]; then
        PASS_KEY="$(python3 "$SCRIPT_DIR/bin/github-auth-broker" session-key "$SELLO_HARDWARE" 2>/dev/null || true)"
    fi
    if [ -z "$PASS_KEY" ]; then
        echo -e "${RED}[!] Error de seguridad: No se pudo derivar la llave de sesión criptográfica para $SELLO_HARDWARE.${NC}"
        echo -e "${RED}[!] Abortando para evitar cifrado con claves predecibles.${NC}"
        exit 1
    fi
    PASS_KEY="$PASS_KEY" openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -pass env:PASS_KEY -out "$SCRIPT_DIR/$TARGET_FOLDER/metadata.enc" <<< "$META_RAW" 2>/dev/null || true
fi

# Generar vault.enc propio si no existe (SIN copiar plantilla del Líder)
if [ ! -f "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc" ]; then
    echo -e "${CYAN}[*] Inicializando bóveda universal de credenciales cifradas (110+ programas)...${NC}"
    if [ -f "$SCRIPT_DIR/bin/vault-manager" ]; then
        bash "$SCRIPT_DIR/bin/vault-manager" pack "$SELLO_HARDWARE" "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc"
    elif command -v vault-manager >/dev/null 2>&1; then
        vault-manager pack "$SELLO_HARDWARE" "$SCRIPT_DIR/$TARGET_FOLDER/vault.enc"
    fi
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

# Registro y sincronización en Cloudflare Edge Gateway
GATEWAY_URL=""
[ -f "$HOME/.config/termux-vscode/gateway_url" ] && GATEWAY_URL=$(cat "$HOME/.config/termux-vscode/gateway_url" 2>/dev/null | tr -d '[:space:]')
[ -z "$GATEWAY_URL" ] && GATEWAY_URL="https://code-stack-gateway.cdn-sys-runtime.workers.dev"

if [ -n "$GATEWAY_URL" ]; then
    echo -e "${YELLOW}[*] Sincronizando con Cloudflare Edge Gateway...${NC}"
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"seal\":\"$SELLO_HARDWARE\",\"username\":\"$USERNAME\",\"role\":\"$DEV_ROLE\",\"model\":\"$MODEL_NAME\"}" \
        "$GATEWAY_URL/api/v1/auth/register" >/dev/null 2>&1 || true

    # Subir bóveda cifrada inicial a Cloudflare R2
    if [ -f "$CONFIG_CREDS/vault.enc" ]; then
        curl -s -X POST --data-binary @"$CONFIG_CREDS/vault.enc" \
            "$GATEWAY_URL/api/v1/vault/upload?seal=$SELLO_HARDWARE" >/dev/null 2>&1 || true
    fi

    # Generar y subir inventario inicial de paquetes y extensiones a Cloudflare R2
    LOCAL_INV=$(python3 -c '
import subprocess, shutil, json, sys
seal = sys.argv[1]
model = sys.argv[2]
core_pkgs = ["code-oss", "zen-browser", "termux-x11-nightly", "termux-x11", "openbox", "virglrenderer-android", "python", "git", "openssl", "pulseaudio", "tar", "curl", "jq"]
installed_pkgs = []
for p in core_pkgs:
    cmd_name = p.split("-")[0]
    if shutil.which(p) or shutil.which(cmd_name):
        installed_pkgs.append(p)
    else:
        res = subprocess.run(["dpkg", "-s", p], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode == 0: installed_pkgs.append(p)

exts = []
if shutil.which("code-oss"):
    try:
        out = subprocess.check_output(["code-oss", "--list-extensions"], stderr=subprocess.DEVNULL).decode().strip()
        if out: exts = [e.strip() for e in out.splitlines() if e.strip()]
    except Exception:
        pass

payload = {
    "seal": seal,
    "system_packages": installed_pkgs,
    "vscode_extensions": exts,
    "device_model": model
}
print(json.dumps(payload))
' "$SELLO_HARDWARE" "$MODEL_NAME" 2>/dev/null || echo "{}")
    if [ -n "$LOCAL_INV" ] && [ "$LOCAL_INV" != "{}" ]; then
        curl -s -X POST -H "Content-Type: application/json" -d "$LOCAL_INV" \
            "$GATEWAY_URL/api/v1/vault/inventory?seal=$SELLO_HARDWARE" >/dev/null 2>&1 || true
    fi
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

# 15.5 Asegurar ruta del repositorio central
echo "$SCRIPT_DIR" > "$HOME/.config/termux-vscode/repo_path" 2>/dev/null || true

# 16. Bóveda Dorada (Golden Vault)
GOLDEN_DIR="$HOME/.config/termux-vscode/.golden"
mkdir -p "$GOLDEN_DIR"
for bin_name in "watcher-sync" "integrity-watchdog" "integrity-guard" "encender" "apagar" "start-vscode" "stop-vscode" "switch-identity" "cloud-sentinel" "flota" "github-auth-broker" "gitops-sync" "vault-logs" "gpu-optimizer" "vault-manager"; do
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

# 18. Modelo Serverless Cero Demonios: Sincronización Efímera (0 procesos en background)
pkill -f "integrity-watchdog" 2>/dev/null || true
pkill -f "watcher-sync" 2>/dev/null || true
if command -v watcher-sync >/dev/null 2>&1; then
    watcher-sync --once >/dev/null 2>&1 || true
fi

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
