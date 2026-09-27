#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Instalador: Yazi Async File Manager
# Descripción: Administrador de archivos en terminal escrito en Rust, asíncrono y visual.
# URL Oficial: https://yazi-rs.github.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Yazi Async File Manager${NC}"
echo -e "${CYAN}  Administrador de archivos en terminal escrito en Rust, asíncrono y visual.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando herramientas Rust y paquete yazi...${NC}"
pkg install -y rust cargo >/dev/null 2>&1 || true
pkg install -y yazi || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/yazi.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Yazi Async File Manager
Comment=Administrador de archivos en terminal escrito en Rust, asíncrono y visual.
Exec=yazi
Icon=yazi
Terminal=false
Type=Application
Categories=System;FileManager;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Yazi Async File Manager instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
