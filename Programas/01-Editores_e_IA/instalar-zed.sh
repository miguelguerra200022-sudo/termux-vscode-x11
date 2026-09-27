#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Zed Editor
# Descripción: Editor de código ultra-rápido en Rust con colaboración en tiempo real.
# URL Oficial: https://zed.dev
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Zed Editor${NC}"
echo -e "${CYAN}  Editor de código ultra-rápido en Rust con colaboración en tiempo real.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando herramientas Rust y paquete zed...${NC}"
pkg install -y rust cargo >/dev/null 2>&1 || true
pkg install -y zed || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/zed.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Zed Editor
Comment=Editor de código ultra-rápido en Rust con colaboración en tiempo real.
Exec=zed
Icon=zed
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Zed Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
