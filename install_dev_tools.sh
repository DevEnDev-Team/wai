#!/bin/bash

# Script d'installation/désinstallation d'applications web
# Trello, ChatGPT, Claude AI, Notion, Github, Gemini

set -e

# Colors & Aesthetics (Sleek 2026 dark/violet theme)
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'

PRIMARY='\033[38;2;139;92;246m'   # Violet/Purple (#8B5CF6)
SECONDARY='\033[38;2;6;182;212m' # Cyan (#06B6D4)
SUCCESS='\033[38;2;16;185;129m'   # Emerald Green (#10B981)
WARNING='\033[38;2;245;158;11m'  # Amber/Yellow (#F59E0B)
DANGER='\033[38;2;239;68;68m'    # Rose Red (#EF4444)
MUTED='\033[38;2;107;114;128m'   # Gray (#6B7280)

# Icons
ICON_CHECK="✔"
ICON_CROSS="✖"
ICON_INFO="ℹ"
ICON_WARN="⚠"

# Print helpers
print_step() {
    local step_num="$1"
    local total_steps="$2"
    local desc="$3"
    echo -e "  ${PRIMARY}[${step_num}/${total_steps}]${NC} ${BOLD}${desc}${NC}"
}

print_success() {
    local msg="$1"
    echo -e "        ${SUCCESS}${ICON_CHECK} ${msg}${NC}"
}

print_error() {
    local msg="$1"
    echo -e "        ${DANGER}${ICON_CROSS} ${msg}${NC}"
}

print_header() {
    clear
    echo -e " ${PRIMARY}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e " ${PRIMARY}║${NC}   ${SECONDARY}${BOLD}⚡ W A I  //  W E B  A P P  I N S T A L L E R${NC}                ${PRIMARY}║${NC}"
    echo -e " ${PRIMARY}║${NC}   ${MUTED}Engineered for Linux | Version 2.0.0 (2026 Edition)${NC}        ${PRIMARY}║${NC}"
    echo -e " ${PRIMARY}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Configuration des applications (noms sans espaces)
declare -A APPS
APPS[trello_name]="Trello"
APPS[trello_url]="https://trello.com/"
APPS[trello_icon]="https://img.icons8.com/?size=100&id=vrmg1S9Hfbiv&format=png&color=000000"
APPS[trello_category]="Office;ProjectManagement;Productivity;"

APPS[chatgpt_name]="ChatGPT"
APPS[chatgpt_url]="https://chatgpt.com/"
APPS[chatgpt_icon]="https://img.icons8.com/?size=100&id=kTuxVYRKeKEY&format=png&color=000000"
APPS[chatgpt_category]="Network;Chat;Office;"

APPS[claude_name]="ClaudeAI"
APPS[claude_url]="https://claude.ai/"
APPS[claude_icon]="https://img.icons8.com/?size=100&id=zQjzFjPpT2Ek&format=png&color=000000"
APPS[claude_category]="Network;Chat;Office;"

APPS[notion_name]="Notion"
APPS[notion_url]="https://www.notion.so/"
APPS[notion_icon]="https://img.icons8.com/?size=100&id=wue74HqaylSJ&format=png&color=000000"
APPS[notion_category]="Office;Productivity;TextEditor;"

APPS[github_name]="Github"
APPS[github_url]="https://github.com/"
APPS[github_icon]="https://img.icons8.com/?size=100&id=52539&format=png&color=000000"
APPS[github_category]="Development;VersionControl;Collaboration;"


APPS[gemini_name]="Gemini"
APPS[gemini_url]="https://gemini.google.com/"
APPS[gemini_icon]="https://img.icons8.com/?size=100&id=BU7Clwq5bV9D&format=png&color=000000" # Icône Google/Gemini
APPS[gemini_category]="Network;Chat;Office;AI;"

APPS[tux_name]="Tux-It"
APPS[tux_repo]="git@github.com:DevEnDev-Team/tux-client.git"
APPS[tux_category]="Utility;Office;"


WINDOW_SIZE="1200x800"
# Fonction d'installation
install_app() {
    local app_key="$1"
    local app_name="${APPS[${app_key}_name]}"
    local app_url="${APPS[${app_key}_url]}"
    local icon_url="${APPS[${app_key}_icon]}"
    local categories="${APPS[${app_key}_category]}"
    
    # Chemins (noms de dossiers sans espaces)
    local app_name_lower=$(echo "$app_key" | tr '[:upper:]' '[:lower:]')
    local app_dir="/opt/$app_name"
    local script_path="$app_dir/${app_name_lower}.sh"
    local icon_path="$app_dir/${app_name_lower}.png"
    local desktop_file="/usr/share/applications/${app_name_lower}.desktop"
    local profile_dir="$HOME/.config/${app_name_lower}-profile"
    
    # Nom d'affichage (avec espace si nécessaire)
    local display_name="$app_name"
    if [ "$app_key" = "claude" ]; then
        display_name="Claude AI"
    elif [ "$app_key" = "tux" ]; then
        display_name="Tux-It"
    fi
    
    print_header
    echo -e "  ${SECONDARY}${BOLD}📥 PRÉPARATION DE L'INSTALLATION : ${display_name^^}${NC}"
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    echo
    
    # Vérifier si déjà installé
    local installed=false
    if [ "$app_key" = "tux" ]; then
        if [ -f "$HOME/.local/bin/tux-it" ]; then
            installed=true
        fi
    else
        if [ -d "$app_dir" ]; then
            installed=true
        fi
    fi
    
    if [ "$installed" = true ]; then
        echo -e "  ${WARNING}${ICON_WARN} $display_name est déjà installé sur votre système.${NC}"
        read -p "  Voulez-vous le réinstaller ? (y/N) : " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  ${MUTED}Installation annulée.${NC}"
            return
        fi
        uninstall_app_silent "$app_key"
    fi
    
    # Vérifier les dépendances
    if [ "$app_key" = "tux" ]; then
        echo -e "  ${MUTED}Vérification des dépendances pour Tux-It...${NC}"
        local missing_deps=()
        if ! command -v cmake &> /dev/null; then
            missing_deps+=("cmake")
        fi
        if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
            missing_deps+=("build-essential (g++)")
        fi
        if ! command -v git &> /dev/null; then
            missing_deps+=("git")
        fi
        if [ ${#missing_deps[@]} -ne 0 ]; then
            echo -e "  ${DANGER}${ICON_CROSS} Erreur : Dépendance(s) manquante(s) pour la compilation : ${missing_deps[*]}${NC}"
            echo -e "  Veuillez les installer avec : ${SECONDARY}sudo apt install build-essential cmake git qt6-base-dev qt6-base-private-dev${NC}"
            exit 1
        fi
    else
        if ! command -v google-chrome &> /dev/null && ! command -v chromium-browser &> /dev/null; then
            echo -e "  ${DANGER}${ICON_CROSS} Erreur : Google Chrome ou Chromium non trouvé.${NC}"
            exit 1
        fi
    fi
    
    if ! command -v wget &> /dev/null; then
        echo -e "  ${DANGER}${ICON_CROSS} Erreur : wget non trouvé.${NC}"
        echo -e "  Veuillez l'installer avec : ${SECONDARY}sudo apt install wget${NC}"
        exit 1
    fi
    
    # Déterminer la commande Chrome
    local chrome_cmd="google-chrome"
    if ! command -v google-chrome &> /dev/null; then
        chrome_cmd="chromium-browser"
    fi
    
    # Installation pour les applications basées sur un dépôt Git
    if [ -n "${APPS[${app_key}_repo]}" ]; then
        print_step "1" "2" "Clonage du dépôt git..."
        local temp_dir="/tmp/tux-client-install-$$"
        rm -rf "$temp_dir"
        git clone --depth 1 "${APPS[${app_key}_repo]}" "$temp_dir" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Dépôt cloné avec succès."
        else
            print_error "Échec du clonage du dépôt."
            rm -rf "$temp_dir"
            exit 1
        fi
        
        print_step "2" "2" "Lancement du script d'installation..."
        if [ -f "$temp_dir/install.sh" ]; then
            (
                cd "$temp_dir"
                chmod +x install.sh
                ./install.sh
            )
            if [ $? -eq 0 ]; then
                print_success "Compilation et installation terminées."
            else
                print_error "Échec de l'installation."
                rm -rf "$temp_dir"
                exit 1
            fi
        else
            print_error "Script install.sh non trouvé dans le dépôt."
            rm -rf "$temp_dir"
            exit 1
        fi
        
        rm -rf "$temp_dir"
        echo
        echo -e "  ${SUCCESS}${BOLD}🎉 Installation de $display_name terminée avec succès !${NC}"
        echo
        
        # Test optionnel
        read -p "  Voulez-vous lancer $display_name maintenant ? (y/N) : " -n 1 -r REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  Lancement de $display_name..."
            "$HOME/.local/bin/tux-it" &
        fi
        return
    fi
    
    # Web app steps:
    print_step "1" "5" "Création du dossier d'application..."
    sudo mkdir -p "$app_dir"
    print_success "Dossier créé : $app_dir"
    
    print_step "2" "5" "Téléchargement de l'icône officielle..."
    sudo wget -q -O "$icon_path" "$icon_url"
    if [ $? -eq 0 ]; then
        print_success "Icône téléchargée : $icon_path"
        sudo chmod 644 "$icon_path"
    else
        print_error "Erreur de téléchargement de l'icône"
        exit 1
    fi
    
    print_step "3" "5" "Création du script de lancement..."
sudo tee "$script_path" > /dev/null <<EOF
#!/bin/bash
$chrome_cmd --app=$app_url \\
  --user-data-dir="\$HOME/.config/${app_name_lower}-profile" \\
  --disable-features=VizDisplayCompositor \\
  --class="${app_name_lower}-app" \\
  --name="$display_name" \\
  --window-size=$WINDOW_SIZE
EOF
    sudo chmod +x "$script_path"
    print_success "Script créé : $script_path"
    
    print_step "4" "5" "Création du fichier .desktop..."
sudo bash -c "cat > '$desktop_file' <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$display_name
Comment=$display_name web application
Exec=$script_path
Icon=$icon_path
Terminal=false
StartupWMClass=$display_name
Categories=$categories
StartupNotify=true
EOF"
    sudo chmod +x "$desktop_file"
    print_success "Raccourci système créé : $desktop_file"
    
    print_step "5" "5" "Mise à jour du cache des applications..."
    sudo update-desktop-database 2>/dev/null || true
    if command -v gtk-update-icon-cache &> /dev/null; then
        sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true
    fi
    print_success "Caches mis à jour."
    
    echo
    echo -e "  ${SUCCESS}${BOLD}🎉 Installation de $display_name terminée avec succès !${NC}"
    echo -e "  ${MUTED}📁 Dossier : $app_dir${NC}"
    echo -e "  ${MUTED}🚀 Lanceur : $desktop_file${NC}"
    echo
    
    # Test optionnel
    read -p "  Voulez-vous lancer $display_name maintenant ? (y/N) : " -n 1 -r REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "  Lancement de $display_name..."
        "$script_path" &
    fi
}

# Fonction de désinstallation silencieuse (pour réinstallation)
uninstall_app_silent() {
    local app_key="$1"
    local app_name="${APPS[${app_key}_name]}"
    local app_name_lower=$(echo "$app_key" | tr '[:upper:]' '[:lower:]')
    
    if [ "$app_key" = "tux" ]; then
        rm -f "$HOME/.local/bin/tux-it" 2>/dev/null || true
        rm -f "$HOME/.local/share/icons/tux-it.png" 2>/dev/null || true
        rm -f "$HOME/.local/share/applications/tux-it.desktop" 2>/dev/null || true
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        fi
    else
        sudo rm -rf "/opt/$app_name" 2>/dev/null || true
        sudo rm "/usr/share/applications/${app_name_lower}.desktop" 2>/dev/null || true
        rm "$HOME/.local/share/applications/${app_name_lower}.desktop" 2>/dev/null || true
        rm -rf "$HOME/.config/${app_name_lower}-profile" 2>/dev/null || true
    fi
}

# Fonction de désinstallation
uninstall_app() {
    local app_key="$1"
    local app_name="${APPS[${app_key}_name]}"
    local app_name_lower=$(echo "$app_key" | tr '[:upper:]' '[:lower:]')
    
    local app_dir="/opt/$app_name"
    local desktop_file="/usr/share/applications/${app_name_lower}.desktop"
    local user_desktop_file="$HOME/.local/share/applications/${app_name_lower}.desktop"
    local profile_dir="$HOME/.config/${app_name_lower}-profile"
    
    # Nom d'affichage
    local display_name="$app_name"
    if [ "$app_key" = "claude" ]; then
        display_name="Claude AI"
    elif [ "$app_key" = "tux" ]; then
        display_name="Tux-It"
    fi
    
    print_header
    echo -e "  ${DANGER}${BOLD}🗑️ DÉSINSTALLATION : ${display_name^^}${NC}"
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    echo
    
    # Vérifier si installé
    local installed=false
    if [ "$app_key" = "tux" ]; then
        if [ -f "$HOME/.local/bin/tux-it" ]; then
            installed=true
        fi
    else
        if [ -d "$app_dir" ]; then
            installed=true
        fi
    fi
    
    if [ "$installed" = false ]; then
        echo -e "  ${DANGER}${ICON_CROSS} $display_name n'est pas installé sur votre système.${NC}"
        return
    fi
    
    # Confirmation
    read -p "  Êtes-vous sûr de vouloir désinstaller $display_name ? (y/N) : " -n 1 -r REPLY
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "  ${MUTED}Désinstallation annulée.${NC}"
        return
    fi
    echo
    
    if [ "$app_key" = "tux" ]; then
        print_step "1" "4" "Suppression de l'exécutable..."
        rm -f "$HOME/.local/bin/tux-it"
        print_success "Binaire supprimé."
        
        print_step "2" "4" "Suppression de l'icône..."
        rm -f "$HOME/.local/share/icons/tux-it.png"
        print_success "Icône supprimée."
        
        print_step "3" "4" "Suppression du raccourci bureau..."
        rm -f "$HOME/.local/share/applications/tux-it.desktop"
        print_success "Raccourci bureau supprimé."
        
        print_step "4" "4" "Mise à jour de la base de données desktop..."
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$HOME/.local/share/applications" || true
        fi
        print_success "Base de données desktop mise à jour."
    else
        print_step "1" "5" "Suppression du dossier d'application..."
        sudo rm -rf "$app_dir"
        print_success "Dossier supprimé."
        
        print_step "2" "5" "Suppression du fichier .desktop système..."
        if [ -f "$desktop_file" ]; then
            sudo rm "$desktop_file"
            print_success "Fichier système supprimé."
        else
            print_success "Aucun fichier système trouvé."
        fi
        
        print_step "3" "5" "Suppression du fichier .desktop utilisateur..."
        if [ -f "$user_desktop_file" ]; then
            rm "$user_desktop_file"
            print_success "Fichier utilisateur supprimé."
        else
            print_success "Aucun fichier utilisateur trouvé."
        fi
        
        print_step "4" "5" "Suppression du profil Chrome..."
        if [ -d "$profile_dir" ]; then
            rm -rf "$profile_dir"
            print_success "Profil Chrome supprimé."
        else
            print_success "Aucun profil Chrome trouvé."
        fi
        
        print_step "5" "5" "Mise à jour du cache..."
        sudo update-desktop-database 2>/dev/null || true
        update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
        print_success "Caches système rafraîchis."
    fi
    
    echo
    echo -e "  ${SUCCESS}${BOLD}✨ Désinstallation de $display_name terminée avec succès !${NC}"
}

# Fonction pour lister les applications installées
list_installed_apps() {
    echo -e "  ${SECONDARY}${BOLD}📊 TABLEAU DE BORD DES APPLICATIONS${NC}"
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    
    local installed_count=0
    local app_list=($(get_app_keys))
    
    for app_key in "${app_list[@]}"; do
        local app_name="${APPS[${app_key}_name]}"
        local display_name=$(get_app_display_name "$app_key")
        local is_installed=false
        
        if [ -n "${APPS[${app_key}_repo]}" ]; then
            if [ "$app_key" = "tux" ] && [ -f "$HOME/.local/bin/tux-it" ]; then
                is_installed=true
            fi
        else
            local app_dir="/opt/$app_name"
            if [ -d "$app_dir" ]; then
                is_installed=true
            fi
        fi
        
        if [ "$is_installed" = true ]; then
            echo -e "  ${SUCCESS}${ICON_CHECK} ${BOLD}${display_name}${NC}  ${MUTED}• Installée${NC}"
            installed_count=$((installed_count + 1))
        else
            echo -e "  ${MUTED}○ ${display_name}${NC}  ${MUTED}• Disponible${NC}"
        fi
    done
    
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    if [ $installed_count -eq 0 ]; then
        echo -e "  ${WARNING}${ICON_WARN} Aucune application installée pour le moment.${NC}"
    else
        echo -e "  ${SUCCESS}${BOLD}${installed_count}/${#app_list[@]}${NC} ${MUTED}applications actives sur le système.${NC}"
    fi
    echo
}

# Fonction pour obtenir la liste des applications pour le menu
get_app_keys() {
    echo "trello chatgpt claude notion github gemini tux"
}

# Fonction pour obtenir l'affichage pour le menu
get_app_display_name() {
    local app_key="$1"
    case "$app_key" in
        trello) echo "Trello" ;;
        chatgpt) echo "ChatGPT" ;;
        claude) echo "Claude AI" ;;
        notion) echo "Notion" ;;
        github) echo "Github" ;;
        gemini) echo "Gemini" ;;
        tux) echo "Tux-It" ;;
        *) echo "$app_key" ;;
    esac
}


# Menu de sélection d'application
select_app() {
    local action="$1"
    local app_list=($(get_app_keys))
    local menu_items="${#app_list[@]}"
    local i=1
    
    print_header
    if [ "$action" = "Installer" ]; then
        echo -e "  ${SUCCESS}${BOLD}📥 INSTALLER UNE APPLICATION${NC}"
    else
        echo -e "  ${DANGER}${BOLD}🗑️ DÉSINSTALLER UNE APPLICATION${NC}"
    fi
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    echo -e "  Sélectionnez l'application :"
    echo
    
    for app_key in "${app_list[@]}"; do
        local display_name=$(get_app_display_name "$app_key")
        # Check if already installed
        local is_installed=false
        if [ -n "${APPS[${app_key}_repo]}" ]; then
            if [ "$app_key" = "tux" ] && [ -f "$HOME/.local/bin/tux-it" ]; then
                is_installed=true
            fi
        else
            local app_name="${APPS[${app_key}_name]}"
            if [ -d "/opt/$app_name" ]; then
                is_installed=true
            fi
        fi
        
        local status_str=""
        if [ "$is_installed" = true ]; then
            status_str=" ${SUCCESS}[Installée]${NC}"
        else
            status_str=" ${MUTED}[Disponible]${NC}"
        fi
        
        echo -e "  ${PRIMARY}${BOLD}[$i]${NC} ${BOLD}${display_name}${NC}${status_str}"
        i=$((i + 1))
    done
    
    echo -e "  ${DANGER}${BOLD}[$i]${NC} ${DANGER}Retour au menu principal${NC}"
    echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
    echo
    
    read -p "  Votre choix (1-$i) : " -r REPLY
    echo
    
    if [[ "$REPLY" =~ ^[0-9]+$ ]] && [ "$REPLY" -ge 1 ] && [ "$REPLY" -le "$menu_items" ]; then
        # C'est un choix d'application
        local selected_key="${app_list[$REPLY - 1]}"
        if [ "$action" = "Installer" ]; then
            install_app "$selected_key"
        else
            uninstall_app "$selected_key"
        fi
    elif [ "$REPLY" -eq "$i" ]; then
        # Retour au menu principal
        return
    else
        echo -e "  ${DANGER}Choix invalide.${NC}"
        sleep 1
    fi
}

# Fonction pour gérer la configuration et les alias
manage_config() {
    local alias_file="$HOME/.bash_aliases"
    local bashrc_file="$HOME/.bashrc"
    
    while true; do
        print_header
        echo -e "  ${SECONDARY}${BOLD}⚙️ CONFIGURATION & ALIAS${NC}"
        echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
        echo -e "  ${BOLD}Dossier applications :${NC} ${PRIMARY}/opt/${NC}"
        echo -e "  ${BOLD}Fichier des alias    :${NC} ${PRIMARY}$alias_file${NC}"
        echo
        echo -e "  ${SECONDARY}${BOLD}📌 ALIAS DÉTECTÉS :${NC}"
        echo -e "  ${MUTED}───────────────────${NC}"
        
        local alias_found=false
        # On liste les alias de .bash_aliases et les alias personnalisés de .bashrc
        if [ -f "$alias_file" ] && [ -s "$alias_file" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^alias ]]; then
                    echo -e "    ${SUCCESS}▶${NC} ${BOLD}$(echo "$line" | cut -d' ' -f2-)${NC}"
                    alias_found=true
                fi
            done < "$alias_file"
        fi
        
        # On cherche aussi dans .bashrc mais on filtre les alias système classiques
        if [ -f "$bashrc_file" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^alias ]] && [[ ! "$line" =~ ls=|grep=|ll=|la=|l=|alert= ]]; then
                    echo -e "    ${SUCCESS}▶${NC} ${BOLD}$(echo "$line" | cut -d' ' -f2-)${NC} ${MUTED}(dans .bashrc)${NC}"
                    alias_found=true
                fi
            done < "$bashrc_file"
        fi
        
        if [ "$alias_found" = false ]; then
            echo -e "    ${MUTED}Aucun alias personnalisé détecté.${NC}"
        fi
        echo -e "  ${MUTED}───────────────────${NC}"
        echo
        echo -e "  ${PRIMARY}${BOLD}[1]${NC} Ajouter un alias"
        echo -e "  ${PRIMARY}${BOLD}[2]${NC} Modifier un alias"
        echo -e "  ${PRIMARY}${BOLD}[3]${NC} Supprimer un alias"
        echo -e "  ${SECONDARY}${BOLD}[4]${NC} Re-scanner / Rafraîchir"
        echo -e "  ${DANGER}${BOLD}[5]${NC} ${DANGER}Retour au menu principal${NC}"
        echo -e "  ${MUTED}──────────────────────────────────────────────────────────────${NC}"
        echo
        
        read -p "  Votre choix (1-5) : " -n 1 -r REPLY
        echo
        echo
        
        case $REPLY in
            1)
                echo -e "  ${SECONDARY}${BOLD}➕ AJOUTER UN ALIAS${NC}"
                read -p "  Nom de l'alias (ex: util) : " alias_name
                read -p "  Commande ou Dossier (ex: cd ~/Documents) : " alias_cmd
                if [ -n "$alias_name" ] && [ -n "$alias_cmd" ]; then
                    [ -f "$alias_file" ] || touch "$alias_file"
                    [ -n "$(tail -c1 "$alias_file" 2>/dev/null)" ] && echo "" >> "$alias_file"
                    echo "alias $alias_name='$alias_cmd'" >> "$alias_file"
                    echo -e "  ${SUCCESS}${ICON_CHECK} Alias ajouté dans $alias_file${NC}"
                    
                    if ! grep -q "test -f ~/.bash_aliases" "$bashrc_file"; then
                        echo -e "\n# Alias personnels\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" >> "$bashrc_file"
                    fi
                fi
                sleep 2
                ;;
            2)
                echo -e "  ${WARNING}${BOLD}📝 MODIFIER UN ALIAS${NC}"
                read -p "  Nom de l'alias à modifier : " alias_name
                if [ -n "$alias_name" ]; then
                    # Vérifier si l'alias est dans .bashrc mais pas dans .bash_aliases
                    if grep -q "^alias $alias_name=" "$bashrc_file" && ! grep -q "^alias $alias_name=" "$alias_file"; then
                        echo -e "  L'alias '${WARNING}$alias_name${NC}' a été détecté dans votre .bashrc."
                        read -p "  Voulez-vous le migrer vers le fichier de config pour pouvoir le modifier ? (y/N) : " -n 1 -r REPLY
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            # Extraire l'ancienne commande proprement
                            old_line=$(grep "^alias $alias_name=" "$bashrc_file" | head -n 1)
                            # Supprimer du .bashrc
                            sed -i "/^alias $alias_name=/d" "$bashrc_file"
                            # Ajouter au .bash_aliases
                            echo "$old_line" >> "$alias_file"
                            echo -e "  ${SUCCESS}${ICON_CHECK} Alias migré avec succès.${NC}"
                        fi
                    fi
                    
                    if grep -q "^alias $alias_name=" "$alias_file"; then
                        local current_cmd=$(grep "^alias $alias_name=" "$alias_file" | cut -d"'" -f2)
                        echo -e "  Alias actuel : ${SECONDARY}$current_cmd${NC}"
                        read -p "  Nouvelle commande/dossier : " new_cmd
                        if [ -n "$new_cmd" ]; then
                            sed -i "/^alias $alias_name=/d" "$alias_file"
                            echo "alias $alias_name='$new_cmd'" >> "$alias_file"
                            echo -e "  ${SUCCESS}${ICON_CHECK} Alias '$alias_name' mis à jour.${NC}"
                        fi
                    else
                        echo -e "  ${DANGER}${ICON_CROSS} L'alias '$alias_name' n'est pas géré par ce script.${NC}"
                    fi
                fi
                sleep 2
                ;;
            3)
                echo -e "  ${DANGER}${BOLD}❌ SUPPRIMER UN ALIAS${NC}"
                read -p "  Nom de l'alias à supprimer : " alias_to_del
                if [ -n "$alias_to_del" ]; then
                    if grep -q "alias $alias_to_del=" "$alias_file"; then
                        sed -i "/alias $alias_to_del=/d" "$alias_file"
                        echo -e "  ${SUCCESS}${ICON_CHECK} Alias '$alias_to_del' supprimé de $alias_file.${NC}"
                    elif grep -q "alias $alias_to_del=" "$bashrc_file"; then
                        echo -e "  Cet alias est configuré dans votre .bashrc."
                        read -p "  Voulez-vous le supprimer de votre .bashrc ? (y/N) : " -n 1 -r REPLY
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            sed -i "/alias $alias_to_del=/d" "$bashrc_file"
                            echo -e "  ${SUCCESS}${ICON_CHECK} Supprimé du .bashrc.${NC}"
                        fi
                    else
                        echo -e "  ${DANGER}${ICON_CROSS} Alias non trouvé.${NC}"
                    fi
                fi
                sleep 2
                ;;
            4)
                echo -e "  ${SECONDARY}Re-scan en cours...${NC}"
                sleep 1
                ;;
            5)
                return
                ;;
        esac
    done
}

# Menu principal
while true; do
    print_header
    list_installed_apps
    
    echo -e "  ${PRIMARY}${BOLD}[1]${NC} ${BOLD}Installer${NC} une application"
    echo -e "  ${PRIMARY}${BOLD}[2]${NC} ${BOLD}Désinstaller${NC} une application"
    echo -e "  ${PRIMARY}${BOLD}[3]${NC} ${BOLD}Configuration & Alias${NC} ${MUTED}(bashrc, raccourcis)${NC}"
    echo -e "  ${DANGER}${BOLD}[4]${NC} ${DANGER}Quitter${NC}"
    echo
    
    read -p "  Votre choix (1-4) : " -n 1 -r REPLY
    echo
    
    case $REPLY in
        1)
            select_app "Installer"
            ;;
        2)
            select_app "Désinstaller"
            ;;
        3)
            manage_config
            ;;
        4)
            echo -e "  ${SECONDARY}Au revoir !${NC}"
            exit 0
            ;;
        *)
            echo -e "  ${DANGER}Choix invalide.${NC}"
            sleep 1
            ;;
    esac
    
    echo
    read -p "Appuyez sur Entrée pour continuer..." 
done