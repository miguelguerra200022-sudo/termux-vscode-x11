#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# menu-instalador.sh: Menú Interactivo de +100 Programas para Termux
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
    clear
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${GREEN}  📦 CENTRO DE INSTALACIÓN DE SOFTWARE (TERMUX / X11)${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo ""
    echo -e "Selecciona una categoría:"
    echo ""
    
    CATEGORIES=()
    i=1
    for d in "$SCRIPT_DIR"/*/; do
        [ -d "$d" ] || continue
        cname=$(basename "$d")
        CATEGORIES+=("$cname")
        cname_clean=$(echo "$cname" | sed 's/^[0-9]*-//; s/_/ /g')
        count=$(find "$d" -maxdepth 1 -name "instalar-*.sh" | wc -l)
        echo -e "  [${YELLOW}$i${NC}] 📁 $cname_clean (${CYAN}$count programas${NC})"
        ((i++))
    done
    echo ""
    echo -e "  [${YELLOW}0${NC}] 🚪 Salir"
    echo ""
    echo -ne "${BOLD}👉 Opción: ${NC}"
    read -r opt_cat

    if [ "$opt_cat" = "0" ] || [ -z "$opt_cat" ]; then
        echo -e "\n${YELLOW}[*] Saliendo...${NC}\n"
        exit 0
    fi

    if [ "$opt_cat" -ge 1 ] && [ "$opt_cat" -le "${#CATEGORIES[@]}" ]; then
        sel_cat="${CATEGORIES[$((opt_cat-1))]}"
        sel_path="$SCRIPT_DIR/$sel_cat"
        
        while true; do
            clear
            cat_title=$(echo "$sel_cat" | sed 's/^[0-9]*-//; s/_/ /g')
            echo -e "${BLUE}======================================================${NC}"
            echo -e "${GREEN}  📁 CATEGORÍA: $cat_title${NC}"
            echo -e "${BLUE}======================================================${NC}"
            echo ""
            
            PROGRAMS=()
            j=1
            for p in "$sel_path"/instalar-*.sh; do
                [ -f "$p" ] || continue
                pname=$(basename "$p" | sed 's/instalar-//; s/.sh//')
                PROGRAMS+=("$p")
                echo -e "  [${YELLOW}$j${NC}] 📦 $pname"
                ((j++))
            done
            echo ""
            echo -e "  [${YELLOW}0${NC}] ↩️ Volver a categorías"
            echo ""
            echo -ne "${BOLD}👉 Selecciona un programa para instalar: ${NC}"
            read -r opt_prog

            if [ "$opt_prog" = "0" ] || [ -z "$opt_prog" ]; then
                break
            fi

            if [ "$opt_prog" -ge 1 ] && [ "$opt_prog" -le "${#PROGRAMS[@]}" ]; then
                target_script="${PROGRAMS[$((opt_prog-1))]}"
                echo ""
                echo -e "${CYAN}⚡ Ejecutando: $(basename "$target_script")...${NC}"
                echo ""
                bash "$target_script"
                echo ""
                echo -e "${YELLOW}Presiona ENTER para continuar...${NC}"
                read -r
            fi
        done
    fi
done
