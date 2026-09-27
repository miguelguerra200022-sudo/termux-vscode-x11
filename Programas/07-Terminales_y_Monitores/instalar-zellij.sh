#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Zellij
# Tagline: A terminal workspace with batteries included - Fast, intuitive and modern multiplexer in Rust
# Instalador: Zellij (A terminal workspace with batteries included - Fast, intuitive and modern multiplexer in Rust)
# Descripción: Multiplexor moderno en Rust con interfaz visual interactiva y plugins.
# URL Oficial: https://zellij.dev
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Zellij${NC}"
echo -e "${CYAN}  (A terminal workspace with batteries included - Fast, intuitive and modern multiplexer in Rust)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y zellij

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/zellij.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Zellij Terminal Workspace
Comment=Multiplexor moderno en Rust con interfaz visual interactiva y plugins.
Exec=zellij
Icon=zellij
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Zellij Terminal Workspace instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
