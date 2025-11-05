# DISCLAIMER: This script executes many system-wide changes. Use on a fresh system or with backups.

set -e

log() { printf "\n[+] %s\n" "$*"; }
warn() { printf "\n[!] %s\n" "$*" >&2; }
die() { printf "\n[✗] %s\n" "$*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Command '$1' is required but not found."; }

ensure_dir() { mkdir -p "$1"; }

file_exists() { [ -e "$1" ]; }

HOME_DIR="${HOME}"
DL="${HOME_DIR}/Downloads"

log "Update the system"
cd "${DL}" || mkdir -p "${DL}" && cd "${DL}"
sudo apt update -y

log "Install apps and dependencies"
sudo apt install -y \
  qttools5-dev-tools kate curl wget rsync git \
  dconf-cli sassc unzip zip

log "Install GNOME applications"
sudo apt install -y \
  nautilus gnome-terminal gnome-weather gnome-maps \
  gnome-calendar gnome-clocks gedit evince eog vlc

log "Download customization resource file (manual step)"
cat <<'EOT'
Selanjutnya install file zip di https://www.pling.com/p/2304796/,
atau kalau mau cepat langsung git clone dari repo kamu.
Install file berikut (letakkan di ~/Downloads):
  plasma6macos-albertlauncher-config.zip
  plasma6macos-albertlauncher-theme.zip
  plasma6macos-cursors.zip
  plasma6macos-fonts.zip
  plasma6macos-gnome-config.zip
  plasma6macos-gtk-theme.zip
  plasma6macos-icons.zip
  plasma6macos-kde-config.zip
  plasma6macos-kde-config-manjaro.zip
  plasma6macos-kvantum-config.zip
  plasma6macos-kwin-effect.zip
  plasma6macos-plasma-theme.zip
  plasma6macos-plasmoids.zip
  plasma6macos-plymouth-config.zip (opsional)
  plasma6macos-sddm.zip
  plasma6macos-sddm-manjaroarch.zip
  plasma6macos-wallpapers.zip
  plasma6macos-zshstarship-konsole.zip
  Plasma6macosMacOS_30.zip
EOT

log "Installing KDE Plasma theme"
if file_exists "${DL}/Plasma6macosMacOS_30.zip"; then
  unzip -o "${DL}/Plasma6macosMacOS_30.zip"
else
  warn "Plasma6macosMacOS_30.zip not found in ${DL} (continuing)."
fi

if file_exists "${DL}/plasma6macos-plasma-theme.zip"; then
  unzip -o "${DL}/plasma6macos-plasma-theme.zip" -d "${HOME_DIR}/.local/share"
else
  warn "plasma6macos-plasma-theme.zip not found (continuing)."
fi

log "Prepare ~/.themes"
ensure_dir "${HOME_DIR}/.themes"

log "Installing GTK themes"
if file_exists "${DL}/plasma6macos-gtk-theme.zip"; then
  unzip -o "${DL}/plasma6macos-gtk-theme.zip" -d "${HOME_DIR}/.themes"
else
  warn "plasma6macos-gtk-theme.zip not found (continuing)."
fi

log "Enable light themes for libadwaita apps"
ensure_dir "${HOME_DIR}/.config/gtk-4.0"
ln -sf "${HOME_DIR}/.themes/MacTahoe-Light/gtk-4.0/assets" "${HOME_DIR}/.config/gtk-4.0/" || true
ln -sf "${HOME_DIR}/.themes/MacTahoe-Light/gtk-4.0/gtk.css" "${HOME_DIR}/.config/gtk-4.0/" || true
ln -sf "${HOME_DIR}/.themes/MacTahoe-Light/gtk-4.0/gtk-dark.css" "${HOME_DIR}/.config/gtk-4.0/" || true

log "Install Kvantum and themes"
sudo apt install -y qt-style-kvantum qt-style-kvantum-themes
ensure_dir "${HOME_DIR}/.config/Kvantum"

if file_exists "${DL}/plasma6macos-kvanum-config"; then
  unzip -o "${DL}/plasma6macos-kvanum-config" -d "${HOME_DIR}/.config/Kvantum" || true
elif file_exists "${DL}/plasma6macos-kvantum-config.zip"; then
  unzip -o "${DL}/plasma6macos-kvantum-config.zip" -d "${HOME_DIR}/.config/Kvantum" || true
else
  warn "Kvantum config archive not found (continuing)."
fi

if kvantummanager --version >/dev/null 2>&1; then
  log "kvantummanager detected."
else
  log "kvantummanager not found, installing as instructed."
  sudo apt install -y kvantum kvantum-manager qt5-style-kvantum
fi

log "Install Darkly (sequence as provided)"
cd "${DL}"
sudo apt install -y git cmake g++ qtbase5-dev qttools5-dev-tools

if curl -L -o darkly.deb https://github.com/Bali10050/Darkly/releases/download/v0.5.21/darkly_0.5.21_amd64.deb; then
  sudo apt install ./darkly.deb || true
else
  warn "Failed to download darkly .deb (continuing to fallback steps)."
fi

# Fallback steps on error
sudo apt update
sudo apt install -y \
  build-essential cmake git \
  qt6-base-dev qt6-tools-dev \
  extra-cmake-modules \
  libkf6coreaddons-dev libkf6config-dev libkf6i18n-dev \
  libkf6windowsystem-dev libkf6iconthemes-dev

if [ -d "${DL}/Darkly" ]; then
  cd "${DL}/Darkly"
  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build
else
  warn "Darkly source directory (${DL}/Darkly) not found; skipping source build steps until it exists."
fi

# Additional sequence
rm -rf "${DL}/Darkly/build" || true

sudo apt update
sudo apt install -y \
  qt6-base-dev qt6-tools-dev qt6-declarative-dev libqt6svg6-dev qt6-wayland-dev \
  extra-cmake-modules \
  libkf6coreaddons-dev libkf6config-dev libkf6configwidgets-dev \
  libkf6i18n-dev libkf6windowsystem-dev libkf6iconthemes-dev libkf6kcmutils-dev

if [ -d "${DL}/Darkly" ]; then
  cd "${DL}/Darkly"
  cmake -S . -B build -DBUILD_QT6=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build

  cd "${DL}/Darkly"
  rm -rf build
  ./install.sh QT6 || true

  sudo apt install -y libkf6kirigamiplatform-dev

  cd "${DL}/Darkly"
  ./install.sh QT6 || true

  cd "${DL}/Darkly"
  cmake -S . -B build -DBUILD_QT6=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DDISABLE_KIRIGAMI_PLATFORM=ON
  cmake --build build -j"$(nproc)"
  sudo cmake --install build

  echo "deb http://archive.neon.kde.org/user jammy main" | sudo tee /etc/apt/sources.list.d/neon.list
  wget -qO - https://archive.neon.kde.org/public.key | sudo apt-key add -
  sudo apt update
  sudo apt install -y libkf6kirigamiplatform-dev

  sudo apt install -y libxkbcommon-dev libxkbcommon-x11-dev

  cd "${DL}/Darkly"
  sed -i 's/find_package(KF6KirigamiPlatform ${KF6_MIN_VERSION} REQUIRED)/find_package(KF6KirigamiPlatform ${KF6_MIN_VERSION} CONFIG QUIET)/' CMakeLists.txt

  rm -rf build
  cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build

  sudo apt install -y libkdecorations3-dev frameworkintegration6 libkf6style-dev

  cd "${DL}/Darkly"
  rm -rf build
  cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build

  cd "${DL}/Darkly"
  sed -i 's/KF6::KirigamiPlatform[ ]*//g' kstyle6/CMakeLists.txt

  rm -rf build
  cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build

  cd "${DL}/Darkly"
  grep -n "KirigamiPlatform" kstyle/CMakeLists.txt || true
  sed -i 's/KF6::KirigamiPlatform[ ]*//g' kstyle/CMakeLists.txt

  rm -rf build
  cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build -j"$(nproc)"
  sudo cmake --install build
else
  warn "Darkly source directory not found; skipped subsequent Darkly steps."
fi

log "Install icon theme"
ensure_dir "${HOME_DIR}/.local/share/icons"
if file_exists "${DL}/plasma6macos-icons.zip"; then
  unzip -o "${DL}/plasma6macos-icons.zip" -d "${HOME_DIR}/.local/share/icons"
else
  warn "plasma6macos-icons.zip not found (continuing)."
fi

log "Install cursors theme"
ensure_dir "${HOME_DIR}/.icons"
if file_exists "${DL}/plasma6macos-cursors.zip"; then
  unzip -o "${DL}/plasma6macos-cursors.zip" -d "${HOME_DIR}/.icons"
else
  warn "plasma6macos-cursors.zip not found (continuing)."
fi

log "Install fonts pack"
if file_exists "${DL}/plasma6macos-fonts.zip"; then
  unzip -o "${DL}/plasma6macos-fonts.zip" -d "${HOME_DIR}/.local/share"
else
  warn "plasma6macos-fonts.zip not found (continuing)."
fi
ls -al "${HOME_DIR}/.local/share/fonts" || true

log "Install wallpapers"
if file_exists "${DL}/plasma6macos-wallpapers.zip"; then
  sudo unzip -o "${DL}/plasma6macos-wallpapers.zip" -d /usr/share/wallpapers
else
  warn "plasma6macos-wallpapers.zip not found (continuing)."
fi

ls -al "${HOME_DIR}/usr/share/wallpapers/Plasma-Tahoe" || true

log "Install plasmoids widgets"
if file_exists "${DL}/plasma6macos-plasmoids.zip"; then
  unzip -o "${DL}/plasma6macos-plasmoids.zip" -d "${HOME_DIR}/.local/share/plasma"
else
  warn "plasma6macos-plasmoids.zip not found (continuing)."
fi

ls -al "${HOME_DIR}/usr/share/plasma/plasmoids" || true

log "Install KWin effects and scripts"
if file_exists "${DL}/plasma6macos-kwin-effect.zip"; then
  unzip -o "${DL}/plasma6macos-kwin-effect.zip" -d "${HOME_DIR}/.local/share"
else
  warn "plasma6macos-kwin-effect.zip not found (continuing)."
fi

ls -al "${HOME_DIR}/usr/.local/share/kwin" || true

log "Install SDDM theme and config"
if file_exists "${DL}/plasma6macos-sddm.zip"; then
  if sudo unzip -o "${HOME_DIR}/Donwloads/plasma6macos-sddm.zip" -d / 2>/dev/null; then
    :
  else
    sudo unzip -o "${DL}/plasma6macos-sddm.zip" -d / || true
  fi
else
  warn "plasma6macos-sddm.zip not found (continuing)."
fi

ls -al "${HOME_DIR}/usr/share/sddm/themes" || true

log "Install Plymouth theme macOS styles (optional)"
sudo apt install -y plymouth plymouth-themes plymouth-x11 || true

if file_exists "${DL}/plasma6macos-plymouth-config.zip"; then
  sudo unzip -o "${DL}/plasma6macos-plymouth-config.zip" -d /usr/share/plymouth/themes/
else
  warn "plasma6macos-plymouth-config.zip not found (optional; continuing)."
fi

ls /usr/share/plymouth/themes || true
sudo plymouth-set-default-theme -R macos || true

log "Install Albert launcher"
cd "${DL}"
if wget -q https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/amd64/albert_0.23.1-0_amd64.deb; then
  sudo apt install ./albert_0.23.1-0_amd64.deb || true
else
  warn "Failed to fetch albert_0.23.1-0_amd64.deb"
fi

if ! command -v albert >/dev/null 2>&1; then
  log "Trying next Albert package..."
  if wget -q https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/amd64/albert_0.27.8-0+701.2_amd64.deb; then
    sudo apt install ./albert_0.27.8-0+701.2_amd64.deb || true
  else
    warn "Failed to fetch albert_0.27.8-0+701.2_amd64.deb"
  fi
fi

if ! command -v albert >/dev/null 2>&1; then
  log "Adding OpenSUSE repo for Albert as instructed"
  curl -fsSL https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null
  echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home_manuelschneid3r.list
  sudo apt update
  sudo apt install -y albert || true
fi

log "Install Albert config and theme"
if file_exists "${DL}/plasma6macos-albertlauncher-config.zip"; then
  unzip -o "${DL}/plasma6macos-albertlauncher-config.zip" -d "${HOME_DIR}"
else
  warn "plasma6macos-albertlauncher-config.zip not found (continuing)."
fi

ls -al "${HOME_DIR}/.config/albert" || true

if file_exists "${DL}/plasma6macos-albertlauncher-theme.zip"; then
  sudo unzip -o "${DL}/plasma6macos-albertlauncher-theme.zip" -d /
else
  warn "plasma6macos-albertlauncher-theme.zip not found (continuing)."
fi

ls -al /usr/share/albert/widgetsboxmodel/themes || true
ls -al /usr/share/albert/widgetsboxmode-ng/themes || true

log "Install Zsh shell"
sudo apt install -y zsh

log "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" <<'EOF'
Y
EOF

log "Install oh-my-zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME_DIR}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME_DIR}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/zsh-users/zsh-history-substring-search "${HOME_DIR}/.oh-my-zsh/custom/plugins/zsh-history-substring-search" || true

log "Install Starship"
curl -sS https://starship.rs/install.sh | sh || true

if file_exists "${DL}/plasma6macos-zshstarship-konsole.zip"; then
  unzip -o "${DL}/plasma6macos-zshstarship-konsole.zip" -d "${HOME_DIR}"
else
  warn "plasma6macos-zshstarship-konsole.zip not found (continuing)."
fi

log "Install KDE Plasma6 macOS global config"
kquitapp6 plasmashell || true

if file_exists "${DL}/plasma6macos-kde-config.zip"; then
  unzip -o "${DL}/plasma6macos-kde-config.zip" -d "${HOME_DIR}"
else
  warn "plasma6macos-kde-config.zip not found (continuing)."
fi

if file_exists "${DL}/plasma6macos-kde-config-manjaro.zip"; then
  unzip -o "${DL}/plasma6macos-kde-config-manjaro.zip" -d "${HOME_DIR}"
else
  warn "plasma6macos-kde-config-manjaro.zip not found (continuing)."
fi

kstart plasmashell &> /dev/null &

log "Attempt KDE logout via qdbus (Qt6 variants first)"
if ! qdbus6-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null; then
  log "Fallback to qdbus (Qt5/Qt6)"
  qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null || true
  sudo apt install -y qdbus-qt6 || true
  sudo apt install -y qt6-base-dev-tools || true
  whereis qdbus6-qt6 || true
  if [ -x /usr/lib/qt6/bin/qdbus6-qt6 ]; then
    /usr/lib/qt6/bin/qdbus6-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout || true
  fi
  if [ -x /usr/lib/qt6/bin/qdbus ]; then
    /usr/lib/qt6/bin/qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout || true
  fi
  qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null || true
fi

kquitapp6 plasmashell && kstart plasmashell &

log "Restart laptop (manual)"
echo "Silakan restart laptop kamu secara manual untuk menerapkan semua perubahan."

log "Jika ada error 'Sorry! There was an error loading Panel Spacer Extended.'"
cat <<'EOT'
file:///home/user/.local/share/plasma/plasmoids/luisbocanegra.panelspacer.extended/contents/ui/main.qml:13:1: module "org.kde.plasma.private.quicklaunch" is not installed

Jalankan:
  sudo apt install plasma-widgets-addons -y
  kquitapp6 plasmashell && kstart plasmashell &
EOT

log "Selesai mengikuti semua step-by-step yang diberikan."
