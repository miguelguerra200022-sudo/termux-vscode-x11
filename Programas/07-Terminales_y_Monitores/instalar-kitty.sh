#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Kitty
# Tagline: Emulador de terminal rápido y rico en funciones acelerado por GPU con soporte para gráficos
# Instalador: Kitty (Emulador de terminal rápido y rico en funciones acelerado por GPU con soporte para gráficos)
# Descripción: Terminal moderna con soporte nativo de imágenes, fuentes y pestañas.
# URL Oficial: https://sw.kovidgoyal.net/kitty/
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Kitty${NC}"
echo -e "${CYAN}  (Emulador de terminal rápido y rico en funciones acelerado por GPU con soporte para gráficos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando Termux User Repository (TUR)...${NC}"
pkg install -y tur-repo >/dev/null 2>&1 || true
pkg install -y kitty || pkg install -y kitty || true

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "kitty" >/dev/null 2>&1 || true
DESKTOP_FILE="$PREFIX/share/applications/kitty.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Kitty Terminal
Comment=Terminal moderna con soporte nativo de imágenes, fuentes y pestañas.
Exec=kitty
Icon=/data/data/com.termux/files/usr/share/pixmaps/kitty.png
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Kitty Terminal instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
