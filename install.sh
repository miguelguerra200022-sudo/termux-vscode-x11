#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador Automatizado: VS Code Nativo + Termux-X11 (Android)
# Repositorio: miguelguerra200022-sudo/termux-vscode-x11
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  🚀 Instalador de VS Code Nativo + Termux:X11 Pro${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# 1. Verificar entorno Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[!] Error: Este instalador debe ejecutarse dentro de Termux.${NC}"
    exit 1
fi

# 2. Permisos de almacenamiento en Android si no están concedidos
if [ ! -d "/storage/emulated/0/Download" ]; then
    echo -e "${YELLOW}[*] Solicitando permisos de almacenamiento a Android...${NC}"
    termux-setup-storage || true
    sleep 2
fi

# 3. Actualizar repositorios e instalar paquetes necesarios
echo -e "${YELLOW}[*] Actualizando repositorios de Termux...${NC}"
pkg update -y

echo -e "${YELLOW}[*] Habilitando repositorio X11...${NC}"
pkg install -y x11-repo

echo -e "${YELLOW}[*] Instalando VS Code, X11, Openbox, Audio y utilidades Pro...${NC}"
pkg install -y termux-x11-nightly code-oss code-is-code-oss openbox dbus aria2 pulseaudio termux-tools git cloudflared termux-api

# 4. Descargar APK de Termux:X11 si no existe en Descargas
APK_PATH="/storage/emulated/0/Download/termux-x11-universal-debug.apk"
APK_URL="https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${YELLOW}[*] Descargando la aplicación Termux:X11 a Descargas...${NC}"
    aria2c -x 4 -s 4 -d "/storage/emulated/0/Download" -o "termux-x11-universal-debug.apk" "$APK_URL" || \
    curl -L "$APK_URL" -o "$APK_PATH" || true
    echo -e "${GREEN}[+] APK descargado en: ${APK_PATH}${NC}"
    echo -e "${YELLOW}[i] Si aún no tienes la app instalada, ábrela e instálala desde tu gestor de archivos o Descargas.${NC}"
else
    echo -e "${GREEN}[+] APK de Termux:X11 ya disponible en Descargas.${NC}"
fi

# 5. Obtener directorio del script (local o clonado)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
BASE_RAW="https://raw.githubusercontent.com/miguelguerra200022-sudo/termux-vscode-x11/main"

# 6. Crear y configurar scripts y comandos de desarrollo en $PREFIX/bin
echo -e "${YELLOW}[*] Instalando utilidades en el sistema (start-vscode, stop-vscode, share-port, dev-info, notify-done, sync-vscode, setup-swap)...${NC}"

SCRIPTS=("start-vscode" "stop-vscode" "share-port" "dev-info" "notify-done" "sync-vscode" "setup-swap")

for s in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    else
        curl -fsSL "$BASE_RAW/bin/$s" -o "$PREFIX/bin/$s"
    fi
    chmod +x "$PREFIX/bin/$s"
done

ln -sf "$PREFIX/bin/start-vscode" "$HOME/start-vscode.sh"
ln -sf "$PREFIX/bin/stop-vscode" "$HOME/stop-vscode.sh"

# 7. Configuración de VS Code (Sesión persistente, navegador móvil, hotExit)
echo -e "${YELLOW}[*] Aplicando configuraciones de VS Code...${NC}"
mkdir -p "$HOME/.config/Code - OSS/User"
mkdir -p "$HOME/.vscode-oss"

if [ -f "$SCRIPT_DIR/config/settings.json" ]; then
    cp "$SCRIPT_DIR/config/settings.json" "$HOME/.config/Code - OSS/User/settings.json"
    cp "$SCRIPT_DIR/config/argv.json" "$HOME/.vscode-oss/argv.json"
else
    curl -fsSL "$BASE_RAW/config/settings.json" -o "$HOME/.config/Code - OSS/User/settings.json"
    curl -fsSL "$BASE_RAW/config/argv.json" -o "$HOME/.vscode-oss/argv.json"
fi

# 8. Configuración de Openbox (Optimización de pantalla completa sin bordes)
echo -e "${YELLOW}[*] Configurando gestor de ventanas Openbox para pantallas táctiles...${NC}"
mkdir -p "$HOME/.config/openbox"
if [ -f "$SCRIPT_DIR/config/rc.xml" ]; then
    cp "$SCRIPT_DIR/config/rc.xml" "$HOME/.config/openbox/rc.xml"
else
    curl -fsSL "$BASE_RAW/config/rc.xml" -o "$HOME/.config/openbox/rc.xml"
fi

# 9. Configuración de variables en ~/.bashrc
echo -e "${YELLOW}[*] Configurando variables de entorno en ~/.bashrc...${NC}"
touch "$HOME/.bashrc"
grep -q "VSCODE_CLI_USE_FILE_KEYCHAIN" "$HOME/.bashrc" || echo "export VSCODE_CLI_USE_FILE_KEYCHAIN=1" >> "$HOME/.bashrc"
grep -q "BROWSER=termux-open-url" "$HOME/.bashrc" || echo "export BROWSER=termux-open-url" >> "$HOME/.bashrc"

# 10. Configurar preferencias óptimas de Termux:X11
echo -e "${YELLOW}[*] Optimizando preferencias de Termux:X11 (Portapapeles, Pantalla Completa)...${NC}"
termux-x11-preference clipboardEnable:true fullscreen:true hideCutout:true >/dev/null 2>&1 || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ¡Instalación y Configuración Pro Completadas!${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "🚀 ${CYAN}Comandos disponibles en tu terminal:${NC}"
echo -e "  • ${YELLOW}start-vscode${NC}      : Abre VS Code con audio y aceleración multi-hilo."
echo -e "  • ${YELLOW}stop-vscode${NC}       : Cierra limpiamente y guarda sesión, tabs y credenciales."
echo -e "  • ${YELLOW}share-port <port>${NC} : Genera túnel público HTTPS Cloudflare al instante."
echo -e "  • ${YELLOW}dev-info <port>${NC}   : Muestra enlaces locales y código QR para tu red Wi-Fi."
echo -e "  • ${YELLOW}notify-done \"msg\"${NC} : Alerta con vibración/notificación al terminar un comando."
echo -e "  • ${YELLOW}sync-vscode${NC}       : Respalda tus ajustes a GitHub en un solo clic."
echo -e "  • ${YELLOW}setup-swap${NC}        : Supervisa la memoria RAM y Swap contra cierres OOM."
echo ""
