use clap::Parser;
use std::path::PathBuf;
use tauri::{WebviewUrl, WebviewWindowBuilder, Manager};

#[derive(Parser, Debug)]
#[command(author, version, about = "WAI Runner - A lightweight Tauri webview wrapper for web applications", long_about = None)]
struct Args {
    /// The URL of the web application to load (must start with http:// or https://)
    #[arg(short, long)]
    url: String,

    /// The title of the window
    #[arg(short, long, default_value = "WAI Web App")]
    title: String,

    /// Unique identifier for the app session (used for isolating user data / cookie storage)
    #[arg(short, long)]
    identifier: Option<String>,

    /// Custom user data directory path for session isolation
    #[arg(short = 'd', long)]
    user_data_dir: Option<PathBuf>,

    /// Initial window width
    #[arg(short = 'w', long, default_value_t = 1200.0)]
    width: f64,

    /// Initial window height
    #[arg(short = 'g', long, default_value_t = 800.0)]
    height: f64,

    /// Open Web Inspector (DevTools) on launch
    #[arg(long)]
    devtools: bool,
}

fn main() {
    let args = Args::parse();
    
    // Parse target URL
    let url_str = args.url.clone();
    if !url_str.starts_with("http://") && !url_str.starts_with("https://") {
        eprintln!("Error: The URL must start with http:// or https://");
        std::process::exit(1);
    }
    
    let target_url = match url_str.parse() {
        Ok(parsed) => WebviewUrl::External(parsed),
        Err(e) => {
            eprintln!("Error parsing URL: {}", e);
            std::process::exit(1);
        }
    };

    let title = args.title.clone();
    let width = args.width;
    let height = args.height;
    let identifier = args.identifier.clone();
    let user_data_dir = args.user_data_dir.clone();
    let enable_devtools = args.devtools;

    tauri::Builder::default()
        .setup(move |app| {
            // Determine session data directory path for isolation
            let data_dir = if let Some(dir) = user_data_dir {
                Some(dir)
            } else if let Some(ref id) = identifier {
                // Isolate by appending the identifier to standard user data directory
                if let Ok(app_data_dir) = app.path().app_data_dir() {
                    let mut path = app_data_dir;
                    path.push("sessions");
                    path.push(id);
                    Some(path)
                } else {
                    None
                }
            } else {
                None
            };

            let mut builder = WebviewWindowBuilder::new(
                app,
                "main",
                target_url,
            )
            .title(&title)
            .inner_size(width, height)
            .resizable(true);

            // Apply data directory if set (provides isolation for WebKitGTK / WebView2)
            if let Some(ref path) = data_dir {
                // Ensure directory exists
                let _ = std::fs::create_dir_all(path);
                builder = builder.data_directory(path.clone());
            }

            let window = builder.build().expect("failed to build window");
            
            if enable_devtools {
                window.open_devtools();
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
