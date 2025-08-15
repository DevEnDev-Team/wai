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
- **Support multi-distribution** Linux

## 📱 Applications supportées

| Application | Description | URL |
|-------------|-------------|-----|
| 🗂️ **Trello** | Gestion de projets et tableaux Kanban | https://trello.com/ |
| 🤖 **ChatGPT** | Assistant IA d'OpenAI | https://chatgpt.com/ |
| 🧠 **Claude AI** | Assistant IA d'Anthropic | https://claude.ai/ |
| 📝 **Notion** | Prise de notes et productivité | https://www.notion.so/ |

## 🔧 Prérequis

### Dépendances obligatoires
- **Google Chrome** ou **Chromium**
- **wget** pour le téléchargement des icônes
- **Accès sudo** pour l'installation système

### Installation des dépendances

#### Ubuntu/Debian/Pop!_OS
```bash
sudo apt update
sudo apt install google-chrome-stable wget
# Ou pour Chromium
sudo apt install chromium-browser wget
```

#### Fedora
```bash
sudo dnf install google-chrome-stable wget
# Ou pour Chromium
sudo dnf install chromium wget
```

#### Arch Linux
```bash
sudo pacman -S google-chrome wget
# Ou pour Chromium
sudo pacman -S chromium wget
```

## 📥 Installation

### Téléchargement direct
```bash
# Télécharger le script
wget https://raw.githubusercontent.com/DevEnDev-Team/wai/main/install_dev_tools.sh

# Rendre exécutable
chmod +x install_dev_tools.sh

# Lancer le script
./install_dev_tools.sh
```

### Clone du repository
```bash
git clone https://github.com/DevEnDev-Team/wai.git
cd web-app-installer
chmod +x install_dev_tools.sh
./install_dev_tools.sh
```

## 🎯 Utilisation

### Lancement du script
```bash
./install_dev_tools.sh
```

### Interface principale
```
=== Gestionnaire d'applications web ===

Applications installées :
  ✓ Trello
  ✓ ChatGPT

1. Installer une application
2. Désinstaller une application
3. Quitter

Votre choix (1-3):
```

### Installation d'une application
1. Choisissez **"1. Installer une application"**
2. Sélectionnez l'application désirée
3. Le script :
   - Crée le dossier `/opt/AppName/`
   - Télécharge l'icône officielle
   - Génère le script de lancement
   - Crée l'entrée de menu `.desktop`
   - Met à jour les caches système

### Désinstallation
1. Choisissez **"2. Désinstaller une application"**
2. Sélectionnez l'application à supprimer
3. Confirmez la suppression
4. Le script supprime complètement :
   - Dossier d'application
   - Fichiers de menu
   - Profil Chrome dédié

## 📁 Structure créée

Chaque application installée génère cette structure :

```
/opt/AppName/
├── appname.sh          # Script de lancement
└── appname.png         # Icône de l'application

/usr/share/applications/
└── appname.desktop     # Entrée du menu système

~/.local/share/applications/
└── appname.desktop     # Entrée du menu utilisateur

~/.config/appname-profile/
└── [Profil Chrome dédié]
```

## ⚙️ Configuration technique

### Paramètres Chrome
Les applications sont lancées avec ces options :
- `--app=URL` : Mode application
- `--user-data-dir` : Profil isolé
- `--disable-features=VizDisplayCompositor` : Optimisation
- `--class` et `--name` : Identification de fenêtre
- `--window-size=1200x800` : Taille par défaut

### Catégories d'applications
- **Trello** : `Office;ProjectManagement;Productivity;`
- **ChatGPT/Claude** : `Network;Chat;Office;`
- **Notion** : `Office;Productivity;TextEditor;`

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
