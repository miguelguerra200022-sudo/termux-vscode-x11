#!/data/data/com.termux/files/usr/bin/bash
# Restauración estricta de terminal ante cualquier salida o interrupción
cleanup_terminal() {
    stty sane 2>/dev/null || true
    echo -ne "\033[?25h\033[0m" 2>/dev/null || true
}
handle_sigint() {
    cleanup_terminal
    echo -e "\n\033[1;33m[*] Cancelado por el usuario (Ctrl+C). Saliendo...\033[0m\n" >&2
    exit 130
}
trap cleanup_terminal EXIT HUP
trap handle_sigint INT TERM
# ==============================================================================
# menu-instalador.sh: Centro de Instalación y Desinstalación de Software
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
GRAY='\033[0;90m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLED_REGISTRY="$HOME/.config/termux-software-center/installed.list"
get_ui_cols() {
    local c
    c=$(tput cols 2>/dev/null || echo 80)
    c=$((c - 2))
    if [ "$c" -lt 36 ]; then c=36; elif [ "$c" -gt 86 ]; then c=86; fi
    echo "$c"
}

get_div_bar() {
    local c=$(get_ui_cols)
    printf '%*s' "$c" '' | tr ' ' '═'
}

get_sep_bar() {
    local c=$(get_ui_cols)
    printf '%*s' "$c" '' | tr ' ' '─'
}

get_box_top() {
    local c=$(get_ui_cols)
    echo "╔$(printf '%*s' "$((c - 2))" '' | tr ' ' '═')╗"
}

get_box_sep() {
    local c=$(get_ui_cols)
    echo "╟$(printf '%*s' "$((c - 2))" '' | tr ' ' '─')╢"
}

get_box_bot() {
    local c=$(get_ui_cols)
    echo "╚$(printf '%*s' "$((c - 2))" '' | tr ' ' '═')╝"
}

mkdir -p "$(dirname "$INSTALLED_REGISTRY")" "$HOME/Desktop"

# ------------------------------------------------------------------------------
# Ejecutor de instaladores con Split-Screen y animación ASCII Matrix en tiempo real
# ------------------------------------------------------------------------------
run_installer_script() {
    local target_script="$1"
    local target_name="$2"
    local ascii_runner=""
    if command -v code-stack-ascii >/dev/null 2>&1; then
        ascii_runner="$(command -v code-stack-ascii)"
    elif [ -f "$REPO_DIR/bin/code-stack-ascii" ]; then
        ascii_runner="$REPO_DIR/bin/code-stack-ascii"
    fi

    if [ -n "$ascii_runner" ]; then
        python3 "$ascii_runner" run --title "$target_name" -- bash "$target_script"
    else
        bash "$target_script"
    fi
}

# ------------------------------------------------------------------------------
# Lector de entrada con soporte nativo para la tecla BORRAR (Backspace) como ATRÁS
# Envía los mensajes visuales a stderr para que command substitution $(...) capture
# únicamente la opción seleccionada.
# ------------------------------------------------------------------------------
read_menu_input() {
    local prompt="$1"
    local input=""
    local char=""

    echo -ne "$prompt" >&2

    # Si la entrada no es una terminal interactiva (ej. scripts o pipes)
    if [ ! -t 0 ]; then
        read -r input || return 0
        echo "$input"
        return 0
    fi

    local old_stty
    old_stty=$(stty -g 2>/dev/null || true)
    # Desactivar modo canónico y eco para capturar la tecla borrar en tiempo real
    stty -icanon -echo min 1 time 0 2>/dev/null || true

    trap 'stty "$old_stty" 2>/dev/null || stty sane 2>/dev/null; echo -ne "\\033[?25h\\033[0m" 2>/dev/null; exit 130' INT TERM

    while IFS= read -r -s -n 1 char; do
        # Tecla ENTER (\r = 13, \n = 10, o vacío)
        if [ -z "$char" ] || [ "$char" = $'\r' ] || [ "$char" = $'\n' ]; then
            stty "$old_stty" 2>/dev/null || true
            trap - INT TERM
            echo "" >&2
            echo "$input"
            return 0
        fi

        # Tecla BORRAR del teclado (Backspace: ASCII 127 o ASCII 8)
        if [ "$char" = $'\x7f' ] || [ "$char" = $'\b' ]; then
            if [ -z "$input" ]; then
                # Si el campo está vacío y presiona borrar -> ECHARSE PARA ATRÁS
                stty "$old_stty" 2>/dev/null || true
                trap - INT TERM
                echo "" >&2
                echo "__BACK__"
                return 0
            else
                # Borrar el último carácter en pantalla y memoria
                input="${input%?}"
                echo -ne "\b \b" >&2
            fi
            continue
        fi

        # Tecla ESC (\x1b)
        if [ "$char" = $'\x1b' ]; then
            local extra=""
            read -r -s -n 2 -t 0.05 extra 2>/dev/null || true
            if [ -z "$extra" ]; then
                # Tecla ESC solitaria -> ATRÁS
                stty "$old_stty" 2>/dev/null || true
                trap - INT TERM
                echo "" >&2
                echo "__BACK__"
                return 0
            fi
            # Ignorar secuencias de escape de flechas
            continue
        fi

        # Ctrl+C (\x03) o Ctrl+D (\x04) -> SALIR INMEDIATAMENTE
        if [ "$char" = $'\x03' ] || [ "$char" = $'\x04' ]; then
            stty "$old_stty" 2>/dev/null || stty sane 2>/dev/null || true
            trap - INT TERM
            echo -e "\n${YELLOW}[*] Cancelado por el usuario (Ctrl+C). Saliendo...${NC}\n" >&2
            kill -s INT $$ 2>/dev/null || exit 130
            return 130
        fi

        # Caracteres normales imprimibles
        if [[ "$char" =~ [[:print:]] ]]; then
            input+="$char"
            echo -n "$char" >&2
        fi
    done

    stty "$old_stty" 2>/dev/null || true
    trap - INT TERM
    echo "" >&2
    echo "$input"
    return 0
}

pause_menu() {
    local prompt="${1:-Presiona ENTER o borrar para continuar...}"
    read_menu_input "${YELLOW}$prompt${NC}" >/dev/null
}

# ------------------------------------------------------------------------------
# Lector ultrarrápido de metadatos (# Nombre y # Tagline) sin procesos hijos
# ------------------------------------------------------------------------------
get_program_meta() {
    local file="$1"
    _META_NAME=""
    _META_TAGLINE=""
    local count=0
    while IFS= read -r line || [ -n "$line" ]; do
        ((count++))
        case "$line" in
            "# Nombre:"*)
                _META_NAME="${line#\# Nombre:}"
                _META_NAME="${_META_NAME#"${_META_NAME%%[![:space:]]*}"}"
                ;;
            "# Tagline:"*)
                _META_TAGLINE="${line#\# Tagline:}"
                _META_TAGLINE="${_META_TAGLINE#"${_META_TAGLINE%%[![:space:]]*}"}"
                ;;
        esac
        if [ -n "$_META_NAME" ] && [ -n "$_META_TAGLINE" ]; then
            break
        fi
        [ "$count" -ge 25 ] && break
    done < "$file"
    # Limpiar posibles paréntesis sobrantes en los extremos
    _META_TAGLINE="${_META_TAGLINE#\(}"
    _META_TAGLINE="${_META_TAGLINE%\)}"
}

# ------------------------------------------------------------------------------
# Caché de búsqueda ultra-rápida de programas instalados
# ------------------------------------------------------------------------------
declare -A INSTALLED_BIN_MAP
declare -A INSTALLED_DESKTOP_MAP

refresh_installed_cache() {
    INSTALLED_BIN_MAP=()
    INSTALLED_DESKTOP_MAP=()

    local b d
    for b in "$PREFIX/bin"/*; do
        [ -e "$b" ] && INSTALLED_BIN_MAP["${b##*/}"]=1
    done

    for d in "$PREFIX/share/applications"/*.desktop \
             "$HOME/.local/share/applications"/*.desktop \
             "$HOME/Desktop"/*.desktop; do
        [ -f "$d" ] && INSTALLED_DESKTOP_MAP["${d##*/}"]=1
    done
}

is_program_installed() {
    local pscript="$1"
    local fname="${pscript##*/}"
    local slug="${fname#instalar-}"
    slug="${slug%.sh}"

    # Casos especiales
    if [ "$slug" = "vscode" ]; then
        if [ -n "${INSTALLED_BIN_MAP["code-oss"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["code-oss.desktop"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["vscode.desktop"]}" ]; then
            return 0
        fi
    fi

    if [ "$slug" = "zen-browser" ]; then
        if [ -n "${INSTALLED_BIN_MAP["zen-browser"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["zen-browser.desktop"]}" ]; then
            return 0
        fi
    fi

    if [ "$slug" = "openbox" ]; then
        if [ -n "${INSTALLED_BIN_MAP["openbox"]}" ] || \
           [ -n "${INSTALLED_DESKTOP_MAP["openbox.desktop"]}" ] || \
           command -v openbox >/dev/null 2>&1; then
            return 0
        fi
    fi

    # Comprobación por binario
    if [ -n "${INSTALLED_BIN_MAP["$slug"]}" ]; then
        return 0
    fi
    local slug_clean="${slug//-/}"
    if [ -n "${INSTALLED_BIN_MAP["$slug_clean"]}" ]; then
        return 0
    fi

    # Comprobación por archivo .desktop
    if [ -n "${INSTALLED_DESKTOP_MAP["${slug}.desktop"]}" ] || \
       [ -n "${INSTALLED_DESKTOP_MAP["${slug//-/_}.desktop"]}" ]; then
        return 0
    fi

    # Registro persistente
    if [ -f "$INSTALLED_REGISTRY" ] && grep -Fxq "$slug" "$INSTALLED_REGISTRY" 2>/dev/null; then
        return 0
    fi

    return 1
}

# ------------------------------------------------------------------------------
# Sincronizar lanzador en el Escritorio interactivo (~/Desktop) estilo PC
# ------------------------------------------------------------------------------
sync_desktop_launcher() {
    local slug="$1"
    mkdir -p "$HOME/Desktop" "$HOME/.local/share/applications"

    # Descargar / asegurar icono oficial bajo demanda si aún no existe
    command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon "$slug" >/dev/null 2>&1 || true

    local desktop_found=""
    for d in "$PREFIX/share/applications/${slug}.desktop" \
             "$HOME/.local/share/applications/${slug}.desktop" \
             "$PREFIX/share/applications/${slug//-/_}.desktop"; do
        if [ -f "$d" ]; then
            desktop_found="$d"
            break
        fi
    done

    if [ "$slug" = "vscode" ] && [ -f "$PREFIX/share/applications/code-oss.desktop" ]; then
        desktop_found="$PREFIX/share/applications/code-oss.desktop"
    fi

    if [ -n "$desktop_found" ]; then
        # Validación y saneamiento proactivo de Exec
        local exec_line=$(grep -E "^Exec=" "$desktop_found" | head -n 1)
        local exec_cmd=$(echo "$exec_line" | sed 's/^Exec=//' | awk '{print $1}')
        if [ -n "$exec_cmd" ] && ! command -v "$exec_cmd" >/dev/null 2>&1; then
            # Buscar binarios alternativos generados por paquetes Termux
            for cand in "${exec_cmd}-browser" "${exec_cmd}-desktop" "${exec_cmd}-bin" "${slug}" "${slug}-browser"; do
                if command -v "$cand" >/dev/null 2>&1; then
                    ln -sf "$(command -v "$cand")" "$PREFIX/bin/$exec_cmd" 2>/dev/null || true
                    break
                fi
            done
        fi

        # Validación y saneamiento proactivo de Icon
        local icon_line=$(grep -E "^Icon=" "$desktop_found" | head -n 1)
        local icon_path=$(echo "$icon_line" | sed 's/^Icon=//')
        if [ -n "$icon_path" ] && [ ! -f "$icon_path" ]; then
            if [ -f "/data/data/com.termux/files/usr/share/pixmaps/${slug}.png" ]; then
                sed -i "s|^Icon=.*|Icon=/data/data/com.termux/files/usr/share/pixmaps/${slug}.png|" "$desktop_found" 2>/dev/null || true
            elif [ -f "/data/data/com.termux/files/usr/share/pixmaps/${slug}.svg" ]; then
                sed -i "s|^Icon=.*|Icon=/data/data/com.termux/files/usr/share/pixmaps/${slug}.svg|" "$desktop_found" 2>/dev/null || true
            fi
        fi

        cp -f "$desktop_found" "$HOME/.local/share/applications/" 2>/dev/null || true
        cp -f "$desktop_found" "$HOME/Desktop/" 2>/dev/null || true
        chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true
    fi

    command -v openbox >/dev/null 2>&1 && openbox --reconfigure >/dev/null 2>&1 || true
    command -v pcmanfm >/dev/null 2>&1 && pcmanfm --reconfigure >/dev/null 2>&1 || true
}

remove_desktop_launcher() {
    local slug="$1"
    rm -f "$HOME/Desktop/${slug}.desktop" \
          "$HOME/Desktop/${slug//-/_}.desktop" \
          "$HOME/.local/share/applications/${slug}.desktop" \
          "$PREFIX/share/applications/${slug}.desktop" 2>/dev/null || true

    if [ "$slug" = "vscode" ]; then
        rm -f "$HOME/Desktop/code-oss.desktop" "$HOME/Desktop/vscode.desktop" \
              "$HOME/.local/share/applications/code-oss.desktop" \
              "$HOME/.local/share/applications/vscode.desktop" 2>/dev/null || true
    fi
    if [ "$slug" = "zen-browser" ]; then
        rm -f "$HOME/Desktop/zen-browser.desktop" "$HOME/Desktop/userapp-Zen-"*.desktop \
              "$HOME/.local/share/applications/zen-browser.desktop" 2>/dev/null || true
    fi

    # Eliminar el icono oficial de disco para no ocupar espacio
    if [ "$slug" != "vscode" ] && [ "$slug" != "zen-browser" ]; then
        command -v fetch-app-icon >/dev/null 2>&1 && fetch-app-icon --clean "$slug" >/dev/null 2>&1 || true
        rm -f "/data/data/com.termux/files/usr/share/pixmaps/${slug}.png" \
              "/data/data/com.termux/files/usr/share/pixmaps/${slug}.svg" 2>/dev/null || true
    fi

    command -v openbox >/dev/null 2>&1 && openbox --reconfigure >/dev/null 2>&1 || true
    command -v pcmanfm >/dev/null 2>&1 && pcmanfm --reconfigure >/dev/null 2>&1 || true
}

# ------------------------------------------------------------------------------
# Respaldo Criptográfico Silencioso (Cero mención de subidas o GitHub)
# ------------------------------------------------------------------------------
do_silent_backup() {
    # Respaldo seguro a través de vault-manager (cifrado AES-256 PBKDF2, sin exponer perfiles en texto plano en Git)
    if command -v vault-manager >/dev/null 2>&1; then
        vault-manager pack >/dev/null 2>&1 || true
    elif [ -f "$REPO_DIR/bin/vault-manager" ]; then
        bash "$REPO_DIR/bin/vault-manager" pack >/dev/null 2>&1 || true
    fi
}

# ------------------------------------------------------------------------------
# Diálogo unificado de Desinstalación (Borrar o Conservar credenciales)
# ------------------------------------------------------------------------------
prompt_and_uninstall() {
    local target_script="$1"
    local fname="${target_script##*/}"
    local slug="${fname#instalar-}"
    slug="${slug%.sh}"

    get_program_meta "$target_script"
    local pname="$_META_NAME"
    [ -z "$pname" ] && pname="$slug"

    # Protección de componentes del entorno de ventanas
    if [ "$slug" = "openbox" ] || [ "$slug" = "tint2" ]; then
        echo ""
        echo -e "${RED}[!] AVISO: ${BOLD}${pname}${NC}${RED} es el gestor gráfico principal.${NC}"
        echo -e "${YELLOW}Desinstalarlo desactivará la interfaz visual de escritorio.${NC}"
        echo ""
        echo -e "  [${YELLOW}1${NC}] Cancelar y volver atrás ${GRAY}(Recomendado)${NC}"
        echo -e "  [${YELLOW}2${NC}] Continuar de todos modos"
        echo ""
        local confirm_crit
        confirm_crit=$(read_menu_input "${BOLD}👉 Opción [1/2]: ${NC}")
        if [ "$confirm_crit" != "2" ]; then
            return 0
        fi
    fi

    while true; do
        clear
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo -e "${YELLOW}  ⚠️ OPCIONES DE DESINSTALACIÓN: ${BOLD}${pname}${NC}"
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo ""
        echo -e "¿Cómo deseas proceder con la desinstalación?"
        echo ""
        echo -e "  [${YELLOW}1${NC}] 🗑️ ${BOLD}Desinstalar aplicación CONSERVANDO credenciales y datos${NC}"
        echo -e "      ${GRAY}└─ Tus cuentas, preferencias y tokens quedarán guardados.${NC}"
        echo -e "      ${GRAY}   Si lo vuelves a instalar en el futuro, iniciará con todo listo.${NC}"
        echo ""
        echo -e "  [${YELLOW}2${NC}] 💥 ${RED}${BOLD}Desinstalar aplicación y BORRAR TODOS los datos${NC}"
        echo -e "      ${GRAY}└─ Se asegura un respaldo previo y luego se purgan por${NC}"
        echo -e "      ${GRAY}   completo carpetas de usuario, configuraciones y tokens.${NC}"
        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Cancelar y volver atrás ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_mode
        opt_mode=$(read_menu_input "${BOLD}👉 Selecciona una opción [1/2/0]: ${NC}")

        if [ "$opt_mode" = "0" ] || [ "$opt_mode" = "__BACK__" ] || [ "$opt_mode" = "b" ] || [ "$opt_mode" = "q" ]; then
            return 0
        fi

        if [ -z "$opt_mode" ]; then
            continue
        fi

        if [ "$opt_mode" = "1" ] || [ "$opt_mode" = "2" ]; then
            local delete_data=0
            [ "$opt_mode" = "2" ] && delete_data=1

            echo ""
            echo -e "${BLUE}$(get_div_bar)${NC}"
            echo -e "${YELLOW}  🗑️ Desinstalando: ${BOLD}${pname}${NC}"
            echo -e "${BLUE}$(get_div_bar)${NC}"
            echo ""

            if [ "$delete_data" = "1" ]; then
                # Respaldo silencioso de seguridad antes de borrar
                do_silent_backup

                echo -e "${CYAN}[*] Purgando configuraciones, cachés y datos locales...${NC}"
                if [ "$slug" = "vscode" ]; then
                    rm -rf "$HOME/.config/Code - OSS" "$HOME/.vscode-oss" "$HOME/.config/Code" 2>/dev/null || true
                elif [ "$slug" = "zen-browser" ]; then
                    rm -rf "$HOME/.config/zen" "$HOME/.zen" "$HOME/.cache/zen" 2>/dev/null || true
                else
                    rm -rf "$HOME/.config/$slug" "$HOME/.$slug" "$HOME/.local/share/$slug" "$HOME/.cache/$slug" 2>/dev/null || true
                fi
            else
                echo -e "${GREEN}[*] Conservando credenciales, configuraciones y datos de usuario intactos.${NC}"
            fi

            # Detener procesos
            echo -e "${CYAN}[*] Deteniendo procesos de $pname...${NC}"
            pkill -9 -f "$slug" 2>/dev/null || true
            if [ "$slug" = "vscode" ]; then
                pkill -9 -f "code-oss" 2>/dev/null || true
            fi

            # Eliminar binarios
            echo -e "${CYAN}[*] Eliminando ejecutables de $PREFIX/bin...${NC}"
            rm -f "$PREFIX/bin/$slug" "$PREFIX/bin/${slug//-/}" 2>/dev/null || true
            if [ "$slug" = "vscode" ]; then
                rm -f "$PREFIX/bin/code-oss" "$PREFIX/bin/vscode" 2>/dev/null || true
            fi

            # Retirar lanzador del escritorio
            echo -e "${CYAN}[*] Retirando iconos del escritorio y menús...${NC}"
            remove_desktop_launcher "$slug"

            # Desinstalar paquetes si aplica
            echo -e "${CYAN}[*] Verificando paquetes del sistema...${NC}"
            if [ "$slug" = "vscode" ]; then
                pkg uninstall -y code-oss >/dev/null 2>&1 || true
            elif [ "$slug" = "zen-browser" ]; then
                pkg uninstall -y zen-browser >/dev/null 2>&1 || true
            else
                pkg uninstall -y "$slug" >/dev/null 2>&1 || true
            fi

            # Limpiar registro persistente
            if [ -f "$INSTALLED_REGISTRY" ]; then
                grep -Fvx "$slug" "$INSTALLED_REGISTRY" > "$INSTALLED_REGISTRY.tmp" 2>/dev/null || true
                mv "$INSTALLED_REGISTRY.tmp" "$INSTALLED_REGISTRY" 2>/dev/null || true
            fi

            echo ""
            echo -e "${GREEN}======================================================${NC}"
            if [ "$delete_data" = "1" ]; then
                echo -e "${GREEN}  ✔ ${pname} y todos sus datos han sido eliminados.${NC}"
            else
                echo -e "${GREEN}  ✔ ${pname} desinstalado (datos y credenciales conservados).${NC}"
            fi
            echo -e "${GREEN}======================================================${NC}"
            echo ""

            pause_menu "Presiona ENTER o borrar para continuar..."
            return 0
        fi
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE DESINSTALACIÓN (Solo muestra lo que está instalado)
# ------------------------------------------------------------------------------
menu_desinstalar() {
    while true; do
        refresh_installed_cache

        local INSTALLED_LIST=()
        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if is_program_installed "$p"; then
                INSTALLED_LIST+=("$p")
            fi
        done

        clear
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo -e "${RED}  🗑️ DESINSTALADOR DE PROGRAMAS (SISTEMA LOCAL)${NC}"
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo ""

        if [ "${#INSTALLED_LIST[@]}" -eq 0 ]; then
            echo -e "${YELLOW}  ℹ️ No se detectaron programas instalados actualmente.${NC}"
            echo ""
            echo -e "  [${YELLOW}0${NC}] ↩️ Volver al menú principal ${GRAY}(o pulsa borrar)${NC}"
            echo ""
            pause_menu "Pulsa ENTER o borrar para volver..."
            return 0
        fi

        echo -e "Programas detectados en el sistema (${GREEN}${#INSTALLED_LIST[@]} instalados${NC}):"
        echo ""
        local k=1
        for p in "${INSTALLED_LIST[@]}"; do
            get_program_meta "$p"
            local pname="$_META_NAME"
            local ptagline="$_META_TAGLINE"
            if [ -z "$pname" ]; then
                local fname="${p##*/}"
                local slug="${fname#instalar-}"
                pname="${slug%.sh}"
            fi

            if [ -n "$ptagline" ]; then
                echo -e "  [${YELLOW}$k${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}"
            else
                echo -e "  [${YELLOW}$k${NC}] 📦 ${BOLD}${pname}${NC}"
            fi
            ((k++))
        done

        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Volver al menú principal ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_sel
        opt_sel=$(read_menu_input "${BOLD}👉 Selecciona un programa para desinstalar: ${NC}")

        if [ "$opt_sel" = "0" ] || [ "$opt_sel" = "__BACK__" ] || [ "$opt_sel" = "b" ] || [ "$opt_sel" = "q" ]; then
            return 0
        fi

        if [ -z "$opt_sel" ]; then
            continue
        fi

        if [[ "$opt_sel" =~ ^[0-9]+$ ]] && [ "$opt_sel" -ge 1 ] && [ "$opt_sel" -le "${#INSTALLED_LIST[@]}" ]; then
            local target_p="${INSTALLED_LIST[$((opt_sel-1))]}"
            prompt_and_uninstall "$target_p"
        fi
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE BÚSQUEDA RÁPIDA (Bucle interactivo con soporte de atrás)
# ------------------------------------------------------------------------------
menu_buscar() {
    while true; do
        clear
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo -e "${GREEN}  🔍 BÚSQUEDA GLOBAL DE PROGRAMAS (+110 DISPONIBLES)${NC}"
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo ""
        echo -e "Escribe el nombre o tema a buscar ${GRAY}(o '0' / borrar para volver al menú)${NC}:"
        echo ""
        local query
        query=$(read_menu_input "${BOLD}👉 Buscar: ${NC}")

        if [ -z "$query" ] || [ "$query" = "__BACK__" ] || [ "$query" = "0" ] || [ "$query" = "q" ] || [ "$query" = "Q" ]; then
            return 0
        fi

        echo ""
        echo -e "${CYAN}[*] Buscando resultados para: '$query'...${NC}"
        echo ""

        refresh_installed_cache

        local MATCHES=()
        declare -A MATCH_MAP=()
        while IFS= read -r f; do
            [ -n "$f" ] && MATCH_MAP["$f"]=1
        done < <(grep -l -i "$query" "$SCRIPT_DIR"/*/instalar-*.sh 2>/dev/null || true)

        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if [ -n "${MATCH_MAP["$p"]}" ] || [[ "${p##*/}" =~ $query ]]; then
                MATCHES+=("$p")
            fi
        done

        if [ "${#MATCHES[@]}" -eq 0 ]; then
            echo -e "${YELLOW}  ℹ️ No se encontraron coincidencias para: '$query'.${NC}"
            echo ""
            pause_menu "Presiona ENTER o borrar para buscar de nuevo..."
            continue
        fi

        while true; do
            clear
            echo -e "${BLUE}$(get_div_bar)${NC}"
            echo -e "${GREEN}  🔍 RESULTADOS PARA: '$query' (${#MATCHES[@]} coincidencias)${NC}"
            echo -e "${BLUE}$(get_div_bar)${NC}"
            echo ""

            local m=1
            for p in "${MATCHES[@]}"; do
                get_program_meta "$p"
                local pname="$_META_NAME"
                local ptagline="$_META_TAGLINE"
                local inst_tag=""
                if [ -z "$pname" ]; then
                    local fname="${p##*/}"
                    local s="${fname#instalar-}"
                    pname="${s%.sh}"
                fi

                if is_program_installed "$p"; then
                    inst_tag=" ${GREEN}[✓ INSTALADO]${NC}"
                fi

                if [ -n "$ptagline" ]; then
                    echo -e "  [${YELLOW}$m${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}${inst_tag}"
                else
                    echo -e "  [${YELLOW}$m${NC}] 📦 ${BOLD}${pname}${NC}${inst_tag}"
                fi
                ((m++))
            done

            echo ""
            echo -e "  [${YELLOW}0${NC}] ↩️ Volver a buscar ${GRAY}(o pulsa borrar)${NC}"
            echo ""
            local opt_b
            opt_b=$(read_menu_input "${BOLD}👉 Selecciona un número para gestionar/instalar: ${NC}")

            if [ "$opt_b" = "0" ] || [ "$opt_b" = "__BACK__" ] || [ "$opt_b" = "b" ] || [ "$opt_b" = "q" ] || [ -z "$opt_b" ]; then
                break
            fi

            if [[ "$opt_b" =~ ^[0-9]+$ ]] && [ "$opt_b" -ge 1 ] && [ "$opt_b" -le "${#MATCHES[@]}" ]; then
                local target_script="${MATCHES[$((opt_b-1))]}"
                local fname="${target_script##*/}"
                local slug="${fname#instalar-}"
                slug="${slug%.sh}"

                get_program_meta "$target_script"
                local target_name="$_META_NAME"
                [ -z "$target_name" ] && target_name="$slug"

                if is_program_installed "$target_script"; then
                    echo ""
                    echo -e "${YELLOW}[!] ${target_name} ya está instalado en este sistema.${NC}"
                    echo -e "  [${YELLOW}1${NC}] ⚡ Reinstalar / Actualizar"
                    echo -e "  [${YELLOW}2${NC}] 🗑️ Desinstalar programa"
                    echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás ${GRAY}(o pulsa borrar)${NC}"
                    echo ""
                    local sub_opt
                    sub_opt=$(read_menu_input "${BOLD}👉 Opción [1/2/0]: ${NC}")
                    if [ "$sub_opt" = "1" ]; then
                        echo ""
                        echo -e "${CYAN}⚡ Reinstalando: ${target_name}...${NC}"
                        echo ""
                        if run_installer_script "$target_script" "$target_name"; then
                            sync_desktop_launcher "$slug"
                            echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                            echo -e "\n${GREEN}[✓] ¡${target_name} reinstalado con éxito!${NC}"
                        else
                            echo -e "\n${RED}[!] La reinstalación de ${target_name} no se completó.${NC}"
                        fi
                        pause_menu "Presiona ENTER o borrar para continuar..."
                    elif [ "$sub_opt" = "2" ]; then
                        prompt_and_uninstall "$target_script"
                    fi
                else
                    echo ""
                    echo -e "${CYAN}⚡ Instalando: ${target_name}...${NC}"
                    echo ""
                    if run_installer_script "$target_script" "$target_name"; then
                        sync_desktop_launcher "$slug"
                        echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                        echo -e "\n${GREEN}[✓] ¡${target_name} instalado con éxito!${NC}"
                    else
                        echo -e "\n${RED}[!] La instalación de ${target_name} no se completó.${NC}"
                    fi
                    echo ""
                    pause_menu "Presiona ENTER o borrar para continuar..."
                fi
                refresh_installed_cache
            fi
        done
    done
}

# ------------------------------------------------------------------------------
# MENÚ DE CATEGORÍA
# ------------------------------------------------------------------------------
menu_categoria() {
    local sel_cat="$1"
    local sel_path="$SCRIPT_DIR/$sel_cat"

    while true; do
        refresh_installed_cache

        clear
        local cat_title="${sel_cat#[0-9]*-}"
        cat_title="${cat_title//_/ }"

        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo -e "${GREEN}  📁 CATEGORÍA: $cat_title${NC}"
        echo -e "${BLUE}$(get_div_bar)${NC}"
        echo ""

        local PROGRAMS=()
        local j=1
        for p in "$sel_path"/instalar-*.sh; do
            [ -f "$p" ] || continue
            PROGRAMS+=("$p")

            get_program_meta "$p"
            local pname="$_META_NAME"
            local ptagline="$_META_TAGLINE"
            local inst_tag=""
            if [ -z "$pname" ]; then
                local fname="${p##*/}"
                local s="${fname#instalar-}"
                pname="${s%.sh}"
            fi

            if is_program_installed "$p"; then
                inst_tag=" ${GREEN}[✓ INSTALADO]${NC}"
            fi

            if [ -n "$ptagline" ]; then
                echo -e "  [${YELLOW}$j${NC}] 📦 ${BOLD}${pname}${NC} ${CYAN}(${ptagline})${NC}${inst_tag}"
            else
                echo -e "  [${YELLOW}$j${NC}] 📦 ${BOLD}${pname}${NC}${inst_tag}"
            fi
            ((j++))
        done

        echo ""
        echo -e "  [${YELLOW}0${NC}] ↩️ Volver a categorías ${GRAY}(o pulsa borrar)${NC}"
        echo ""
        local opt_prog
        opt_prog=$(read_menu_input "${BOLD}👉 Selecciona un programa para instalar o gestionar: ${NC}")

        if [ "$opt_prog" = "0" ] || [ "$opt_prog" = "__BACK__" ] || [ "$opt_prog" = "b" ] || [ "$opt_prog" = "q" ]; then
            break
        fi

        if [ -z "$opt_prog" ]; then
            continue
        fi

        if [[ "$opt_prog" =~ ^[0-9]+$ ]] && [ "$opt_prog" -ge 1 ] && [ "$opt_prog" -le "${#PROGRAMS[@]}" ]; then
            local target_script="${PROGRAMS[$((opt_prog-1))]}"
            local fname="${target_script##*/}"
            local slug="${fname#instalar-}"
            slug="${slug%.sh}"

            get_program_meta "$target_script"
            local target_name="$_META_NAME"
            [ -z "$target_name" ] && target_name="$slug"

            if is_program_installed "$target_script"; then
                echo ""
                echo -e "${YELLOW}[!] ${target_name} ya está instalado en este sistema.${NC}"
                echo -e "  [${YELLOW}1${NC}] ⚡ Reinstalar / Actualizar"
                echo -e "  [${YELLOW}2${NC}] 🗑️ Desinstalar programa"
                echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás ${GRAY}(o pulsa borrar)${NC}"
                echo ""
                local sub_action
                sub_action=$(read_menu_input "${BOLD}👉 Opción [1/2/0]: ${NC}")
                if [ "$sub_action" = "1" ]; then
                    echo ""
                    echo -e "${CYAN}⚡ Reinstalando: ${target_name}...${NC}"
                    echo ""
                    if run_installer_script "$target_script" "$target_name"; then
                        sync_desktop_launcher "$slug"
                        echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                        echo -e "\n${GREEN}[✓] ¡${target_name} reinstalado con éxito!${NC}"
                    else
                        echo -e "\n${RED}[!] La reinstalación de ${target_name} no se completó.${NC}"
                    fi
                    pause_menu "Presiona ENTER o borrar para continuar..."
                elif [ "$sub_action" = "2" ]; then
                    prompt_and_uninstall "$target_script"
                fi
            else
                echo ""
                echo -e "${CYAN}⚡ Instalando: ${target_name}...${NC}"
                echo ""
                if run_installer_script "$target_script" "$target_name"; then
                    sync_desktop_launcher "$slug"
                    echo "$slug" >> "$INSTALLED_REGISTRY" 2>/dev/null || true
                    echo -e "\n${GREEN}[✓] ¡${target_name} instalado con éxito!${NC}"
                else
                    echo -e "\n${RED}[!] La instalación de ${target_name} no se completó.${NC}"
                fi
                echo ""
                pause_menu "Presiona ENTER o borrar para continuar..."
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# BUCLE PRINCIPAL DEL CENTRO DE SOFTWARE
# ------------------------------------------------------------------------------
run_main_menu() {
    local banner_frame=0
    while true; do
        refresh_installed_cache

        # Contar programas instalados con caché en memoria ultra-rápida (cero subshells)
        local inst_count=0
        for p in "$SCRIPT_DIR"/*/instalar-*.sh; do
            [ -f "$p" ] || continue
            if is_program_installed "$p"; then
                ((inst_count++))
            fi
        done

        clear
        local t_lines=$(tput lines 2>/dev/null || echo 24)
        local t_cols=$(get_ui_cols)

        # 1. Caja Superior: Banner CSAN2 Independiente
        # Solo mostrar banner si la terminal tiene al menos 24 líneas para que
        # ambas cajas (banner + menú + prompt) quepan simultáneamente sin scroll.
        if [ "$t_lines" -ge 24 ]; then
            local max_b_rows=4
            [ "$t_lines" -ge 30 ] && max_b_rows=6
            if command -v code-stack-ascii >/dev/null 2>&1; then
                python3 "$(command -v code-stack-ascii)" banner "$banner_frame" --boxed --cols "$t_cols" --rows "$max_b_rows" 2>/dev/null || true
            elif [ -f "$REPO_DIR/bin/code-stack-ascii" ]; then
                python3 "$REPO_DIR/bin/code-stack-ascii" banner "$banner_frame" --boxed --cols "$t_cols" --rows "$max_b_rows" 2>/dev/null || true
            fi
            ((banner_frame=(banner_frame+4)%120))
            echo ""
        fi

        CATEGORIES=()
        local -a CAT_ITEMS=()
        local i=1
        for d in "$SCRIPT_DIR"/*/; do
            [ -d "$d" ] || continue
            local cname="${d%/}"
            cname="${cname##*/}"
            CATEGORIES+=("$cname")
            local cname_clean="${cname#[0-9]*-}"
            cname_clean="${cname_clean//_/ }"

            local cat_files=("$d"instalar-*.sh)
            local count=0
            [ -e "${cat_files[0]}" ] && count="${#cat_files[@]}"

            CAT_ITEMS+=(" [${i}] 📁 ${cname_clean} (${count})")
            ((i++))
        done

        # 2. Caja Inferior: Menú de Software Independiente
        local ascii_bin=""
        if command -v code-stack-ascii >/dev/null 2>&1; then
            ascii_bin="$(command -v code-stack-ascii)"
        elif [ -f "$REPO_DIR/bin/code-stack-ascii" ]; then
            ascii_bin="$REPO_DIR/bin/code-stack-ascii"
        fi

        if [ -n "$ascii_bin" ]; then
            local -a menu_cmd=(python3 "$ascii_bin" menu-box --cols "$t_cols" \
                --title "📦 CODE STACK SH • CENTRO DE SOFTWARE OFICIAL" \
                --subtitle "«La libertad de programar sin necesidad de una PC»")
            for item in "${CAT_ITEMS[@]}"; do
                menu_cmd+=(--item "$item")
            done
            menu_cmd+=(--action " [D] 🗑️ Desinstalar ($inst_count)" \
                       --action " [G] ⚡ Calibrar GPU" \
                       --action " [B] 🔍 Buscar (+110 apps)" \
                       --action " [0] 🚪 Salir")
            "${menu_cmd[@]}"
        else
            echo -e "${BLUE}$(get_box_top)${NC}"
            for item in "${CAT_ITEMS[@]}"; do
                echo -e " $item"
            done
            echo -e "${BLUE}$(get_box_bot)${NC}"
        fi
        echo ""

        local opt_cat
        opt_cat=$(read_menu_input "${BOLD}👉 Selecciona una opción: ${NC}")

        if [ "$opt_cat" = "0" ] || [ "$opt_cat" = "__BACK__" ] || [ "$opt_cat" = "q" ] || [ "$opt_cat" = "Q" ]; then
            echo -e "\n${YELLOW}[*] Saliendo del Centro de Software...${NC}\n" >&2
            exit 0
        fi

        if [ -z "$opt_cat" ]; then
            continue
        fi

        if [ "$opt_cat" = "d" ] || [ "$opt_cat" = "D" ]; then
            menu_desinstalar
            continue
        fi

        if [ "$opt_cat" = "b" ] || [ "$opt_cat" = "B" ]; then
            menu_buscar
            continue
        fi

        if [ "$opt_cat" = "g" ] || [ "$opt_cat" = "G" ]; then
            if command -v gpu-optimizer >/dev/null 2>&1; then
                gpu-optimizer --reprobe
            elif [ -f "$REPO_DIR/bin/gpu-optimizer" ]; then
                "$REPO_DIR/bin/gpu-optimizer" --reprobe
            fi
            echo -ne "${BOLD}Presiona ENTER para continuar...${NC}" >&2
            read_menu_input "" >/dev/null
            continue
        fi

        if [[ "$opt_cat" =~ ^[0-9]+$ ]] && [ "$opt_cat" -ge 1 ] && [ "$opt_cat" -le "${#CATEGORIES[@]}" ]; then
            local sel_cat="${CATEGORIES[$((opt_cat-1))]}"
            menu_categoria "$sel_cat"
        fi
    done
}

# Ejecutar bucle principal solo cuando se ejecuta directamente el script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main_menu
fi
