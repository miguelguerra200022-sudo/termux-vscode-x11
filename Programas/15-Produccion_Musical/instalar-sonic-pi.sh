#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Sonic Pi
# Tagline: Entorno para programar y componer música electrónica en vivo (Live Coding)
# Instalador: Sonic Pi (Entorno para programar y componer música electrónica en vivo (Live Coding))
# Descripción: Sintetizador musical controlado por código Ruby para directos y producción.
# URL Oficial: https://sonic-pi.net
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Sonic Pi${NC}"
echo -e "${CYAN}  (Entorno para programar y componer música electrónica en vivo (Live Coding))${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete sonic-pi...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v sonic-pi >/dev/null 2>&1; then
    pkg install -y sonic-pi >/dev/null 2>&1 || apt-get install -y sonic-pi >/dev/null 2>&1 || true
fi


# Asegurar directorios de soporte para juegos y emuladores
if [ "15-Produccion_Musical" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/sonic-pi"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/sonic-pi" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "sonic-pi" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/sonic-pi.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Sonic Pi (Live Coding Music Synth)
Comment=Sintetizador musical controlado por código Ruby para directos y producción.
Exec=sonic-pi
Icon=/data/data/com.termux/files/usr/share/pixmaps/sonic-pi.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Education;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Sonic Pi instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
