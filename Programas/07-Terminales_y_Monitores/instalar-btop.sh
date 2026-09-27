#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Btop
# Tagline: Resource monitor that shows usage and stats for processor, memory, disks and network
# Instalador: Btop (Resource monitor that shows usage and stats for processor, memory, disks and network)
# Descripción: Monitor interactivo de CPU, memoria, discos y procesos con gráficos.
# URL Oficial: https://github.com/aristocratos/btop
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Btop${NC}"
echo -e "${CYAN}  (Resource monitor that shows usage and stats for processor, memory, disks and network)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y btop

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/btop.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Btop Resource Monitor
Comment=Monitor interactivo de CPU, memoria, discos y procesos con gráficos.
Exec=btop
Icon=btop
Terminal=false
Type=Application
Categories=System;Monitor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Btop Resource Monitor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
