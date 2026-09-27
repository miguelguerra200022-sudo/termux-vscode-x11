#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Mozilla Thunderbird
# Descripción: Cliente completo de correo electrónico, calendarios y gestión de tareas.
# URL Oficial: https://www.thunderbird.net
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Mozilla Thunderbird${NC}"
echo -e "${CYAN}  Cliente completo de correo electrónico, calendarios y gestión de tareas.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete thunderbird...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y thunderbird

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/thunderbird.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Mozilla Thunderbird
Comment=Cliente completo de correo electrónico, calendarios y gestión de tareas.
Exec=thunderbird
Icon=thunderbird
Terminal=false
Type=Application
Categories=Network;Email;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Mozilla Thunderbird instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
