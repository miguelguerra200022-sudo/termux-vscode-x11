#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Xournal++ Note Taking
# Descripción: Cuaderno digital para toma de notas manuscritas y anotación en PDFs.
# URL Oficial: https://xournalpp.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Xournal++ Note Taking${NC}"
echo -e "${CYAN}  Cuaderno digital para toma de notas manuscritas y anotación en PDFs.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete xournalpp...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y xournalpp

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/xournalpp.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Xournal++ Note Taking
Comment=Cuaderno digital para toma de notas manuscritas y anotación en PDFs.
Exec=xournalpp
Icon=xournalpp
Terminal=false
Type=Application
Categories=Office;Notes;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Xournal++ Note Taking instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
