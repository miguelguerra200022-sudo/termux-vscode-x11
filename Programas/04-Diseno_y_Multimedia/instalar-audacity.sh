#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Audacity
# Tagline: El software de audio de código abierto más popular del mundo para grabar y editar
# Instalador: Audacity (El software de audio de código abierto más popular del mundo para grabar y editar)
# Descripción: Grabador y editor de audio multi-pista profesional con PulseAudio.
# URL Oficial: https://www.audacityteam.org
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Audacity${NC}"
echo -e "${CYAN}  (El software de audio de código abierto más popular del mundo para grabar y editar)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias de X11 y paquete audacity...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true
pkg install -y audacity

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/audacity.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Audacity Audio Editor
Comment=Grabador y editor de audio multi-pista profesional con PulseAudio.
Exec=audacity
Icon=audacity
Terminal=false
Type=Application
Categories=AudioVideo;AudioEditor;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Audacity Audio Editor instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
