# 🚀 WAI (Web App Installer pour Linux)

Un script Bash interactif pour transformer vos applications web préférées en applications natives Linux avec Chrome/Chromium.

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Chrome](https://img.shields.io/badge/Chrome-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)

## ✨ Fonctionnalités

- **Installation automatisée** d'applications web comme applications natives
- **Interface interactive** avec menus intuitifs
- **Gestion complète** : installation, désinstallation, réinstallation
- **Profils Chrome isolés** pour chaque application
- **Icônes haute qualité** téléchargées automatiquement
- **Intégration système** complète (menu d'applications, lanceurs)
- **Gestion des Alias** : Créez et gérez vos raccourcis terminal directement
- **Support multi-distribution** Linux

## 📱 Applications supportées

| Application | Description | URL |
|-------------|-------------|-----|
| 🗂️ **Trello** | Gestion de projets et tableaux Kanban | https://trello.com/ |
| 🤖 **ChatGPT** | Assistant IA d'OpenAI | https://chatgpt.com/ |
| 🧠 **Claude AI** | Assistant IA d'Anthropic | https://claude.ai/ |
| 📝 **Notion** | Prise de notes et productivité | https://www.notion.so/ |
| 🐙 **Github** | Plateforme de développement et Git | https://github.com/ |
| ✨ **Gemini** | Intelligence artificielle de Google | https://gemini.google.com/ |
| 🐧 **Tux-It** | Application de notes adhésives (Qt6) compiles nativement | *Repo Git* |

## 🔧 Prérequis

Le script gère automatiquement l'installation des dépendances si vous l'exécutez sur une base Debian/Ubuntu.

### Dépendances obligatoires (compilation de wai-runner)
- **Rust & Cargo** pour compiler le binaire
- **libwebkit2gtk-4.1-dev** et **libgtk-3-dev** (moteurs WebKit/GTK système)
- **wget** pour le téléchargement des icônes
- **Accès sudo** pour l'installation système des raccourcis et dépendances

### Installation manuelle des dépendances (optionnelle)

#### Ubuntu/Debian/Pop!_OS
```bash
sudo apt update
sudo apt install cargo rustc libsoup-3.0-dev libwebkit2gtk-4.1-dev libgtk-3-dev build-essential wget
```

#### Fedora
```bash
sudo dnf install cargo rustc webkit2gtk4.1-devel gtk3-devel wget
```

#### Arch Linux
```bash
sudo pacman -S rust webkit2gtk-4.1 gtk3 wget
```

## 📥 Installation

### Téléchargement direct
```bash
### Méthode 1 : Paquet Debian (Recommandée pour Ubuntu/Debian/Pop!_OS)
1. Téléchargez le dernier paquet `.deb` depuis la page des [Releases GitHub](https://github.com/DevEnDev-Team/wai/releases).
2. Installez-le avec votre gestionnaire de paquets favori :
   ```bash
   sudo apt install ./wai_*.deb
   ```

### Méthode 2 : Compilation à partir des sources (Toutes distributions)
1. Clonez le repository et accédez-y :
   ```bash
   git clone https://github.com/DevEnDev-Team/wai.git
   cd wai
   ```
2. Compilez le projet Workspace Rust :
   ```bash
   cargo build --release
   ```
3. Installez le binaire de la CLI dans vos exécutables utilisateur :
   ```bash
   cp target/release/wai-cli ~/.local/bin/wai
   ```
   *(Assurez-vous que `~/.local/bin` est présent dans votre `$PATH`).*

## 🎯 Utilisation

### Lancement de l'outil
Ouvrez simplement votre terminal et lancez la commande :
```bash
wai
```

### Interface TUI Interactive
L'interface en ligne de commande (TUI) est entièrement interactive et se pilote au clavier :
- Utilisez les flèches du clavier **Haut/Bas** ⬆️ ⬇️ pour naviguer dans les options.
- Appuyez sur **Entrée** pour valider vos choix.

### Installation d'une application
1. Choisissez **"Installer une application"** dans le menu principal.
2. Naviguez vers l'application de votre choix.
3. WAI s'occupe de tout :
   - Télécharge l'icône haute qualité au format PNG.
   - Génère une entrée de bureau `.desktop` dans `~/.local/share/applications/` pour l'intégrer à votre menu d'applications système.
   - Initialise une session isolée pour votre application.
   - *(Si vous compilez manuellement)* WAI s'occupe de compiler automatiquement le runner Tauri la première fois.

### Gestion des Alias & Config
Depuis le menu **"Configuration & Alias"**, vous pouvez :
- Visualiser tous vos alias personnalisés (détectés dans `~/.bash_aliases` et `~/.bashrc`).
- **Ajouter** de nouveaux alias instantanément.
- **Modifier** des alias existants (avec détection intelligente dans `.bashrc` et transfert sécurisé).
- **Supprimer** des alias proprement sans risque pour votre système.

### Désinstallation
1. Choisissez **"Désinstaller une application"** dans le menu principal.
2. Sélectionnez l'application à supprimer.
3. Validez la confirmation. Tout est nettoyé proprement sans laisser de résidus (fichiers desktop, icônes, dossiers de sessions et de cookies).

## 📁 Structure créée

Chaque application installée génère cette structure :

```
/opt/AppName/
├── appname.sh          # Script de lancement (appelle wai-runner)
└── appname.png         # Icône de l'application

/usr/share/applications/
└── appname.desktop     # Entrée du menu système (tous utilisateurs)

~/.local/share/com.devendev.wairunner/sessions/appname/
└── [Données de session isolées du site web]
```

## ⚙️ Configuration technique

### Paramètres de wai-runner
Les applications s'exécutent avec `wai-runner` en utilisant les paramètres suivants :
- `--url URL` : L'adresse URL de la webapp à charger.
- `--title Titre` : Le titre affiché sur la fenêtre.
- `--identifier ID` : Identifiant unique pour isoler le stockage (cookies, localStorage, cache).

### Catégories d'applications
- **Trello** : `Office;ProjectManagement;Productivity;`
- **ChatGPT/Claude/Gemini** : `Network;Chat;Office;AI;`
- **Notion** : `Office;Productivity;TextEditor;`
- **Github** : `Development;VersionControl;Collaboration;`
- **Tux-It** : `Utility;Office;` (compilé nativement)

## 🔍 Dépannage

### L'application n'apparaît pas dans le menu
```bash
# Mettre à jour les caches
sudo update-desktop-database
update-desktop-database ~/.local/share/applications/
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/

# Redémarrer le shell (GNOME/Pop!_OS)
killall -SIGUSR1 gnome-shell
```

### Erreur de téléchargement d'icône
```bash
# Vérifier la connexion internet
ping -c 3 icons8.com

# Installer wget si manquant
sudo apt install wget
```

### Chrome non trouvé
```bash
# Installer Google Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable

# Ou installer Chromium
sudo apt install chromium-browser
```

### Problèmes de permissions
```bash
# Vérifier les permissions sudo
sudo -v

# Le script nécessite sudo pour :
# - Créer /opt/AppName/
# - Écrire dans /usr/share/applications/
# - Mettre à jour les caches système
```

## 🌟 Avantages

### 🔒 **Sécurité**
- Profils Chrome isolés par application
- Pas d'interférence entre applications
- Données séparées et sécurisées

### 🎨 **Intégration native**
- Icônes haute qualité
- Apparence d'applications natives
- Intégration parfaite au système

### ⚡ **Performance**
- Utilise Chrome existant (pas de duplication)
- Démarrage rapide
- Mises à jour automatiques avec Chrome

### 🛠️ **Maintenance**
- Installation/désinstallation propre
- Gestion centralisée
- Pas de résidus système

## 🔧 Personnalisation

### Modifier la taille de fenêtre
Éditez la variable dans le script :
```bash
WINDOW_SIZE="1400x900"  # Au lieu de 1200x800
```

### Ajouter une nouvelle application
```bash
# Dans la section configuration
APPS[nouvelleapp_name]="Nouvelle App"
APPS[nouvelleapp_url]="https://example.com/"
APPS[nouvelleapp_icon]="https://icon-url.png"
APPS[nouvelleapp_category]="Office;Productivity;"

# Ajouter aux menus et boucles
```

## 🤝 Compatibilité

### Distributions testées
- ✅ **Ubuntu** 20.04, 22.04, 24.04
- ✅ **Pop!_OS** 20.04, 22.04
- ✅ **Debian** 11, 12
- ✅ **Fedora** 38, 39
- ✅ **Arch Linux**
- ✅ **Linux Mint**

### Environnements de bureau
- ✅ **GNOME** / **GNOME Shell**
- ✅ **KDE Plasma**
- ✅ **XFCE**
- ✅ **MATE**
- ✅ **Cinnamon**

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! 

1. **Fork** le projet
2. **Créez** votre branche (`git checkout -b feature/nouvelle-app`)
3. **Committez** vos changements (`git commit -m 'Ajout nouvelle app'`)
4. **Pushez** vers la branche (`git push origin feature/nouvelle-app`)
5. **Ouvrez** une Pull Request

### Idées de contributions
- 🆕 Nouvelles applications supportées
- 🐛 Corrections de bugs
- 📚 Amélioration de la documentation
- 🎨 Amélioration de l'interface
- 🧪 Tests sur nouvelles distributions

## 📞 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/DevEnDev-Team/wai/issues)
- 💬 **Discussions** : [GitHub Discussions](https://github.com/DevEnDev-Team/wai/discussions)
- 📧 **Email** : devendev.pro@gmail.com

## 🙏 Remerciements

- **Icons8** pour les icônes haute qualité
- **Google Chrome Team** pour l'excellent support des applications web
- **Communauté Linux** pour les retours et tests

---

<div align="center">

**⭐ N'hésitez pas à donner une étoile si ce projet vous a été utile ! ⭐**

Made with ❤️ for the Linux community

</div>
