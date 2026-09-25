#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador Automatizado: VS Code Nativo + Termux-X11 Pro (Siempre Última Versión)
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
echo -e "${CYAN}     (Siempre descargando las últimas versiones)${NC}"
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

# 3. Actualizar repositorios e instalar las versiones más recientes de todo
echo -e "${YELLOW}[*] Buscando y actualizando paquetes a su última versión disponible...${NC}"
pkg update -y
pkg upgrade -y

echo -e "${YELLOW}[*] Habilitando repositorio X11...${NC}"
pkg install -y x11-repo

echo -e "${YELLOW}[*] Instalando las últimas versiones de VS Code, X11, Openbox y utilidades...${NC}"
pkg install -y termux-x11-nightly code-oss code-is-code-oss openbox dbus aria2 pulseaudio termux-tools git cloudflared termux-api

# 4. Obtener dinámicamente la última versión de Termux:X11 desde GitHub Releases
echo -e "${YELLOW}[*] Consultando la última versión oficial de Termux:X11 en GitHub...${NC}"
APK_PATH="/storage/emulated/0/Download/termux-x11-universal-debug.apk"

# Consultar API de GitHub para obtener la URL de descarga más reciente
LATEST_APK_URL=$(curl -s "https://api.github.com/repos/termux/termux-x11/releases" 2>/dev/null | grep -o 'https://github.com/termux/termux-x11/releases/download/[^"]*universal-debug\.apk' | head -n 1)

if [ -z "$LATEST_APK_URL" ]; then
    LATEST_APK_URL="https://github.com/termux/termux-x11/releases/download/nightly/termux-x11-universal-debug.apk"
fi

echo -e "${CYAN}[i] Versión de Termux:X11 detectada: ${LATEST_APK_URL}${NC}"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${YELLOW}[*] Descargando la última versión del APK a Descargas...${NC}"
    aria2c -x 4 -s 4 -d "/storage/emulated/0/Download" -o "termux-x11-universal-debug.apk" "$LATEST_APK_URL" || \
    curl -L "$LATEST_APK_URL" -o "$APK_PATH" || true
    echo -e "${GREEN}[+] APK descargado en: ${APK_PATH}${NC}"
    echo -e "${YELLOW}[i] Instala o actualiza la app Termux:X11 desde tu gestor de archivos o Descargas.${NC}"
else
    echo -e "${GREEN}[+] APK de Termux:X11 ya disponible en Descargas.${NC}"
fi

# 5. Obtener directorio del script (local o clonado)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
BASE_RAW="https://raw.githubusercontent.com/miguelguerra200022-sudo/termux-vscode-x11/main"
CURL_OPTS=(-fsSL -H "Cache-Control: no-cache" -H "Pragma: no-cache")

# 6. Crear y configurar scripts y comandos de desarrollo en $PREFIX/bin
echo -e "${YELLOW}[*] Instalando utilidades Pro en el sistema...${NC}"

SCRIPTS=("start-vscode" "stop-vscode" "share-port" "dev-info" "notify-done" "sync-vscode" "setup-swap")

for s in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    else
        curl "${CURL_OPTS[@]}" "$BASE_RAW/bin/$s" -o "$PREFIX/bin/$s"
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
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/settings.json" -o "$HOME/.config/Code - OSS/User/settings.json"
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/argv.json" -o "$HOME/.vscode-oss/argv.json"
fi

# 8. Configuración de Openbox (Optimización de pantalla completa sin bordes)
echo -e "${YELLOW}[*] Configurando gestor de ventanas Openbox para pantallas táctiles...${NC}"
mkdir -p "$HOME/.config/openbox"
if [ -f "$SCRIPT_DIR/config/rc.xml" ]; then
    cp "$SCRIPT_DIR/config/rc.xml" "$HOME/.config/openbox/rc.xml"
else
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/rc.xml" -o "$HOME/.config/openbox/rc.xml"
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
echo -e "  • ${YELLOW}stop-vscode${NC}       : Cierra limpiamente y respalda TODO en GitHub automáticamente."
echo -e "  • ${YELLOW}share-port <port>${NC} : Genera túnel público HTTPS Cloudflare al instante."
echo -e "  • ${YELLOW}dev-info <port>${NC}   : Muestra enlaces locales y código QR para tu red Wi-Fi."
echo -e "  • ${YELLOW}notify-done \"msg\"${NC} : Alerta con vibración/notificación al terminar un comando."
echo -e "  • ${YELLOW}sync-vscode${NC}       : Respalda tus ajustes a GitHub en un solo clic."
echo -e "  • ${YELLOW}setup-swap${NC}        : Supervisa la memoria RAM y Swap contra cierres OOM."
echo ""
