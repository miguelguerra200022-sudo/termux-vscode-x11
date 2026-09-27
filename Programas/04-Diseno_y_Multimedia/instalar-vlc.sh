#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: VLC media player
# Tagline: Free and open source cross-platform multimedia player that plays most multimedia files
# Instalador: VLC media player (Free and open source cross-platform multimedia player that plays most multimedia files)
# Descripción: Reproductor multimedia universal acelerado con soporte de audio.
# URL Oficial: https://www.videolan.org/vlc
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando VLC media player${NC}"
echo -e "${CYAN}  (Free and open source cross-platform multimedia player that plays most multimedia files)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete vlc...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y vlc

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/vlc.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=VLC Media Player
Comment=Reproductor multimedia universal acelerado con soporte de audio.
Exec=vlc
Icon=vlc
Terminal=false
Type=Application
Categories=AudioVideo;Player;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ VLC Media Player instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
