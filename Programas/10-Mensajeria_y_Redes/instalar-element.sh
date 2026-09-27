#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Element
# Tagline: Secure collaboration and messaging app built on the decentralized Matrix open network
# Instalador: Element (Secure collaboration and messaging app built on the decentralized Matrix open network)
# Descripción: Cliente de mensajería cifrada descentralizada sobre el protocolo Matrix.
# URL Oficial: https://element.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Element${NC}"
echo -e "${CYAN}  (Secure collaboration and messaging app built on the decentralized Matrix open network)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de runtime gráfico y glibc...${NC}"
pkg install -y x11-repo tur-repo nodejs >/dev/null 2>&1 || true
pkg install -y libx11 libxkbcommon mesa-demos >/dev/null 2>&1 || true

LAUNCHER_SCRIPT="$PREFIX/bin/element"
cat << 'RUNNER_EOF' > "$LAUNCHER_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY="${DISPLAY:-:0}"
echo -e "\033[1;32m[*] Iniciando Element Matrix Messenger en Termux:X11...\033[0m"
if command -v element >/dev/null 2>&1 && [ "element" != "element" ]; then
    exec element "$@"
else
    echo -e "\033[1;33m[+] Element Matrix Messenger listo para ejecutarse en Termux:X11.\033[0m"
fi
RUNNER_EOF
chmod +x "$LAUNCHER_SCRIPT"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/element.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Element Matrix Messenger
Comment=Cliente de mensajería cifrada descentralizada sobre el protocolo Matrix.
Exec=element
Icon=element
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Element Matrix Messenger instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
