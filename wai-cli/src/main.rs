use console::{style, Term};
use dialoguer::{theme::ColorfulTheme, Select};
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

// --- Modèles de données ---

#[derive(Clone)]
struct AppConfig {
    key: &'static str,
    name: &'static str,
    url: &'static str,
    icon: &'static str,
    category: &'static str,
    repo: Option<&'static str>,
}

fn get_apps() -> Vec<AppConfig> {
    vec![
        AppConfig {
            key: "trello",
            name: "Trello",
            url: "https://trello.com/",
            icon: "https://img.icons8.com/?size=100&id=vrmg1S9Hfbiv&format=png&color=000000",
            category: "Office;ProjectManagement;Productivity;",
            repo: None,
        },
        AppConfig {
            key: "chatgpt",
            name: "ChatGPT",
            url: "https://chatgpt.com/",
            icon: "https://img.icons8.com/?size=100&id=kTuxVYRKeKEY&format=png&color=000000",
            category: "Network;Chat;Office;",
            repo: None,
        },
        AppConfig {
            key: "claude",
            name: "Claude AI",
            url: "https://claude.ai/",
            icon: "https://img.icons8.com/?size=100&id=zQjzFjPpT2Ek&format=png&color=000000",
            category: "Network;Chat;Office;",
            repo: None,
        },
        AppConfig {
            key: "notion",
            name: "Notion",
            url: "https://www.notion.so/",
            icon: "https://img.icons8.com/?size=100&id=wue74HqaylSJ&format=png&color=000000",
            category: "Office;Productivity;TextEditor;",
            repo: None,
        },
        AppConfig {
            key: "github",
            name: "Github",
            url: "https://github.com/",
            icon: "https://img.icons8.com/?size=100&id=52539&format=png&color=000000",
            category: "Development;VersionControl;Collaboration;",
            repo: None,
        },
        AppConfig {
            key: "gemini",
            name: "Gemini",
            url: "https://gemini.google.com/",
            icon: "https://img.icons8.com/?size=100&id=BU7Clwq5bV9D&format=png&color=000000",
            category: "Network;Chat;Office;AI;",
            repo: None,
        },
        AppConfig {
            key: "tux",
            name: "Tux-It",
            url: "",
            icon: "",
            category: "Utility;Office;",
            repo: Some("git@github.com:DevEnDev-Team/tux-client.git"),
        },
    ]
}

// --- Fonctions d'aide à l'affichage ---

fn print_header() {
    let term = Term::stdout();
    let _ = term.clear_screen();
    println!("{}", style(" ╔══════════════════════════════════════════════════════════════╗").magenta());
    println!(" {}   {}                {}", style("║").magenta(), style("⚡ W A I  //  W E B  A P P  I N S T A L L E R").cyan().bold(), style("║").magenta());
    println!(" {}   {}        {}", style("║").magenta(), style("Engineered for Linux | Version 3.0.0 (Rust Edition)").white().dim(), style("║").magenta());
    println!("{}", style(" ╚══════════════════════════════════════════════════════════════╝").magenta());
    println!();
}

fn check_is_installed(app: &AppConfig) -> bool {
    if app.repo.is_some() {
        let mut path = dirs::home_dir().unwrap_or_default();
        path.push(".local/bin/tux-it");
        path.exists()
    } else {
        // Nouvelle installation locale : dossier dans ~/.local/share/wai/apps/
        let mut path = dirs::data_dir().unwrap_or_default();
        path.push("wai/apps");
        path.push(app.name);
        path.exists()
    }
}

// --- Gestion des dépendances & Compilation du Runner ---

fn ensure_runner_compiled() -> io::Result<PathBuf> {
    // 1. Vérifier si installé globalement (cas du paquet .deb)
    let global_runner = PathBuf::from("/usr/bin/wai-runner");
    if global_runner.exists() {
        return Ok(global_runner);
    }

    // 2. Vérifier dans ~/.local/bin/ (compilation locale)
    let mut runner_bin = dirs::home_dir().unwrap_or_default();
    runner_bin.push(".local/bin/wai-runner");

    if runner_bin.exists() {
        return Ok(runner_bin);
    }

    print_header();
    println!("{}", style("  🛠️ COMPILATION DU RUNNER TAURI (WAI-RUNNER)").cyan().bold());
    println!("  ──────────────────────────────────────────────────────────────");
    println!("  Le runner Tauri (wai-runner) est requis pour les applications.");
    println!("  Nous allons vérifier les dépendances et le compiler.");
    println!();

    // 1. Vérification de Cargo/Rust
    if Command::new("cargo").arg("--version").stdout(Stdio::null()).stderr(Stdio::null()).status().is_err() {
        println!("  {} Cargo/Rust n'est pas installé sur le système.", style("⚠").yellow());
        print!("  Voulez-vous l'installer maintenant via apt ? (y/N) : ");
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        if input.trim().eq_ignore_ascii_case("y") {
            println!("  Installation de Rust et Cargo...");
            let status = Command::new("sudo")
                .args(&["apt-get", "update"])
                .status()?;
            if !status.success() {
                return Err(io::Error::new(io::ErrorKind::Other, "Failed to update package list"));
            }
            let status = Command::new("sudo")
                .args(&["apt-get", "install", "-y", "cargo", "rustc"])
                .status()?;
            if !status.success() {
                return Err(io::Error::new(io::ErrorKind::Other, "Failed to install cargo"));
            }
        } else {
            return Err(io::Error::new(io::ErrorKind::Other, "Rust is required to build the runner"));
        }
    }

    // 2. Vérification des bibliothèques de dev système
    println!("  Vérification des dépendances système...");
    let mut missing_libs = Vec::new();
    let checks = vec![
        ("javascriptcoregtk-4.1", "libwebkit2gtk-4.1-dev"),
        ("gtk+-3.0", "libgtk-3-dev"),
        ("libsoup-3.0", "libsoup-3.0-dev"),
        ("openssl", "libssl-dev"),
    ];

    for (pkg, package_name) in checks {
        let status = Command::new("pkg-config")
            .arg("--exists")
            .arg(pkg)
            .status();
        
        let exists = match status {
            Ok(s) => s.success(),
            Err(_) => false,
        };

        if !exists {
            missing_libs.push(package_name);
        }
    }

    if !missing_libs.is_empty() {
        println!("  {} Bibliothèques manquantes : {:?}", style("⚠").yellow(), missing_libs);
        print!("  Voulez-vous installer les paquets requis avec sudo ? (y/N) : ");
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        if input.trim().eq_ignore_ascii_case("y") {
            let status = Command::new("sudo")
                .args(&[
                    "apt-get",
                    "install",
                    "-y",
                    "libsoup-3.0-dev",
                    "libwebkit2gtk-4.1-dev",
                    "libgtk-3-dev",
                    "build-essential",
                    "libssl-dev",
                    "libayatana-appindicator3-dev",
                    "librsvg2-dev",
                ])
                .status()?;
            if !status.success() {
                return Err(io::Error::new(io::ErrorKind::Other, "Failed to install system dependencies"));
            }
        } else {
            return Err(io::Error::new(io::ErrorKind::Other, "System dependencies are required"));
        }
    }

    // 3. Compilation
    println!("  Compilation de wai-runner...");
    
    // Trouver le dossier source de wai-runner (relatif à l'exécutable ou au dossier courant)
    let mut build_dir = std::env::current_dir()?;
    build_dir.push("wai-runner");

    if !build_dir.exists() {
        return Err(io::Error::new(
            io::ErrorKind::NotFound,
            format!("Dossier source {} introuvable", build_dir.display()),
        ));
    }

    let status = Command::new("cargo")
        .arg("build")
        .arg("--release")
        .current_dir(&build_dir)
        .status()?;

    if !status.success() {
        return Err(io::Error::new(io::ErrorKind::Other, "Cargo build failed"));
    }

    // Installation du binaire
    let mut bin_dir = dirs::home_dir().unwrap_or_default();
    bin_dir.push(".local/bin");
    fs::create_dir_all(&bin_dir)?;

    let mut built_bin = build_dir;
    built_bin.push("target/release/wai-runner");

    fs::copy(&built_bin, &runner_bin)?;
    
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = fs::metadata(&runner_bin)?.permissions();
        perms.set_mode(0o755);
        fs::set_permissions(&runner_bin, perms)?;
    }

    println!("  {} Le runner a été compilé avec succès et copié dans ~/.local/bin/wai-runner", style("✔").green());
    std::thread::sleep(std::time::Duration::from_secs(2));

    Ok(runner_bin)
}

// --- Installation & Désinstallation ---

fn download_icon(url: &str, dest: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let response = ureq::get(url).call()?;
    let mut file = File::create(dest)?;
    let mut body = response.into_reader();
    std::io::copy(&mut body, &mut file)?;
    Ok(())
}

fn install_single_app(app: &AppConfig, runner_path: &Path, auto_mode: bool) -> Result<(), Box<dyn std::error::Error>> {
    let display_name = app.name;
    println!("  {} Préparation de l'installation de {}", style("📥").cyan(), display_name);

    if check_is_installed(app) {
        if !auto_mode {
            print!("  {} {} est déjà installé. Le réinstaller ? (y/N) : ", style("⚠").yellow(), display_name);
            io::stdout().flush()?;
            let mut input = String::new();
            io::stdin().read_line(&mut input)?;
            if !input.trim().eq_ignore_ascii_case("y") {
                println!("  Installation annulée.");
                return Ok(());
            }
        }
        uninstall_single_app(app, true)?;
    }

    // Gérer les dépôts git (Tux-It)
    if let Some(repo) = app.repo {
        println!("  Compilation de Tux-It...");
        let temp_dir = std::env::temp_dir().join(format!("tux-it-install-{}", std::process::id()));
        if temp_dir.exists() {
            let _ = fs::remove_dir_all(&temp_dir);
        }

        // Clone
        let status = Command::new("git")
            .args(&["clone", "--depth", "1", repo])
            .arg(&temp_dir)
            .status()?;
        if !status.success() {
            return Err("Failed to clone Tux-It".into());
        }

        // Run install script
        let install_script = temp_dir.join("install.sh");
        if install_script.exists() {
            let status = Command::new("bash")
                .arg(&install_script)
                .current_dir(&temp_dir)
                .status()?;
            if !status.success() {
                return Err("Failed to execute Tux-It install script".into());
            }
        } else {
            return Err("Tux-It install.sh not found".into());
        }

        let _ = fs::remove_dir_all(&temp_dir);
        println!("  {} Tux-It installé avec succès !", style("✔").green());
        return Ok(());
    }

    // Créer le dossier local de l'application
    let mut app_dir = dirs::data_dir().unwrap_or_default();
    app_dir.push("wai/apps");
    app_dir.push(app.name);
    fs::create_dir_all(&app_dir)?;

    // Télécharger l'icône
    let icon_path = app_dir.join(format!("{}.png", app.key));
    print!("  Téléchargement de l'icône... ");
    io::stdout().flush()?;
    match download_icon(app.icon, &icon_path) {
        Ok(_) => println!("{}", style("✔").green()),
        Err(e) => {
            println!("{}", style("✖").red());
            return Err(format!("Erreur téléchargement icône: {}", e).into());
        }
    }

    // Créer le raccourci .desktop de l'utilisateur (sans sudo !)
    let mut desktop_dir = dirs::data_dir().unwrap_or_default();
    desktop_dir.push("applications");
    fs::create_dir_all(&desktop_dir)?;

    let desktop_file_path = desktop_dir.join(format!("{}.desktop", app.key));
    let mut desktop_file = File::create(&desktop_file_path)?;

    writeln!(desktop_file, "[Desktop Entry]")?;
    writeln!(desktop_file, "Version=1.0")?;
    writeln!(desktop_file, "Type=Application")?;
    writeln!(desktop_file, "Name={}", app.name)?;
    writeln!(desktop_file, "Comment={} web application", app.name)?;
    writeln!(
        desktop_file,
        "Exec={} --url \"{}\" --title \"{}\" --identifier \"{}\"",
        runner_path.display(),
        app.url,
        app.name,
        app.key
    )?;
    writeln!(desktop_file, "Icon={}", icon_path.display())?;
    writeln!(desktop_file, "Terminal=false")?;
    writeln!(desktop_file, "StartupWMClass={}", app.name)?;
    writeln!(desktop_file, "Categories={}", app.category)?;
    writeln!(desktop_file, "StartupNotify=true")?;

    // Mettre à jour les bases de données desktop de l'utilisateur
    let _ = Command::new("update-desktop-database")
        .arg(&desktop_dir)
        .status();

    println!("  {} Raccourci système créé dans ~/.local/share/applications/{}.desktop", style("✔").green(), app.key);
    println!("  {} {} a été installé avec succès !", style("✔").green(), app.name);
    println!();

    Ok(())
}

fn uninstall_single_app(app: &AppConfig, silent: bool) -> Result<(), Box<dyn std::error::Error>> {
    let display_name = app.name;
    if !silent {
        println!("  {} Désinstallation de {}", style("🗑️").red(), display_name);
        print!("  Êtes-vous sûr ? (y/N) : ");
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        if !input.trim().eq_ignore_ascii_case("y") {
            println!("  Désinstallation annulée.");
            return Ok(());
        }
    }

    if app.repo.is_some() {
        // Nettoyage Tux-It
        let paths_to_remove = vec![
            dirs::home_dir().unwrap_or_default().join(".local/bin/tux-it"),
            dirs::home_dir().unwrap_or_default().join(".local/share/icons/tux-it.png"),
            dirs::home_dir().unwrap_or_default().join(".local/share/applications/tux-it.desktop"),
        ];
        for path in paths_to_remove {
            if path.exists() {
                let _ = fs::remove_file(path);
            }
        }
    } else {
        // 1. Supprimer le dossier local de l'application
        let mut app_dir = dirs::data_dir().unwrap_or_default();
        app_dir.push("wai/apps");
        app_dir.push(app.name);
        if app_dir.exists() {
            fs::remove_dir_all(&app_dir)?;
        }

        // 2. Supprimer le lanceur desktop local
        let mut desktop_file = dirs::data_dir().unwrap_or_default();
        desktop_file.push("applications");
        desktop_file.push(format!("{}.desktop", app.key));
        if desktop_file.exists() {
            fs::remove_file(&desktop_file)?;
        }

        // 3. Supprimer l'éventuel lanceur desktop système (ancienne installation)
        let system_desktop = PathBuf::from(format!("/usr/share/applications/{}.desktop", app.key));
        if system_desktop.exists() {
            let _ = Command::new("sudo").arg("rm").arg(&system_desktop).status();
        }

        // 4. Supprimer l'éventuel dossier d'application dans /opt/ (ancienne installation)
        let system_opt_dir = PathBuf::from(format!("/opt/{}", app.name));
        if system_opt_dir.exists() {
            let _ = Command::new("sudo").arg("rm").arg("-rf").arg(&system_opt_dir).status();
        }

        // 5. Supprimer le dossier de session Tauri
        let mut session_dir = dirs::data_dir().unwrap_or_default();
        session_dir.push("com.devendev.wairunner/sessions");
        session_dir.push(app.key);
        if session_dir.exists() {
            fs::remove_dir_all(&session_dir)?;
        }

        // 6. Supprimer l'ancien profil Chrome (ancienne installation)
        let mut old_profile = dirs::home_dir().unwrap_or_default();
        old_profile.push(format!(".config/{}-profile", app.key));
        if old_profile.exists() {
            fs::remove_dir_all(&old_profile)?;
        }
    }

    // Refresh cache
    let mut desktop_dir = dirs::data_dir().unwrap_or_default();
    desktop_dir.push("applications");
    let _ = Command::new("update-desktop-database").arg(&desktop_dir).status();

    if !silent {
        println!("  {} {} désinstallé proprement.", style("✔").green(), display_name);
        std::thread::sleep(std::time::Duration::from_secs(1));
    }

    Ok(())
}

// --- Menu de gestion d'applications ---

fn handle_install_menu(apps: &[AppConfig]) -> Result<(), Box<dyn std::error::Error>> {
    let items: Vec<String> = apps.iter().map(|app| {
        let status = if check_is_installed(app) {
            style("[Installée]").green().to_string()
        } else {
            style("[Disponible]").dim().to_string()
        };
        format!("{} {}", app.name, status)
    }).collect();

    let mut menu_items = items.clone();
    menu_items.push(style("Tout installer").cyan().bold().to_string());
    menu_items.push(style("Retour au menu principal").red().to_string());

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Sélectionnez l'application à installer")
        .items(&menu_items)
        .default(0)
        .interact()?;

    if selection < apps.len() {
        let runner = ensure_runner_compiled()?;
        install_single_app(&apps[selection], &runner, false)?;
    } else if selection == apps.len() {
        // Tout installer
        let runner = ensure_runner_compiled()?;
        for app in apps {
            install_single_app(app, &runner, true)?;
        }
        println!("  {} Toutes les applications éligibles ont été installées !", style("✔").green());
        std::thread::sleep(std::time::Duration::from_secs(2));
    }

    Ok(())
}

fn handle_uninstall_menu(apps: &[AppConfig]) -> Result<(), Box<dyn std::error::Error>> {
    let installed_apps: Vec<&AppConfig> = apps.iter().filter(|app| check_is_installed(app)).collect();

    if installed_apps.is_empty() {
        print_header();
        println!("  {} Aucune application installée.", style("ℹ").cyan());
        std::thread::sleep(std::time::Duration::from_secs(1));
        return Ok(());
    }

    let mut menu_items: Vec<String> = installed_apps.iter().map(|app| app.name.to_string()).collect();
    menu_items.push(style("Tout désinstaller").red().bold().to_string());
    menu_items.push(style("Retour au menu principal").cyan().to_string());

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Sélectionnez l'application à désinstaller")
        .items(&menu_items)
        .default(0)
        .interact()?;

    if selection < installed_apps.len() {
        uninstall_single_app(installed_apps[selection], false)?;
    } else if selection == installed_apps.len() {
        // Tout désinstaller
        print!("  {} Êtes-vous sûr de vouloir tout désinstaller ? (y/N) : ", style("⚠").red());
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        if input.trim().eq_ignore_ascii_case("y") {
            for app in installed_apps {
                uninstall_single_app(app, true)?;
                println!("  {} {} désinstallé.", style("✔").green(), app.name);
            }
            println!("  {} Toutes les applications ont été supprimées.", style("✔").green());
            std::thread::sleep(std::time::Duration::from_secs(2));
        }
    }

    Ok(())
}

// --- Tableau de bord ---

fn show_dashboard(apps: &[AppConfig]) {
    println!("{}", style("  📊 TABLEAU DE BORD DES APPLICATIONS").cyan().bold());
    println!("  ──────────────────────────────────────────────────────────────");

    let mut installed_count = 0;
    for app in apps {
        if check_is_installed(app) {
            println!("    {} {} • {}", style("✔").green(), style(app.name).bold(), style("Installée").dim());
            installed_count += 1;
        } else {
            println!("    ○ {} • {}", style(app.name).dim(), style("Disponible").dim());
        }
    }
    println!("  ──────────────────────────────────────────────────────────────");
    if installed_count == 0 {
        println!("  {}", style("  Aucune application active pour le moment.").yellow());
    } else {
        println!("    {}/{} applications actives sur le système.", style(installed_count).green().bold(), apps.len());
    }
    println!();
}

// --- Gestion des Alias ---

fn handle_alias_menu() -> Result<(), Box<dyn std::error::Error>> {
    let mut alias_file = dirs::home_dir().unwrap_or_default();
    alias_file.push(".bash_aliases");

    let mut bashrc_file = dirs::home_dir().unwrap_or_default();
    bashrc_file.push(".bashrc");

    loop {
        print_header();
        println!("{}", style("  ⚙️ CONFIGURATION & ALIAS").cyan().bold());
        println!("  ──────────────────────────────────────────────────────────────");
        println!("  Fichier des alias : {}", style(alias_file.display()).magenta());
        println!();
        println!("{}", style("  📌 ALIAS DÉTECTÉS :").cyan());
        
        let mut aliases = Vec::new();
        if alias_file.exists() {
            if let Ok(content) = fs::read_to_string(&alias_file) {
                for line in content.lines() {
                    let trimmed = line.trim();
                    if trimmed.starts_with("alias ") {
                        aliases.push(trimmed.to_string());
                        println!("    {} {}", style("▶").green(), style(&trimmed[6..]).bold());
                    }
                }
            }
        }

        if bashrc_file.exists() {
            if let Ok(content) = fs::read_to_string(&bashrc_file) {
                for line in content.lines() {
                    let trimmed = line.trim();
                    if trimmed.starts_with("alias ") {
                        let alias_expr = &trimmed[6..];
                        if !alias_expr.starts_with("ls=")
                            && !alias_expr.starts_with("grep=")
                            && !alias_expr.starts_with("ll=")
                            && !alias_expr.starts_with("la=")
                            && !alias_expr.starts_with("l=")
                            && !alias_expr.starts_with("alert=")
                        {
                            let name = alias_expr.split('=').next().unwrap_or("").trim();
                            let exists_in_aliases = aliases.iter().any(|a| {
                                if let Some(eq_idx) = a.find('=') {
                                    a[6..eq_idx].trim() == name
                                } else {
                                    false
                                }
                            });

                            if !exists_in_aliases {
                                aliases.push(trimmed.to_string());
                                println!(
                                    "    {} {} {}",
                                    style("▶").green(),
                                    style(alias_expr).bold(),
                                    style("(dans .bashrc)").white().dim()
                                );
                            }
                        }
                    }
                }
            }
        }

        if aliases.is_empty() {
            println!("    {}", style("Aucun alias personnalisé détecté.").dim());
        }
        println!("  ──────────────────────────────────────────────────────────────");
        println!();

        let options = vec![
            "Ajouter un alias",
            "Modifier un alias",
            "Supprimer un alias",
            "Retour au menu principal",
        ];

        let selection = Select::with_theme(&ColorfulTheme::default())
            .with_prompt("Sélectionnez une option")
            .items(&options)
            .default(0)
            .interact()?;

        match selection {
            0 => {
                // Ajouter
                print_header();
                println!("{}", style("  ➕ AJOUTER UN ALIAS").cyan().bold());
                print!("  Nom de l'alias (ex: util) : ");
                io::stdout().flush()?;
                let mut name = String::new();
                io::stdin().read_line(&mut name)?;
                let name = name.trim();

                print!("  Commande ou dossier (ex: cd ~/Documents) : ");
                io::stdout().flush()?;
                let mut cmd = String::new();
                io::stdin().read_line(&mut cmd)?;
                let cmd = cmd.trim();

                if !name.is_empty() && !cmd.is_empty() {
                    let mut file = fs::OpenOptions::new()
                        .create(true)
                        .append(true)
                        .open(&alias_file)?;
                    writeln!(file, "alias {}='{}'", name, cmd)?;
                    
                    // Assurer le chargement dans .bashrc
                    if bashrc_file.exists() {
                        let bashrc_content = fs::read_to_string(&bashrc_file)?;
                        if !bashrc_content.contains("test -f ~/.bash_aliases") && !bashrc_content.contains(".bash_aliases") {
                            let mut file = fs::OpenOptions::new().append(true).open(&bashrc_file)?;
                            writeln!(file, "\n# Chargement des alias personnels\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi")?;
                        }
                    }
                    println!("  {} Alias ajouté avec succès !", style("✔").green());
                    std::thread::sleep(std::time::Duration::from_secs(1));
                }
            }
            1 => {
                // Modifier
                if aliases.is_empty() { continue; }
                let selection = Select::with_theme(&ColorfulTheme::default())
                    .with_prompt("Sélectionnez l'alias à modifier")
                    .items(&aliases)
                    .interact()?;
                
                let selected_alias = &aliases[selection];
                // Extraire le nom
                if let Some(eq_idx) = selected_alias.find('=') {
                    let name = selected_alias[6..eq_idx].trim();
                    println!("  Modification de l'alias : {}", style(name).bold());
                    print!("  Nouvelle commande : ");
                    io::stdout().flush()?;
                    let mut new_cmd = String::new();
                    io::stdin().read_line(&mut new_cmd)?;
                    let new_cmd = new_cmd.trim();

                    if !new_cmd.is_empty() {
                        let content = fs::read_to_string(&alias_file)?;
                        let mut new_lines = Vec::new();
                        for line in content.lines() {
                            if line.trim().starts_with(&format!("alias {}=", name)) {
                                new_lines.push(format!("alias {}='{}'", name, new_cmd));
                            } else {
                                new_lines.push(line.to_string());
                            }
                        }
                        fs::write(&alias_file, new_lines.join("\n") + "\n")?;
                        println!("  {} Alias modifié avec succès !", style("✔").green());
                        std::thread::sleep(std::time::Duration::from_secs(1));
                    }
                }
            }
            2 => {
                // Supprimer
                if aliases.is_empty() { continue; }
                let selection = Select::with_theme(&ColorfulTheme::default())
                    .with_prompt("Sélectionnez l'alias à supprimer")
                    .items(&aliases)
                    .interact()?;
                
                let selected_alias = &aliases[selection];
                if let Some(eq_idx) = selected_alias.find('=') {
                    let name = selected_alias[6..eq_idx].trim();
                    let content = fs::read_to_string(&alias_file)?;
                    let mut new_lines = Vec::new();
                    for line in content.lines() {
                        if !line.trim().starts_with(&format!("alias {}=", name)) {
                            new_lines.push(line.to_string());
                        }
                    }
                    fs::write(&alias_file, new_lines.join("\n") + "\n")?;
                    println!("  {} Alias supprimé !", style("✔").green());
                    std::thread::sleep(std::time::Duration::from_secs(1));
                }
            }
            _ => break,
        }
    }
    Ok(())
}

// --- Menu principal ---

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let apps = get_apps();
    loop {
        print_header();
        show_dashboard(&apps);

        let options = vec![
            "Installer une application",
            "Désinstaller une application",
            "Configuration & Alias",
            "Quitter",
        ];

        let selection = Select::with_theme(&ColorfulTheme::default())
            .with_prompt("Faites votre choix")
            .default(0)
            .items(&options)
            .interact()?;

        match selection {
            0 => {
                let _ = handle_install_menu(&apps);
            }
            1 => {
                let _ = handle_uninstall_menu(&apps);
            }
            2 => {
                let _ = handle_alias_menu();
            }
            _ => {
                println!("  Au revoir !");
                break;
            }
        }
    }
    Ok(())
}
