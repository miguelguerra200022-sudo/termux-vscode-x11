#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# gestor-juegos.sh: Biblioteca y Gestor de Juegos/ROMs para Emuladores
# Code Stack Sh • Emulación y Retro-Gaming en Android ARM64
# ==============================================================================

cleanup_terminal() {
    stty sane 2>/dev/null || true
    echo -ne "\033[?25h\033[0m" 2>/dev/null || true
}
trap cleanup_terminal EXIT HUP INT TERM

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
GRAY='\033[0;90m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

EMU="${1:-}"

# Asegurar directorios de juegos
BASE_GAMES="$HOME/RetroGames"
mkdir -p "$BASE_GAMES"
if [ -d "/storage/emulated/0" ] && [ -w "/storage/emulated/0" ]; then
    mkdir -p "/storage/emulated/0/RetroGames" 2>/dev/null || true
fi

get_ui_cols() {
    local c
    c=$(tput cols 2>/dev/null || echo 80)
    c=$((c - 2))
    if [ "$c" -lt 40 ]; then c=40; elif [ "$c" -gt 84 ]; then c=84; fi
    echo "$c"
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

# Lector de entrada con soporte nativo de backspace
read_input() {
    local prompt="$1"
    local input=""
    local char=""
    echo -ne "$prompt" >&2
    if [ ! -t 0 ]; then
        read -r input || return 0
        echo "$input"
        return 0
    fi
    local old_stty
    old_stty=$(stty -g 2>/dev/null || true)
    stty -icanon -echo min 1 time 0 2>/dev/null || true
    while IFS= read -r -s -n 1 char; do
        if [ -z "$char" ] || [ "$char" = $'\r' ] || [ "$char" = $'\n' ]; then
            stty "$old_stty" 2>/dev/null || true
            echo "" >&2
            echo "$input"
            return 0
        fi
        if [ "$char" = $'\x7f' ] || [ "$char" = $'\b' ]; then
            if [ -z "$input" ]; then
                stty "$old_stty" 2>/dev/null || true
                echo "" >&2
                echo "__BACK__"
                return 0
            else
                input="${input%?}"
                echo -ne "\b \b" >&2
            fi
        else
            input="${input}${char}"
            echo -ne "$char" >&2
        fi
    done
    stty "$old_stty" 2>/dev/null || true
    echo "$input"
}

# ------------------------------------------------------------------------------
# BASE DE DATOS DE JUEGOS Y METADATOS
# ------------------------------------------------------------------------------
get_games_list() {
    local console="$1"
    case "$console" in
        ppsspp)
            cat << 'EOF'
gow_chains|God of War: Chains of Olympus|1.1 GB|Acción / Hack & Slash|gow_chains.iso|https://archive.org/download/psp-god-of-war-chains/gow_chains.iso
gta_vice_city|Grand Theft Auto: Vice City Stories|850 MB|Mundo Abierto / Acción|gta_vcs.cso|https://archive.org/download/psp-gta-vcs/gta_vcs.cso
tekken6|Tekken 6|720 MB|Lucha 3D|tekken6.cso|https://archive.org/download/psp-tekken-6/tekken6.cso
persona3|Persona 3 Portable|980 MB|JRPG / Rol|p3p.iso|https://archive.org/download/psp-persona-3-portable/p3p.iso
nfs_mostwanted|Need for Speed: Most Wanted|450 MB|Carreras / Conducción|nfs_mw.cso|https://archive.org/download/psp-nfs-mw/nfs_mw.cso
dbz_shinbudokai|Dragon Ball Z: Shin Budokai|280 MB|Lucha Anime|dbz_sb.cso|https://archive.org/download/psp-dbz-sb/dbz_sb.cso
crisis_core|Crisis Core: Final Fantasy VII|1.0 GB|Acción RPG|crisis_core.iso|https://archive.org/download/psp-crisis-core/crisis_core.iso
daxter|Daxter|950 MB|Plataformas 3D|daxter.cso|https://archive.org/download/psp-daxter/daxter.cso
monster_hunter|Monster Hunter Freedom Unite|780 MB|Caza / Acción RPG|mhfu.cso|https://archive.org/download/psp-mhfu/mhfu.cso
lumines|Lumines Puzzle Fusion|150 MB|Puzles / Ritmo|lumines.cso|https://archive.org/download/psp-lumines/lumines.cso
EOF
            ;;
        mgba)
            cat << 'EOF'
zelda_minish|The Legend of Zelda: The Minish Cap|16 MB|Aventura / Acción|zelda_minish.gba|https://archive.org/download/gba-zelda-minish-cap/zelda_minish.gba
pokemon_emerald|Pokemon Edicion Esmeralda (ES)|16 MB|RPG / Aventura|pokemon_emerald_es.gba|https://archive.org/download/gba-pokemon-esmeralda-es/pokemon_emerald_es.gba
pokemon_firered|Pokemon Edicion Rojo Fuego (ES)|16 MB|RPG / Aventura|pokemon_firered_es.gba|https://archive.org/download/gba-pokemon-rojo-fuego-es/pokemon_firered_es.gba
metroid_fusion|Metroid Fusion|8 MB|Metroidvania / Acción|metroid_fusion.gba|https://archive.org/download/gba-metroid-fusion/metroid_fusion.gba
castlevania_aria|Castlevania: Aria of Sorrow|8 MB|Acción / Aventura|castlevania_aria.gba|https://archive.org/download/gba-castlevania-aria/castlevania_aria.gba
mario_kart|Mario Kart: Super Circuit|8 MB|Carreras Arcade|mario_kart.gba|https://archive.org/download/gba-mario-kart/mario_kart.gba
golden_sun|Golden Sun|16 MB|JRPG Clásico|golden_sun.gba|https://archive.org/download/gba-golden-sun/golden_sun.gba
advance_wars|Advance Wars|8 MB|Estrategia Táctica|advance_wars.gba|https://archive.org/download/gba-advance-wars/advance_wars.gba
fire_emblem|Fire Emblem: The Sacred Stones|16 MB|Rol Táctico|fire_emblem.gba|https://archive.org/download/gba-fire-emblem/fire_emblem.gba
megaman_bn|Mega Man Battle Network|8 MB|Acción / Estrategia|megaman_bn.gba|https://archive.org/download/gba-megaman-bn/megaman_bn.gba
EOF
            ;;
        retroarch)
            cat << 'EOF'
smw|Super Mario World (SNES)|4 MB|Plataformas|smw.sfc|https://archive.org/download/snes-super-mario-world/smw.sfc
chrono_trigger|Chrono Trigger (SNES)|6 MB|JRPG Legendario|chrono_trigger.sfc|https://archive.org/download/snes-chrono-trigger/chrono_trigger.sfc
zelda_alttp|Zelda: A Link to the Past (SNES)|4 MB|Acción / Aventura|zelda_alttp.sfc|https://archive.org/download/snes-zelda-alttp/zelda_alttp.sfc
dkc|Donkey Kong Country (SNES)|4 MB|Plataformas|dkc.sfc|https://archive.org/download/snes-donkey-kong-country/dkc.sfc
super_metroid|Super Metroid (SNES)|4 MB|Metroidvania|super_metroid.sfc|https://archive.org/download/snes-super-metroid/super_metroid.sfc
sonic2|Sonic the Hedgehog 2 (Genesis)|4 MB|Velocidad / Plataformas|sonic2.md|https://archive.org/download/genesis-sonic-2/sonic2.md
sf2_turbo|Street Fighter II Turbo (SNES)|4 MB|Lucha 2D|sf2_turbo.sfc|https://archive.org/download/snes-street-fighter-2/sf2_turbo.sfc
megaman_x|Mega Man X (SNES)|4 MB|Acción / Plataformas|megaman_x.sfc|https://archive.org/download/snes-megaman-x/megaman_x.sfc
castlevania_sotn|Castlevania: Symphony of the Night (PS1)|450 MB|Metroidvania|castlevania_sotn.chd|https://archive.org/download/ps1-castlevania-sotn/castlevania_sotn.chd
EOF
            ;;
        duckstation)
            cat << 'EOF'
re2|Resident Evil 2 (Dual Shock)|750 MB|Survival Horror|re2.chd|https://archive.org/download/ps1-resident-evil-2/re2.chd
silent_hill|Silent Hill|350 MB|Terror Psicológico|silent_hill.chd|https://archive.org/download/ps1-silent-hill/silent_hill.chd
mgs|Metal Gear Solid|750 MB|Sigilo / Espionaje|mgs.chd|https://archive.org/download/ps1-metal-gear-solid/mgs.chd
crash3|Crash Bandicoot 3: Warped|480 MB|Plataformas 3D|crash3.chd|https://archive.org/download/ps1-crash-3/crash3.chd
tekken3|Tekken 3|450 MB|Lucha 3D|tekken3.chd|https://archive.org/download/ps1-tekken-3/tekken3.chd
spyro|Spyro the Dragon|420 MB|Aventura 3D|spyro.chd|https://archive.org/download/ps1-spyro/spyro.chd
gt2|Gran Turismo 2|600 MB|Simulador de Conducción|gt2.chd|https://archive.org/download/ps1-gran-turismo-2/gt2.chd
EOF
            ;;
        dosbox-x)
            cat << 'EOF'
doom|Doom (1993 Shareware)|6 MB|FPS Clásico 3D|doom.zip|https://archive.org/download/DoomShareware_1020/doom1_9.zip
prince_persia|Prince of Persia (1989)|2 MB|Aventura / Plataformas|prince.zip|https://archive.org/download/PrinceOfPersia_1020/prince.zip
duke3d|Duke Nukem 3D (Shareware)|15 MB|FPS / Acción|duke3d.zip|https://archive.org/download/DukeNukem3D_shareware/3dduke.zip
wolf3d|Wolfenstein 3D (Shareware)|3 MB|FPS Pionero|wolf3d.zip|https://archive.org/download/Wolfenstein3D_shareware/1wolf14.zip
simcity2000|SimCity 2000|8 MB|Simulador de Ciudades|sc2000.zip|https://archive.org/download/SimCity2000_dos/sc2000.zip
keen|Commander Keen: Marooned on Mars|2 MB|Plataformas Clásico|keen1.zip|https://archive.org/download/CommanderKeenMaroonedOnMars_1020/1keen.zip
EOF
            ;;
        scummvm)
            cat << 'EOF'
bass|Beneath a Steel Sky (Freeware Oficial)|70 MB|Cyberpunk / Aventura|bass.zip|https://downloads.scummvm.org/frs/extras/Beneath%20a%20Steel%20Sky/bass-cd-1.2.zip
fotaq|Flight of the Amazon Queen (Freeware Oficial)|35 MB|Aventura / Comedia|fotaq.zip|https://downloads.scummvm.org/frs/extras/Flight%20of%20the%20Amazon%20Queen/FOTAQ_Talkie-1.1.zip
lure|Lure of the Temptress (Freeware Oficial)|12 MB|Fantasía Medieval|lure.zip|https://downloads.scummvm.org/frs/extras/Lure%20of%20the%20Temptress/lure-1.1.zip
drascula|Drascula: Vampire Strikes Back (Freeware)|30 MB|Comedia / Vampiros|drascula.zip|https://downloads.scummvm.org/frs/extras/Drascula%20The%20Vampire%20Strikes%20Back/drascula-1.0.zip
monkey1|The Secret of Monkey Island|15 MB|Piratas / Aventura|monkey1.zip|https://archive.org/download/scummvm-monkey1/monkey1.zip
dott|Day of the Tentacle|25 MB|Viajes en el Tiempo|dott.zip|https://archive.org/download/scummvm-dott/dott.zip
EOF
            ;;
        *)
            echo ""
            ;;
    esac
}

get_emu_name() {
    case "$1" in
        ppsspp) echo "Sony PlayStation Portable (PSP)" ;;
        mgba) echo "Nintendo Game Boy Advance (GBA)" ;;
        retroarch) echo "RetroArch (Multiconsola Clásica)" ;;
        duckstation) echo "Sony PlayStation 1 (PS1)" ;;
        dosbox-x) echo "MS-DOS PC Clásico (DOSBox-X)" ;;
        scummvm) echo "ScummVM (Aventuras Gráficas)" ;;
        *) echo "$1" ;;
    esac
}

get_emu_bin() {
    case "$1" in
        ppsspp) command -v ppsspp 2>/dev/null || command -v ppsspp-sdl 2>/dev/null || echo "ppsspp" ;;
        mgba) command -v mgba-qt 2>/dev/null || command -v mgba 2>/dev/null || echo "mgba-qt" ;;
        retroarch) command -v retroarch 2>/dev/null || echo "retroarch" ;;
        duckstation) command -v duckstation-qt 2>/dev/null || command -v duckstation 2>/dev/null || echo "duckstation-qt" ;;
        dosbox-x) command -v dosbox-x 2>/dev/null || command -v dosbox 2>/dev/null || echo "dosbox-x" ;;
        scummvm) command -v scummvm 2>/dev/null || echo "scummvm" ;;
        *) echo "$1" ;;
    esac
}

# ------------------------------------------------------------------------------
# MENÚ DEL CATÁLOGO POR CONSOLA
# ------------------------------------------------------------------------------
menu_consola() {
    local console="$1"
    local emu_title=$(get_emu_name "$console")
    local rom_dir="$BASE_GAMES/$console"
    mkdir -p "$rom_dir"

    while true; do
        clear
        local t_cols=$(get_ui_cols)
        echo -e "${BLUE}$(get_box_top)${NC}"
        echo -e " ${BOLD}🎮 BIBLIOTECA DE JUEGOS • ${emu_title}${NC}"
        echo -e " ${GRAY}📁 Carpeta: ~/RetroGames/${console}/"
        if [ -d "/storage/emulated/0/RetroGames/${console}" ]; then
            echo -e " 📱 Celular: /storage/emulated/0/RetroGames/${console}/"
        fi
        echo -e "${BLUE}$(get_box_sep)${NC}"

        local -a GAME_IDS=()
        local -a GAME_NAMES=()
        local -a GAME_SIZES=()
        local -a GAME_GENRES=()
        local -a GAME_FILES=()
        local -a GAME_URLS=()

        local idx=1
        while IFS='|' read -r gid gname gsize ggenre gfile gurl; do
            [ -z "$gid" ] && continue
            GAME_IDS+=("$gid")
            GAME_NAMES+=("$gname")
            GAME_SIZES+=("$gsize")
            GAME_GENRES+=("$ggenre")
            GAME_FILES+=("$gfile")
            GAME_URLS+=("$gurl")

            local status_badge="[  Disponible ]"
            local full_path="$rom_dir/$gfile"
            if [ -f "$full_path" ] || [ -f "${full_path%.*}.iso" ] || [ -f "${full_path%.*}.cso" ] || [ -f "${full_path%.*}.gba" ] || [ -d "$rom_dir/$gid" ]; then
                status_badge="${GREEN}[✓ Instalado ]${NC}"
            fi

            printf " [${YELLOW}%2d${NC}] %-34.34s ${GRAY}%-9s${NC} %b\n" "$idx" "$gname" "($gsize)" "$status_badge"
            ((idx++))
        done < <(get_games_list "$console")

        echo -e "${BLUE}$(get_box_sep)${NC}"
        echo -e " [${CYAN}P${NC}] ▶️ Iniciar Emulador ahora   [${YELLOW}0${NC}] ↩️ Volver atrás ${GRAY}(o pulsa borrar)${NC}"
        echo -e "${BLUE}$(get_box_bot)${NC}"
        echo ""

        local opt
        opt=$(read_input "${BOLD}👉 Elige un juego [1-$((idx-1))] o comando: ${NC}")

        if [ "$opt" = "0" ] || [ "$opt" = "__BACK__" ] || [ "$opt" = "q" ] || [ "$opt" = "Q" ]; then
            return 0
        fi

        if [ "$opt" = "p" ] || [ "$opt" = "P" ]; then
            local emu_bin=$(get_emu_bin "$console")
            if ! command -v "$emu_bin" >/dev/null 2>&1; then
                echo -e "\n${RED}[!] El emulador $emu_bin no está instalado.${NC}"
                echo -e "    Instálalo primero desde el menú de programas."
                sleep 2
                continue
            fi
            echo -e "\n${GREEN}[*] Iniciando $emu_title...${NC}"
            DISPLAY="${DISPLAY:-:0}" "$emu_bin" >/dev/null 2>&1 &
            sleep 1
            return 0
        fi

        if [[ "$opt" =~ ^[0-9]+$ ]] && [ "$opt" -ge 1 ] && [ "$opt" -lt "$idx" ]; then
            local g_idx=$((opt-1))
            local target_id="${GAME_IDS[$g_idx]}"
            local target_name="${GAME_NAMES[$g_idx]}"
            local target_size="${GAME_SIZES[$g_idx]}"
            local target_file="${GAME_FILES[$g_idx]}"
            local target_url="${GAME_URLS[$g_idx]}"
            local rom_path="$rom_dir/$target_file"

            local is_installed=0
            if [ -f "$rom_path" ] || [ -f "${rom_path%.*}.iso" ] || [ -f "${rom_path%.*}.cso" ] || [ -f "${rom_path%.*}.gba" ] || [ -d "$rom_dir/$target_id" ]; then
                is_installed=1
            fi

            echo ""
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BOLD}🎮 ${target_name}${NC}"
            echo -e "   ├─ Consola: ${emu_title}"
            echo -e "   ├─ Género:  ${GAME_GENRES[$g_idx]}"
            echo -e "   └─ Tamaño:  ${target_size}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""

            if [ "$is_installed" -eq 1 ]; then
                echo -e "${GREEN}[✓] Este juego ya se encuentra instalado.${NC}"
                echo -e "  [${YELLOW}1${NC}] ▶️ Jugar ahora"
                echo -e "  [${YELLOW}2${NC}] 🗑️ Eliminar juego para liberar espacio"
                echo -e "  [${YELLOW}3${NC}] 🖥️ Crear acceso directo en el Escritorio"
                echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás"
                echo ""
                local sub_act
                sub_act=$(read_input "${BOLD}👉 Opción [1/2/3/0]: ${NC}")
                if [ "$sub_act" = "1" ]; then
                    local emu_bin=$(get_emu_bin "$console")
                    if ! command -v "$emu_bin" >/dev/null 2>&1; then
                        echo -e "\n${RED}[!] Instala el emulador primero desde el menú.${NC}"
                        sleep 2
                        continue
                    fi
                    echo -e "\n${GREEN}[*] Lanzando $target_name en $emu_bin...${NC}"
                    DISPLAY="${DISPLAY:-:0}" "$emu_bin" "$rom_path" >/dev/null 2>&1 &
                    sleep 1
                    return 0
                elif [ "$sub_act" = "2" ]; then
                    echo -ne "⚠️ ¿Estás seguro de eliminar $target_name? (s/N): "
                    read -r confirm
                    if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
                        rm -f "$rom_path" "${rom_path%.*}.iso" "${rom_path%.*}.cso" "${rom_path%.*}.gba" 2>/dev/null || true
                        rm -rf "$rom_dir/$target_id" 2>/dev/null || true
                        echo -e "${GREEN}[✓] Juego eliminado con éxito.${NC}"
                        sleep 1
                    fi
                elif [ "$sub_act" = "3" ]; then
                    local desk_file="$HOME/Desktop/${target_id}.desktop"
                    local emu_bin=$(get_emu_bin "$console")
                    cat << EOF_DESK > "$desk_file"
[Desktop Entry]
Name=$target_name
Comment=Juego de $emu_title
Exec=$emu_bin "$rom_path"
Icon=/data/data/com.termux/files/usr/share/pixmaps/${console}.png
Terminal=false
Type=Application
Categories=Game;
EOF_DESK
                    chmod +x "$desk_file" 2>/dev/null || true
                    echo -e "${GREEN}[✓] Acceso directo creado en el Escritorio.${NC}"
                    sleep 1.5
                fi
            else
                echo -e "${YELLOW}[!] El juego está disponible en la nube.${NC}"
                echo -e "  [${YELLOW}1${NC}] 📥 Descargar e Instalar ($target_size)"
                echo -e "  [${YELLOW}0${NC}] ↩️ Volver atrás"
                echo ""
                local sub_act
                sub_act=$(read_input "${BOLD}👉 Opción [1/0]: ${NC}")
                if [ "$sub_act" = "1" ]; then
                    echo ""
                    echo -e "${CYAN}[*] Descargando ${target_name} (${target_size})...${NC}"
                    local tmp_download="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/${target_file}"
                    
                    if curl -# -L --connect-timeout 15 -A "Mozilla/5.0 (Android; Termux) Code-Stack-Client/1.0" "$target_url" -o "$tmp_download"; then
                        if [[ "$target_file" == *.zip ]]; then
                            echo -e "${CYAN}[*] Descomprimiendo archivos del juego...${NC}"
                            unzip -q -o "$tmp_download" -d "$rom_dir" 2>/dev/null || true
                            rm -f "$tmp_download" 2>/dev/null || true
                        else
                            mv "$tmp_download" "$rom_path" 2>/dev/null || true
                        fi
                        echo -e "${GREEN}[✓] ¡${target_name} instalado exitosamente en ${rom_dir}!${NC}"
                        if [ -d "/storage/emulated/0/RetroGames/${console}" ]; then
                            cp -rf "$rom_path" "/storage/emulated/0/RetroGames/${console}/" 2>/dev/null || true
                        fi
                        sleep 1.5
                    else
                        echo -e "${RED}[!] Error al descargar ${target_name}. Revisa tu conexión a internet.${NC}"
                        rm -f "$tmp_download" 2>/dev/null || true
                        sleep 2
                    fi
                fi
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# MENÚ PRINCIPAL DE CONSOLAS
# ------------------------------------------------------------------------------
if [ -n "$EMU" ]; then
    menu_consola "$EMU"
    exit 0
fi

while true; do
    clear
    echo -e "${BLUE}$(get_box_top)${NC}"
    echo -e " ${BOLD}🕹️ CODE STACK SH • GESTOR DE JUEGOS Y RETRO-GAMING${NC}"
    echo -e " ${GRAY}Selecciona la plataforma para explorar y descargar títulos clásicos${NC}"
    echo -e "${BLUE}$(get_box_sep)${NC}"
    echo -e " [${YELLOW}1${NC}] 🎮 Sony PlayStation Portable (PPSSPP)    [${CYAN}10 Títulos Clásicos${NC}]"
    echo -e " [${YELLOW}2${NC}] 🕹️ Nintendo Game Boy Advance (mGBA)       [${CYAN}10 Títulos Clásicos${NC}]"
    echo -e " [${YELLOW}3${NC}] 👾 Super Nintendo / RetroArch            [${CYAN} 9 Títulos Clásicos${NC}]"
    echo -e " [${YELLOW}4${NC}] 💿 Sony PlayStation 1 (DuckStation)       [${CYAN} 7 Títulos Clásicos${NC}]"
    echo -e " [${YELLOW}5${NC}] 💾 MS-DOS PC Clásico (DOSBox-X)           [${CYAN} 6 Títulos Clásicos${NC}]"
    echo -e " [${YELLOW}6${NC}] 🏝️ ScummVM Aventuras Gráficas             [${CYAN} 6 Títulos Clásicos${NC}]"
    echo -e "${BLUE}$(get_box_sep)${NC}"
    echo -e " [${YELLOW}0${NC}] 🚪 Salir al menú principal"
    echo -e "${BLUE}$(get_box_bot)${NC}"
    echo ""

    opt=$(read_input "${BOLD}👉 Selecciona una consola [1-6]: ${NC}")
    case "$opt" in
        1) menu_consola "ppsspp" ;;
        2) menu_consola "mgba" ;;
        3) menu_consola "retroarch" ;;
        4) menu_consola "duckstation" ;;
        5) menu_consola "dosbox-x" ;;
        6) menu_consola "scummvm" ;;
        0|__BACK__|q|Q) exit 0 ;;
        *) continue ;;
    esac
done
