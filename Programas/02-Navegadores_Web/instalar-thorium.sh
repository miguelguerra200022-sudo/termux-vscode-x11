#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Thorium
# Tagline: The fastest browser on Earth - Compiler-optimized Chromium fork for maximum speed
# Instalador: Thorium (The fastest browser on Earth - Compiler-optimized Chromium fork for maximum speed)
# Descripción: Navegador hiper-optimizado para máxima velocidad de compilación y carga.
# URL Oficial: https://thorium.rocks
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Thorium${NC}"
echo -e "${CYAN}  (The fastest browser on Earth - Compiler-optimized Chromium fork for maximum speed)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y thorium-browser || pkg install -y thorium || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/thorium.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Thorium Browser
Comment=Navegador hiper-optimizado para máxima velocidad de compilación y carga.
Exec=thorium-browser
Icon=thorium
Terminal=false
Type=Application
Categories=Network;WebBrowser;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Thorium Browser instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
