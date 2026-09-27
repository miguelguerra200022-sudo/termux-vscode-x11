#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: GNU Emacs
# Tagline: The extensible, customizable, self-documenting real-time display editor
# Instalador: GNU Emacs (The extensible, customizable, self-documenting real-time display editor)
# Descripción: Entorno extensible y personalizable con modo Org y Magit.
# URL Oficial: https://www.gnu.org/software/emacs/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando GNU Emacs${NC}"
echo -e "${CYAN}  (The extensible, customizable, self-documenting real-time display editor)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y emacs

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/emacs.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=GNU Emacs
Comment=Entorno extensible y personalizable con modo Org y Magit.
Exec=emacs
Icon=emacs
Terminal=false
Type=Application
Categories=Development;TextEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ GNU Emacs instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
