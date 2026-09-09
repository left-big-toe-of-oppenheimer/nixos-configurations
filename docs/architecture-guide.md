# 📘 Guida Completa all'Architettura NixOS & Gestione Configurazioni

Benvenuto nel tuo sistema NixOS. Questa configurazione segue un'architettura **modulare, scalabile, trasparente e conforme al principio KISS ("Keep It Simple, Stupid")**, senza metalinguaggi oscuri o script fragili.

Questa guida documenta la struttura del sistema, come gestire pacchetti e servizi, il sistema di theming centralizzato e la gestione dei file di configurazione (gestiti centralmente da Home Manager vs stati mutabili locali come LocalSend o KDE Plasma).

---

## 🏗️ 1. Mappa dell'Architettura

Tutto il sistema operativo è contenuto dentro `/etc/nixos/` (collegato tramite symlink anche a `~/nixos`) ed è versionato con Git.

```mermaid
graph TD
    subgraph Core ["Punto di Ingresso Unico"]
        FLAKE["flake.nix"]
    end

    subgraph System ["Livello Sistema (NixOS System)"]
        HOST["hosts/nixos/configuration.nix"]
        HW["hosts/nixos/hardware-configuration.nix"]
        MOD_SYS["modules/system/"]
        MOD_SERV["modules/system/services/"]
        MOD_SOFT["modules/software/"]
        
        MOD_SOFT_CLI["modules/software/cli-tools.nix"]
        MOD_SOFT_DESK["modules/software/desktop-apps.nix"]
        MOD_SOFT_DEV["modules/software/dev-tools.nix"]
    end

    subgraph User ["Livello Utente (Home Manager)"]
        HOME["users/luigi/home.nix"]
        THEME["users/luigi/theme.nix<br/>(Master Theme Switcher)"]
        PROGS["users/luigi/programs/"]
        PROGS_AUTO["users/luigi/programs/default.nix<br/>(Auto-discovery)"]
        NVIM_DIR["users/luigi/programs/nvim/lua/"]
    end

    subgraph Scripts ["Automazioni & Helper"]
        SCRIPTS["scripts/"]
        SCRIPTS_AP["add-program.sh / rm-program.sh"]
        SCRIPTS_AS["add-service.sh / rm-service.sh"]
    end

    FLAKE --> HOST
    FLAKE --> HOME

    HOST --> HW
    HOST --> MOD_SYS
    HOST --> MOD_SERV
    HOST --> MOD_SOFT

    MOD_SOFT --> MOD_SOFT_CLI
    MOD_SOFT --> MOD_SOFT_DESK
    MOD_SOFT --> MOD_SOFT_DEV

    HOME --> THEME
    HOME --> PROGS
    PROGS --> PROGS_AUTO
    PROGS --> NVIM_DIR

    SCRIPTS --> SCRIPTS_AP
    SCRIPTS --> SCRIPTS_AS
```

### Separazione delle Responsabilità:
- **[`flake.nix`](../flake.nix)**: Il punto di ingresso dichiarativo con blocco Flakes e integrazione Home Manager.
- **`hosts/nixos/`**: Configurazione legata all'hardware di questo specifico PC.
- **`modules/system/`**: Bootloader, PipeWire audio, NetworkManager, SDDM e servizi di sistema.
- **`modules/system/services/`**: Demoni di sistema (OpenSSH, keyd, udisks2, gvfs) con **auto-importing automatico**.
- **`modules/software/`**: Pacchetti di sistema suddivisi logicamente (`cli-tools.nix`, `desktop-apps.nix`, `dev-tools.nix`).
- **`users/luigi/`**: Configurazione utente Home Manager (dotfiles, terminale, shell, editor e theming).
- **`scripts/`**: Helper CLI leggeri e sicuri per creare/rimuovere moduli senza modificare file manualmente.

---

## 📦 2. Gestione Software: Aggiungere e Rimuovere Programmi

Il sistema adotta un'unica e trasparente **Sorgente di Verità (Single Source of Truth)**.

### Caso A: Installare un Programma Semplice (99% dei casi)
Per installare utility come `vlc`, `fastfetch`, `gimp`, `htop`, `tmux`, ecc., **non serve creare nuovi file .nix**. 

Basta aprire il file della categoria desiderata in `modules/software/` e aggiungere il nome del pacchetto all'elenco:

| Categoria | File | Esempi di Pacchetti |
| :--- | :--- | :--- |
| **Strumenti CLI & Terminale** | [`modules/software/cli-tools.nix`](../modules/software/cli-tools.nix) | `ripgrep`, `fd`, `fastfetch`, `htop`, `ffmpeg` |
| **Applicazioni Desktop GUI** | [`modules/software/desktop-apps.nix`](../modules/software/desktop-apps.nix) | `vlc`, `gimp`, `obsidian`, `discord`, `mpv` |
| **Strumenti di Sviluppo & Compilatori** | [`modules/software/dev-tools.nix`](../modules/software/dev-tools.nix) | `clang`, `gdb`, `valgrind`, `rustc`, Python Stack |
| **Pacchetti Solo-Utente** | [`users/luigi/home.nix`](../users/luigi/home.nix) | Pacchetti in `home.packages` |

Dopo aver salvato, applica con:
```bash
rebuild
```

---

### Caso B: Creare un Modulo Programma Configurato (Home Manager)
Per programmi che richiedono configurazioni personalizzate, plugin o dotfiles specifici (es. `tmux`, `zsh`, `wezterm`, `neovim`):

Grazie all'**Auto-Discovery** presente in [`users/luigi/programs/default.nix`](../users/luigi/programs/default.nix), qualunque file `.nix` inserito nella cartella `programs/` viene importato automaticamente da Home Manager. **Non devi mai toccare `default.nix`**.

Puoi usare i comandi helper:

```bash
# 1. Crea lo scheletro del modulo e lo traccia in Git:
add-program tmux

# 2. (Opzionale) Modifica users/luigi/programs/tmux.nix per aggiungere opzioni

# 3. Rimuove il modulo e ne programma la cancellazione:
rm-program tmux
```

Per i servizi di sistema:
```bash
add-service syncthing    # Crea modules/system/services/syncthing.nix
rm-service syncthing     # Rimuove modules/system/services/syncthing.nix
```

---

## 🎨 3. Il Sistema di Theming Centralizzato (1 Single Line Switch)

Il theming del tuo ambiente è governato da un master switch in [`users/luigi/theme.nix`](../users/luigi/theme.nix).

### Come Cambiare Stile
Apri [`users/luigi/theme.nix`](../users/luigi/theme.nix) e decommenta **UNA** sola riga:

```nix
# ==============================================================================
# Global Theme Switcher
# Uncomment ONE line to set the active style across WezTerm, Neovim, Zsh, & Bat:
# ==============================================================================
"tokyonight"   # Stile 1: High-Contrast Solid (Tokyo Night, Opacità 1.0, Neovim Solido, Prompt RobbyRussell)
# "catppuccin" # Stile 2: Translucent Aesthetic (Catppuccin Mocha, Opacità 0.80, Neovim Trasparente, Prompt Flottante)
```

Poi esegui `rebuild`. In un solo colpo cambieranno:
1. **WezTerm** ([`wezterm.nix`](../users/luigi/programs/wezterm.nix)): Opacità della finestra (1.0 solido vs 0.80 vetro) e palette colori.
2. **Neovim** ([`nvim/lua/plugins/theme.lua`](../users/luigi/programs/nvim/lua/plugins/theme.lua)): Colori e trasparenza letti tramite la variabile standard `vim.g.theme_style`.
3. **Zsh** ([`zsh.nix`](../users/luigi/programs/zsh.nix)): Prompt `robbyrussell` pulito e ad alto contrasto vs prompt casuale.
4. **Bat** ([`bat.nix`](../users/luigi/programs/bat.nix)): `TwoDark` ad alto contrasto vs `Catppuccin Mocha`.

---

## 🔍 4. Anatomia delle Configurazioni: File Gestiti vs Stati Locali

Nel tuo sistema Linux coesistono tre categorie distinte di file di configurazione e dati nella cartella home (`~`):

```mermaid
graph TD
    subgraph Cat1 ["1. Dotfiles Dichiarativi Gestiti (Home Manager)"]
        HM_ZSH["~/.zshrc"]
        HM_WEZ["~/.config/wezterm/wezterm.lua"]
        HM_NVIM["~/.config/nvim/"]
        HM_GIT["~/.config/git/config"]
        HM_BAT["~/.config/bat/config"]
    end

    subgraph Cat2 ["2. Stati Runtime & App Locali (Non Gestiti da Nix)"]
        APP_LOCAL["LocalSend<br/>(~/.local/share/org.localsend.localsend_app/)"]
        APP_KDE["KDE Plasma 6 & KWin<br/>(~/.config/kdeglobals, kwinrc, plasmarc)"]
        APP_GUI["App Desktop<br/>(~/.config/dolphinrc, okularrc, spectaclerc)"]
        APP_BROWSER["Browser State<br/>(~/.mozilla/firefox/, ~/.config/falkon/)"]
    end

    subgraph Cat3 ["3. Cache, Cronologie & File Effimeri"]
        STATE_HIST["~/.zsh_history"]
        STATE_CACHE["~/.cache/"]
        STATE_LAZY["~/.local/share/nvim/lazy/"]
    end

    NIX_STORE[("/nix/store/<br/>Immutabile & Read-Only")] -.->|Symlink| Cat1
```

---

### Categoria 1: Dotfiles Centralizzati e Immutabili (Home Manager)
- **Cosa sono**: Configurazioni generate direttamente da NixOS in `/etc/nixos/users/luigi/programs/`.
- **Come vivono nel disco**: Sono **symlink** che puntano dentro `/nix/store/...` (in sola lettura).
  - `~/.zshrc` -> `/nix/store/...-home-manager-files/.zshrc`
  - `~/.config/wezterm/wezterm.lua` -> `/nix/store/...-home-manager-files/.config/wezterm/wezterm.lua`
  - `~/.config/nvim/lua` -> `/nix/store/...-home-manager-files/.config/nvim/lua`
  - `~/.config/git/config` -> `/nix/store/...-home-manager-files/.config/git/config`
  - `~/.config/bat/config` -> `/nix/store/...-home-manager-files/.config/bat/config`
- **Regole Fondamentali**:
  - ❌ **Non modificarli a mano dentro `~/.config/`**: Qualunque modifica manuale verrebbe sovrascritta al prossimo `rebuild`.
  - ✅ **Modificali in `/etc/nixos/users/luigi/`**: Cambia il file sorgente in Nix/Lua e lancia `rebuild`.

---

### Categoria 2: Stati Runtime & App Non Gestite Centralmente (es. LocalSend, Plasma 6)
- **Cosa sono**: Applicazioni che memorizzano stati dinamici, chiavi crittografiche, abbinamenti di rete o preferenze grafiche direttamente durante l'utilizzo.

#### Il caso di **LocalSend**:
- LocalSend salva i propri dati in `~/.local/share/org.localsend.localsend_app/`.
- **Cosa contiene**:
  - Chiavi TLS e certificati locali per il trasferimento file sicuro.
  - Abbinamento dispositivi fidati sulla rete locale (LAN).
  - Cronologia dei trasferimenti e cartella di download predefinita.
- **Perché NON è gestito in Nix**: Se LocalSend fosse vincolato a un file immutabile in `/nix/store`, l'applicazione non potrebbe generare certificati dinamici né ricordare i dispositivi associati a runtime.

#### Il caso di **KDE Plasma 6 & KWin**:
- I file di Plasma (come `~/.config/kdeglobals`, `~/.config/kwinrc`, `~/.config/plasma-org.kde.plasma.desktop-appletsrc`, `~/.config/kglobalshortcutsrc`):
  - Sono modificati continuamente dal server grafico (spostamento widget, ridimensionamento finestre, regole monitor in `kwinoutputconfig.json`).
  - Rimangono file locali scrivibili per consentire a Plasma di salvare lo stato senza andare in conflitto con i link immutabili di Nix.

#### Il caso di altre App GUI (Dolphin, Spectacle, Okular, MPV, Firefox):
- `~/.config/dolphinrc`: Posizione pannelli e modalità di visualizzazione cartelle.
- `~/.config/spectaclerc`: Scorciatoie e impostazioni OCR dello strumento screenshot.
- `~/.mozilla/firefox/`: Cookie, sessioni aperte, credenziali salvate nel password manager.

---

### Categoria 3: Cache, Cronologie e Dati Temporanei
- **`~/.zsh_history`**: Il registro dei comandi eseguiti nella shell (file mutabile, append-only).
- **`~/.cache/`**: Cache delle miniature, font, bat cache (`bat.bin`), shader GPU.
- **`~/.local/share/nvim/lazy/`**: Repository Git dei plugin di Neovim scaricati da LazyVim.
- **Caratteristica**: Possono essere cancellati in qualsiasi momento; verranno rigenerati automaticamente dal sistema o dai programmi.

---

### 🛡️ Protezione Automatica Conflitti (`backupFileExtension = "backup"`)
In [`flake.nix`](../flake.nix) è configurata la direttiva:
```nix
home-manager.backupFileExtension = "backup";
```
Se un programma genera un file regolare in `~/.config` che entra in collisione con un nuovo modulo Home Manager, Home Manager rinomina automaticamente il file vecchio in `.backup` invece di bloccare il build del sistema.

---

## ⚡ 5. Cheat Sheet dei Comandi

### Operazioni Quotidiane
```bash
# Applica tutte le modifiche alla configurazione (alias di sudo nixos-rebuild switch --flake /etc/nixos)
rebuild

# Entra direttamente nella directory di configurazione
conf

# Cerca un pacchetto nei repository Nixpkgs
nix search nixpkgs <nome>

# Esegui un programma al volo senza installarlo permanentemente
nix-shell -p <nome>
# oppure
nix run nixpkgs#<nome>

# Pulisci generazioni vecchie e libera spazio su disco
sudo nix-collect-garbage -d
```

### Gestione Moduli Rapida
```bash
# Crea un modulo programma in users/luigi/programs/<nome>.nix
add-program <nome>

# Rimuove un modulo programma
rm-program <nome>

# Crea un modulo servizio in modules/system/services/<nome>.nix
add-service <nome>

# Rimuove un modulo servizio
rm-service <nome>
```

---

*Guida aggiornata e sincronizzata con l'architettura attiva in `/etc/nixos`.*
