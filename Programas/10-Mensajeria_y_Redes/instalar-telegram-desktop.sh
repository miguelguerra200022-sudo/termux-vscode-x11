#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Telegram Desktop
# Descripción: Cliente oficial de mensajería con soporte multimedia y bots en X11.
# URL Oficial: https://desktop.telegram.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Telegram Desktop${NC}"
echo -e "${CYAN}  Cliente oficial de mensajería con soporte multimedia y bots en X11.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete telegram-desktop...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y telegram-desktop

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/telegram-desktop.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Telegram Desktop
Comment=Cliente oficial de mensajería con soporte multimedia y bots en X11.
Exec=telegram-desktop
Icon=telegram-desktop
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Telegram Desktop instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
