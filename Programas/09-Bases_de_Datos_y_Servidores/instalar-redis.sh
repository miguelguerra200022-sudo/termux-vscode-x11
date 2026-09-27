#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==============================================================================
# Nombre: Redis
# Tagline: The open source, in-memory data store used by millions as database, cache and message broker
# Instalador: Redis (The open source, in-memory data store used by millions as database, cache and message broker)
# Descripción: Almacén en memoria de clave-valor de alta velocidad para caché y colas.
# URL Oficial: https://redis.io
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}  📦 Instalando Redis${NC}"
echo -e "${CYAN}  (The open source, in-memory data store used by millions as database, cache and message broker)${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo -e "${YELLOW}[*] Instalando paquetes requeridos vía pkg...${NC}"
pkg update -y >/dev/null 2>&1 || true
pkg install -y redis

# Registrar lanzador de escritorio .desktop para Openbox y tint2
echo -e "${CYAN}[*] Registrando lanzador oficial en el sistema...${NC}"
mkdir -p "$PREFIX/share/applications" "$HOME/.local/share/applications"

DESKTOP_FILE="$PREFIX/share/applications/redis.desktop"
cat << 'DESK_EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Name=Redis In-Memory Store
Comment=Almacén en memoria de clave-valor de alta velocidad para caché y colas.
Exec=redis
Icon=redis
Terminal=false
Type=Application
Categories=Development;Database;
DESK_EOF

cp -f "$DESKTOP_FILE" "$HOME/.local/share/applications/" 2>/dev/null || true

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✔ Redis In-Memory Store instalado y registrado con éxito.${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
