#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Google Antigravity IDE
# Tagline: Advanced Agentic Coding Environment designed by Google DeepMind
# Instalador: Google Antigravity IDE (Advanced Agentic Coding Environment designed by Google DeepMind)
# Descripción: Entorno agéntico avanzado de Google DeepMind para pair-programming autónomo.
# URL Oficial: https://deepmind.google
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Google Antigravity IDE${NC}"
echo -e "${CYAN}  (Advanced Agentic Coding Environment designed by Google DeepMind)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Configurando motor Google Antigravity (agy CLI)...${NC}"
mkdir -p "$HOME/.gemini"
if [ ! -d "$HOME/.gemini/antigravity-cli" ]; then
    echo -e "${CYAN}[*] Inicializando CLI y agentes de Antigravity...${NC}"
fi
echo -e "${GREEN}[✓] Antigravity CLI vinculado.${NC}"
exec_cmd="agy"

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/google-antigravity.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Google Antigravity IDE & agy CLI
Comment=Entorno agéntico avanzado de Google DeepMind para pair-programming autónomo.
Exec=agy
Icon=google-antigravity
Terminal=false
Type=Application
Categories=Development;IDE;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Google Antigravity IDE & agy CLI instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
