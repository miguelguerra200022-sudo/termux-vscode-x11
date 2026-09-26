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

# 3. Actualizar repositorios e instalar las versiones más recientes de todo
echo -e "${YELLOW}[*] Buscando y actualizando paquetes a su última versión disponible...${NC}"
pkg update -y
pkg upgrade -y

echo -e "${YELLOW}[*] Habilitando repositorio X11...${NC}"
pkg install -y x11-repo

echo -e "${YELLOW}[*] Instalando las últimas versiones de VS Code, Zen Browser, X11, Openbox, Tint2 y utilidades...${NC}"
pkg install -y termux-x11-nightly code-oss code-is-code-oss openbox tint2 zen-browser rsync dbus aria2 pulseaudio termux-tools git cloudflared termux-api unzip inotify-tools openssl

# 4. Obtener dinámicamente la última versión de Termux:X11 desde GitHub Releases
echo -e "${YELLOW}[*] Consultando la última versión oficial de Termux:X11 en GitHub...${NC}"
APK_PATH="/storage/emulated/0/Download/termux-x11-universal-debug.apk"

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
)

for s in "${SCRIPTS[@]}"; do
    rm -f "$PREFIX/bin/$s"
    if [ -f "$SCRIPT_DIR/bin/$s" ]; then
        cp "$SCRIPT_DIR/bin/$s" "$PREFIX/bin/$s"
    else
        curl "${CURL_OPTS[@]}" "$BASE_RAW/bin/$s" -o "$PREFIX/bin/$s"
    fi
    chmod +x "$PREFIX/bin/$s"
done
chmod 500 "$PREFIX/bin/integrity-guard" "$PREFIX/bin/integrity-watchdog" "$PREFIX/bin/watcher-sync" 2>/dev/null || true

ln -sf "$PREFIX/bin/start-vscode" "$HOME/start-vscode.sh"
ln -sf "$PREFIX/bin/stop-vscode" "$HOME/stop-vscode.sh"

# 7. Configuración de VS Code (OLED Pure Black, fuentes con ligaduras, persistencia y navegador)
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

# 8. Configuración de Openbox (Optimización de pantalla completa y menú contextual)
echo -e "${YELLOW}[*] Configurando gestor de ventanas Openbox para pantallas táctiles...${NC}"
mkdir -p "$HOME/.config/openbox"
if [ -f "$SCRIPT_DIR/config/rc.xml" ]; then
    cp "$SCRIPT_DIR/config/rc.xml" "$HOME/.config/openbox/rc.xml"
    [ -f "$SCRIPT_DIR/config/menu.xml" ] && cp "$SCRIPT_DIR/config/menu.xml" "$HOME/.config/openbox/menu.xml"
else
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/rc.xml" -o "$HOME/.config/openbox/rc.xml"
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/menu.xml" -o "$HOME/.config/openbox/menu.xml" || true
fi

# 8.1 Configuración de Barra de Tareas tint2 (Estilo Ubuntu Yaru Dark con Lanzadores)
echo -e "${YELLOW}[*] Configurando barra de tareas inferior tint2 (estilo Ubuntu)...${NC}"
mkdir -p "$HOME/.config/tint2"
if [ -f "$SCRIPT_DIR/config/tint2rc" ]; then
    cp "$SCRIPT_DIR/config/tint2rc" "$HOME/.config/tint2/tint2rc"
else
    curl "${CURL_OPTS[@]}" "$BASE_RAW/config/tint2rc" -o "$HOME/.config/tint2/tint2rc"
fi

# 8.2 Configurar iconos del sistema para la barra de tareas
mkdir -p "$PREFIX/share/pixmaps"
if [ -f "$PREFIX/lib/code-oss/resources/app/resources/linux/code.png" ]; then
    cp "$PREFIX/lib/code-oss/resources/app/resources/linux/code.png" "$PREFIX/share/pixmaps/com.visualstudio.code.oss.png" 2>/dev/null || true
    cp "$PREFIX/lib/code-oss/resources/app/resources/linux/code.png" "$PREFIX/share/pixmaps/code-oss.png" 2>/dev/null || true
fi
if [ -f "$PREFIX/share/icons/hicolor/48x48/apps/zen-browser.png" ]; then
    cp "$PREFIX/share/icons/hicolor/48x48/apps/zen-browser.png" "$PREFIX/share/pixmaps/zen-browser.png" 2>/dev/null || true
fi

# 8.3 Restauración de datos y sesiones (VS Code y Zen Browser)
echo -e "${YELLOW}[*] Restaurando datos guardados (sesiones, cookies, historial, extensiones)...${NC}"
if [ -f "$PREFIX/bin/restore-vscode" ]; then
    "$PREFIX/bin/restore-vscode" || true
fi

# 9. Configuración de variables en ~/.bashrc
echo -e "${YELLOW}[*] Configurando variables de entorno en ~/.bashrc...${NC}"
touch "$HOME/.bashrc"
grep -q "VSCODE_CLI_USE_FILE_KEYCHAIN" "$HOME/.bashrc" || echo "export VSCODE_CLI_USE_FILE_KEYCHAIN=1" >> "$HOME/.bashrc"
sed -i 's/export BROWSER=termux-open-url/export BROWSER=zen-browser/g' "$HOME/.bashrc" 2>/dev/null || true
grep -q "BROWSER=zen-browser" "$HOME/.bashrc" || echo "export BROWSER=zen-browser" >> "$HOME/.bashrc"

# 10. Configurar preferencias óptimas de Termux:X11
echo -e "${YELLOW}[*] Optimizando preferencias de Termux:X11 (Portapapeles, Pantalla Completa)...${NC}"
termux-x11-preference clipboardEnable:true fullscreen:true hideCutout:true >/dev/null 2>&1 || true

# 11. Configurar accesos directos para la app Termux:Widget en pantalla de inicio
echo -e "${YELLOW}[*] Configurando accesos directos de pantalla de inicio (~/.shortcuts/)...${NC}"
mkdir -p "$HOME/.shortcuts/tasks"
cat << 'EOF' > "$HOME/.shortcuts/VS-Code"
#!/data/data/com.termux/files/usr/bin/bash
vscode
EOF
cat << 'EOF' > "$HOME/.shortcuts/Cerrar-VS-Code"
#!/data/data/com.termux/files/usr/bin/bash
stop-vscode
EOF
cat << 'EOF' > "$HOME/.shortcuts/Compartir-Web"
#!/data/data/com.termux/files/usr/bin/bash
dev-info 8080
EOF
chmod -R 700 "$HOME/.shortcuts"

# 12. Habilitar la tienda oficial de Microsoft Marketplace
echo -e "${YELLOW}[*] Desbloqueando la tienda oficial de extensiones de Microsoft...${NC}"
"$PREFIX/bin/set-marketplace" official >/dev/null 2>&1 || true

# 13. Descargar e instalar tipografía Fira Code con ligaduras
if [ ! -f "$PREFIX/share/fonts/TTF/FiraCode-Regular.ttf" ]; then
    echo -e "${YELLOW}[*] Instalando tipografía Fira Code con ligaduras de programación...${NC}"
    FONT_TMP="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/firafont"
    mkdir -p "$FONT_TMP" "$PREFIX/share/fonts/TTF" "$HOME/.termux"
    curl -sL "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o "$FONT_TMP/fira.zip" 2>/dev/null && \
    unzip -q "$FONT_TMP/fira.zip" -d "$FONT_TMP" 2>/dev/null && \
    cp "$FONT_TMP/ttf/"*.ttf "$PREFIX/share/fonts/TTF/" 2>/dev/null && \
    cp "$FONT_TMP/ttf/FiraCode-Regular.ttf" "$HOME/.termux/font.ttf" 2>/dev/null || true
    rm -rf "$FONT_TMP"
fi

# 14. Instalar copia maestra permanente de la Guía Rápida (@GUIA_RAPIDA.md)
echo -e "${YELLOW}[*] Instalando copia maestra permanente de la Guía Rápida (@GUIA_RAPIDA.md)...${NC}"
mkdir -p "$PREFIX/share/termux-vscode-x11"
if [ -f "$SCRIPT_DIR/docs/GUIA_RAPIDA.md" ]; then
    cp "$SCRIPT_DIR/docs/GUIA_RAPIDA.md" "$PREFIX/share/termux-vscode-x11/GUIA_RAPIDA.md"
else
    curl "${CURL_OPTS[@]}" "$BASE_RAW/docs/GUIA_RAPIDA.md" -o "$PREFIX/share/termux-vscode-x11/GUIA_RAPIDA.md"
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ¡Instalación y Configuración Pro Completadas!${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "🚀 ${CYAN}Comandos Pro disponibles en tu terminal:${NC}"
echo -e "  • ${YELLOW}vscode${NC}            : Explorador interactivo con números/flechas para elegir carpeta y abrir."
echo -e "  • ${YELLOW}start-vscode${NC}      : Abre VS Code directo con audio, aceleración y la Guía Rápida."
echo -e "  • ${YELLOW}stop-vscode${NC}       : Cierra limpiamente y respalda TODO en GitHub automáticamente."
echo -e "  • ${YELLOW}guia${NC}              : Abre la copia original permanente de la Guía (@GUIA_RAPIDA.md)."
echo -e "  • ${YELLOW}start-vscode-web${NC}  : Comparte VS Code para usarlo desde tu PC o Tablet remota."
echo -e "  • ${YELLOW}new-project${NC}       : Generador interactivo de plantillas de proyectos en 3 segundos."
echo -e "  • ${YELLOW}share-port <port>${NC} : Genera túnel público HTTPS Cloudflare al instante."
echo -e "  • ${YELLOW}dev-info <port>${NC}   : Muestra enlaces locales y código QR para tu red Wi-Fi."
echo -e "  • ${YELLOW}set-marketplace${NC}  : Alterna entre tienda Oficial Microsoft y Open-VSX."
echo -e "  • ${YELLOW}fix-phantom-killer${NC}: Desactiva el Phantom Process Killer de Android 12+."
echo -e "  • ${YELLOW}notify-done \"msg\"${NC} : Alerta con vibración/notificación al terminar un comando."
echo -e "  • ${YELLOW}sync-vscode${NC}       : Respalda tus ajustes a GitHub en un solo clic."
echo -e "  • ${YELLOW}setup-swap${NC}        : Supervisa la memoria RAM y Swap contra cierres OOM."
echo ""
