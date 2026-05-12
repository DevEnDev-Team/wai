#!/bin/bash

# Script d'installation/désinstallation d'applications web
# Trello, ChatGPT, Claude AI, Notion, Github, Gemini

set -e

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
    fi
    
    echo "=== Installation de $display_name ==="
    echo
    
    # Vérifier si déjà installé
    if [ -d "$app_dir" ]; then
        echo "$display_name est déjà installé."
        read -p "Voulez-vous réinstaller ? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation annulée."
            return
        fi
        uninstall_app_silent "$app_key"
    fi
    
    # Vérifier les dépendances
    if ! command -v google-chrome &> /dev/null && ! command -v chromium-browser &> /dev/null; then
        echo "Erreur: Google Chrome ou Chromium non trouvé"
        exit 1
    fi
    
    if ! command -v wget &> /dev/null; then
        echo "Erreur: wget non trouvé"
        echo "Installation: sudo apt install wget"
        exit 1
    fi
    
    # Déterminer la commande Chrome
    local chrome_cmd="google-chrome"
    if ! command -v google-chrome &> /dev/null; then
        chrome_cmd="chromium-browser"
    fi
    
    echo "1. Création du dossier application..."
    sudo mkdir -p "$app_dir"
    
    echo "2. Téléchargement de l'icône $display_name..."
    sudo wget -q -O "$icon_path" "$icon_url"
    if [ $? -eq 0 ]; then
        echo "    ✓ Icône téléchargée"
        sudo chmod 644 "$icon_path"
    else
        echo "    ✗ Erreur téléchargement icône"
        exit 1
    fi
    
    echo "3. Création du script de lancement..."
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
    echo "    ✓ Script créé: $script_path"
    
    echo "4. Création du fichier .desktop..."
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
    echo "    ✓ Fichier .desktop créé"
    
    echo "5. Mise à jour du cache des applications..."
    sudo update-desktop-database 2>/dev/null || true
    
    # Mise à jour du cache des icônes
    if command -v gtk-update-icon-cache &> /dev/null; then
        sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true
    fi
    
    echo
    echo "=== Installation terminée ==="
    echo "Structure créée:"
    echo "  📁 $app_dir/"
    echo "  📄    ├── ${app_name_lower}.sh"
    echo "  🖼️    └── ${app_name_lower}.png"
    echo "  🚀 $desktop_file"
    echo
    echo "$display_name devrait maintenant apparaître dans votre menu d'applications."
    
    # Test optionnel
    read -p "Voulez-vous lancer $display_name maintenant ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Lancement de $display_name..."
        "$script_path" &
    fi
}

# Fonction de désinstallation silencieuse (pour réinstallation)
uninstall_app_silent() {
    local app_key="$1"
    local app_name="${APPS[${app_key}_name]}"
    local app_name_lower=$(echo "$app_key" | tr '[:upper:]' '[:lower:]')
    
    sudo rm -rf "/opt/$app_name" 2>/dev/null || true
    sudo rm "/usr/share/applications/${app_name_lower}.desktop" 2>/dev/null || true
    rm "$HOME/.local/share/applications/${app_name_lower}.desktop" 2>/dev/null || true
    rm -rf "$HOME/.config/${app_name_lower}-profile" 2>/dev/null || true
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
    fi
    
    echo "=== Désinstallation de $display_name ==="
    echo
    
    # Vérifier si installé
    if [ ! -d "$app_dir" ]; then
        echo "$display_name n'est pas installé."
        return
    fi
    
    # Confirmation
    read -p "Êtes-vous sûr de vouloir désinstaller $display_name ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Désinstallation annulée."
        return
    fi
    
    echo "1. Suppression du dossier application..."
    sudo rm -rf "$app_dir"
    echo "    ✓ Dossier supprimé: $app_dir"
    
    echo "2. Suppression du fichier .desktop système..."
    if [ -f "$desktop_file" ]; then
        sudo rm "$desktop_file"
        echo "    ✓ Fichier système supprimé"
    fi
    
    echo "3. Suppression du fichier .desktop utilisateur..."
    if [ -f "$user_desktop_file" ]; then
        rm "$user_desktop_file"
        echo "    ✓ Fichier utilisateur supprimé"
    fi
    
    echo "4. Suppression du profil Chrome..."
    if [ -d "$profile_dir" ]; then
        rm -rf "$profile_dir"
        echo "    ✓ Profil Chrome supprimé"
    fi
    
    echo "5. Mise à jour du cache..."
    sudo update-desktop-database 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    echo
    echo "=== Désinstallation terminée ==="
    echo "$display_name a été complètement supprimé du système."
}

# Fonction pour lister les applications installées
list_installed_apps() {
    echo "Applications installées :"
    installed_count=0
    
    # Mise à jour de la liste avec 'gemini'
    for app_key in trello chatgpt claude notion github gemini; do
        app_name="${APPS[${app_key}_name]}"
        app_dir="/opt/$app_name"
        display_name="$app_name"
        if [ "$app_key" = "claude" ]; then
            display_name="Claude AI"
        fi
        
        if [ -d "$app_dir" ]; then
            echo "  ✓ $display_name"
            installed_count=$((installed_count + 1))
        fi
    done
    
    if [ $installed_count -eq 0 ]; then
        echo "  Aucune application installée."
    fi
    echo
}

# Fonction pour obtenir la liste des applications pour le menu
get_app_keys() {
    echo "trello chatgpt claude notion github gemini"
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
        *) echo "$app_key" ;;
    esac
}


# Menu de sélection d'application
select_app() {
    local action="$1"
    local app_list=($(get_app_keys))
    local menu_items="${#app_list[@]}"
    local i=1
    
    echo "=== $action une application ==="
    
    for app_key in "${app_list[@]}"; do
        echo "$i. $(get_app_display_name "$app_key")"
        i=$((i + 1))
    done
    
    echo "$i. Retour au menu principal"
    echo
    
    read -p "Votre choix (1-$i): " -r
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
        echo "Choix invalide."
    fi
}

# Fonction pour gérer la configuration et les alias
manage_config() {
    local alias_file="$HOME/.bash_aliases"
    local bashrc_file="$HOME/.bashrc"
    
    while true; do
        clear
        echo "=== Configuration & Alias ==="
        echo
        echo "Informations système :"
        echo "  📂 Applications : /opt/"
        echo "  📄 Fichier principal : $alias_file"
        echo
        echo "--- Alias détectés ---"
        # On liste les alias de .bash_aliases et les alias personnalisés de .bashrc
        if [ -f "$alias_file" ]; then
            grep "^alias " "$alias_file" | cut -d' ' -f2- || true
        fi
        # On cherche aussi dans .bashrc mais on filtre les alias système classiques
        grep "^alias " "$bashrc_file" | grep -vE "ls=|grep=|ll=|la=|l=|alert=" | cut -d' ' -f2- || true
        echo "----------------------"
        echo
        echo "1. Ajouter un alias"
        echo "2. Modifier un alias"
        echo "3. Supprimer un alias"
        echo "4. Re-scanner / Voir tout"
        echo "5. Retour au menu principal"
        echo
        
        read -p "Votre choix (1-5): " -n 1 -r
        echo
        echo
        
        case $REPLY in
            1)
                read -p "Nom de l'alias (ex: util) : " alias_name
                read -p "Commande ou Dossier (ex: cd ~/Documents) : " alias_cmd
                if [ -n "$alias_name" ] && [ -n "$alias_cmd" ]; then
                    [ -f "$alias_file" ] || touch "$alias_file"
                    [ -n "$(tail -c1 "$alias_file" 2>/dev/null)" ] && echo "" >> "$alias_file"
                    echo "alias $alias_name='$alias_cmd'" >> "$alias_file"
                    echo "✓ Alias ajouté dans $alias_file"
                    
                    if ! grep -q "test -f ~/.bash_aliases" "$bashrc_file"; then
                        echo -e "\n# Alias personnels\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" >> "$bashrc_file"
                    fi
                fi
                sleep 2
                ;;
            2)
                read -p "Nom de l'alias à modifier : " alias_name
                if [ -n "$alias_name" ]; then
                    # Vérifier si l'alias est dans .bashrc mais pas dans .bash_aliases
                    if grep -q "^alias $alias_name=" "$bashrc_file" && ! grep -q "^alias $alias_name=" "$alias_file"; then
                        echo "L'alias '$alias_name' a été détecté dans votre .bashrc."
                        read -p "Voulez-vous le migrer vers le fichier de config pour pouvoir le modifier ? (y/N) : " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            # Extraire l'ancienne commande proprement
                            old_line=$(grep "^alias $alias_name=" "$bashrc_file" | head -n 1)
                            # Supprimer du .bashrc
                            sed -i "/^alias $alias_name=/d" "$bashrc_file"
                            # Ajouter au .bash_aliases
                            echo "$old_line" >> "$alias_file"
                            echo "✓ Alias migré."
                        fi
                    fi
                    
                    if grep -q "^alias $alias_name=" "$alias_file"; then
                        echo "Alias actuel : $(grep "^alias $alias_name=" "$alias_file" | cut -d"'" -f2)"
                        read -p "Nouvelle commande/dossier : " new_cmd
                        if [ -n "$new_cmd" ]; then
                            # On supprime l'ancien et on ajoute le nouveau pour éviter les soucis de 'sed' avec les caractères spéciaux comme '&'
                            sed -i "/^alias $alias_name=/d" "$alias_file"
                            echo "alias $alias_name='$new_cmd'" >> "$alias_file"
                            echo "✓ Alias '$alias_name' mis à jour."
                        fi
                    else
                        echo "L'alias '$alias_name' n'est pas géré par ce script (il doit être dans .bash_aliases ou être migré)."
                    fi
                fi
                sleep 2
                ;;
            3)
                read -p "Nom de l'alias à supprimer : " alias_to_del
                if [ -n "$alias_to_del" ]; then
                    if grep -q "alias $alias_to_del=" "$alias_file"; then
                        sed -i "/alias $alias_to_del=/d" "$alias_file"
                        echo "✓ Alias '$alias_to_del' supprimé de $alias_file."
                    elif grep -q "alias $alias_to_del=" "$bashrc_file"; then
                        echo "Cet alias est dans votre .bashrc."
                        read -p "Voulez-vous le supprimer de votre .bashrc ? (y/N) : " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            sed -i "/alias $alias_to_del=/d" "$bashrc_file"
                            echo "✓ Supprimé du .bashrc."
                        fi
                    else
                        echo "Alias non trouvé."
                    fi
                fi
                sleep 2
                ;;
            4)
                echo "Re-scan en cours..."
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
    echo "=== Gestionnaire d'applications web ==="
    echo
    list_installed_apps
    echo "1. Installer une application"
    echo "2. Désinstaller une application"
    echo "3. Configuration & Alias"
    echo "4. Quitter"
    echo
    
    read -p "Votre choix (1-4): " -n 1 -r
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
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Choix invalide."
            ;;
    esac
    
    echo
    read -p "Appuyez sur Entrée pour continuer..." 
    clear
done