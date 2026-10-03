#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: DuckStation
# Tagline: Emulador avanzado de PlayStation 1 con escalado y filtros gráficos
# Instalador: DuckStation (Emulador avanzado de PlayStation 1 con escalado y filtros gráficos)
# Descripción: Emulador de Sony PlayStation 1 centrado en la jugabilidad, velocidad y mantenimiento.
# URL Oficial: https://github.com/stenzek/duckstation
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando DuckStation${NC}"
echo -e "${CYAN}  (Emulador avanzado de PlayStation 1 con escalado y filtros gráficos)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando dependencias y paquete duckstation-qt...${NC}"
pkg install -y x11-repo >/dev/null 2>&1 || true

if ! command -v duckstation-qt >/dev/null 2>&1; then
    pkg install -y duckstation-qt >/dev/null 2>&1 || apt-get install -y duckstation-qt >/dev/null 2>&1 || true
fi
    if ! command -v duckstation-qt >/dev/null 2>&1; then
        echo -e "${YELLOW}[*] Probando paquete alternativo duckstation...${NC}"
        pkg install -y duckstation >/dev/null 2>&1 || apt-get install -y duckstation >/dev/null 2>&1 || true
    fi

# Asegurar directorios de soporte para juegos y emuladores
if [ "12-Emuladores_y_Retro" = "12-Emuladores_y_Retro" ]; then
    mkdir -p "$HOME/RetroGames/duckstation"
    if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
        mkdir -p "/storage/emulated/0/RetroGames/duckstation" 2>/dev/null || true
    fi
fi

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications" "$HOME/Desktop"

command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "duckstation" >/dev/null 2>&1 || true

DESKTOP_FILE="$PREFIX/share/applications/duckstation.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=DuckStation (PlayStation 1 Emulator)
Comment=Emulador de Sony PlayStation 1 centrado en la jugabilidad, velocidad y mantenimiento.
Exec=duckstation-qt
Icon=/data/data/com.termux/files/usr/share/pixmaps/duckstation.png
Terminal=false
Type=Application
Categories=Game;Emulator;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true
cp -f "$DESKTOP_FILE" "$HOME/Desktop/" 2>/dev/null || true
chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ DuckStation instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
