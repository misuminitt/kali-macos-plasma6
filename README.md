# MacOS Tahoe Theme in Kali Linux

Transform Kali Linux (KDE Plasma 6) into a macOS-style desktop — complete with themes, icons, cursors, widgets, SDDM, Plymouth boot animation, Albert launcher, and Zsh + Starship setup.
This project compiles all tested steps to achieve a stable and beautiful macOS-like look on Kali without breaking KDE components.

## Requirements

Run these first:

```bash
sudo apt update -y
sudo apt install -y qttools5-dev-tools kate curl wget rsync git dconf-cli sassc unzip zip
```

```bash
sudo apt install -y nautilus gnome-terminal gnome-weather gnome-maps gnome-calendar gnome-clocks gedit evince eog vlc
```

## Download All Required Packages

You can download the ZIP packs from:
**[https://www.pling.com/p/2304796/](https://www.pling.com/p/2304796/)**

or just clone this repo
```bash
git clone https://github.com/misuminitt/kali-macos-plasma6.git
```

Once you’ve cloned the repo, if you’re too lazy to go through all the steps manually, just run this script instead :
```bash
chmod +x auto_runner_kde_macos.sh
bash ./auto_runner_kde_macos.sh
```


Then place them inside your `~/Downloads/` folder:

```
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
plasma6macos-plymouth-config.zip
plasma6macos-sddm.zip
plasma6macos-sddm-manjaroarch.zip
plasma6macos-wallpapers.zip
plasma6macos-zshstarship-konsole.zip
Plasma6macosMacOS_30.zip
```

## Plasma Theme (macOS Tahoe)

```bash
cd ~/Downloads
unzip Plasma6macosMacOS_30.zip
unzip -o plasma6macos-plasma-theme.zip -d ~/.local/share
```

## GTK Theme (MacTahoe Light/Dark)

```bash
mkdir -p ~/.themes
unzip -o plasma6macos-gtk-theme.zip -d ~/.themes

mkdir -p ~/.config/gtk-4.0
ln -sf ~/.themes/MacTahoe-Light/gtk-4.0/assets ~/.config/gtk-4.0/
ln -sf ~/.themes/MacTahoe-Light/gtk-4.0/gtk.css ~/.config/gtk-4.0/
ln -sf ~/.themes/MacTahoe-Light/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/
```

## Kvantum (Qt Style Engine)

```bash
sudo apt install -y qt-style-kvantum qt-style-kvantum-themes
mkdir -p ~/.config/Kvantum
unzip -o plasma6macos-kvantum-config.zip -d ~/.config/Kvantum
```

If you don’t have Kvantum Manager:

```bash
sudo apt install -y kvantum kvantum-manager qt5-style-kvantum
```

## Darkly (Qt6 / KF6 Style)

### Option A – Prebuilt `.deb` installer

```bash
cd ~/Downloads
curl -L -o darkly.deb https://github.com/Bali10050/Darkly/releases/download/v0.5.21/darkly_0.5.21_amd64.deb
sudo apt install ./darkly.deb
```

### Option B – Build manually (for Plasma 6)

Install dependencies:

```bash
sudo apt install -y build-essential cmake git \
qt6-base-dev qt6-tools-dev qt6-declarative-dev libqt6svg6-dev qt6-wayland-dev \
extra-cmake-modules \
libkf6coreaddons-dev libkf6config-dev libkf6configwidgets-dev \
libkf6i18n-dev libkf6windowsystem-dev libkf6iconthemes-dev libkf6kcmutils-dev \
libkdecorations3-dev frameworkintegration6 libkf6style-dev \
libxkbcommon-dev libxkbcommon-x11-dev
```

Build:

```bash
cd ~/Downloads/Darkly
rm -rf build
cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)"
sudo cmake --install build
```

If you get **KirigamiPlatform missing** error:

```bash
sed -i 's/KF6::KirigamiPlatform[ ]*//g' kstyle6/CMakeLists.txt
sed -i 's/KF6::KirigamiPlatform[ ]*//g' kstyle/CMakeLists.txt
rm -rf build && cmake -S . -B build -DBUILD_QT6=ON -DBUILD_QT5=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)" && sudo cmake --install build
```

## Icons, Cursors, Fonts, and Wallpapers

```bash
# Icons
mkdir -p ~/.local/share/icons
unzip -o plasma6macos-icons.zip -d ~/.local/share/icons

# Cursors
mkdir -p ~/.icons
unzip -o plasma6macos-cursors.zip -d ~/.icons

# Fonts
unzip -o plasma6macos-fonts.zip -d ~/.local/share

# Wallpapers
sudo unzip -o plasma6macos-wallpapers.zip -d /usr/share/wallpapers
```

## Widgets (Plasmoids) & KWin Effects

```bash
# Widgets
unzip -o plasma6macos-plasmoids.zip -d ~/.local/share/plasma

# KWin effects
unzip -o plasma6macos-kwin-effect.zip -d ~/.local/share
```

If you see this error:
`module "org.kde.plasma.private.quicklaunch" is not installed`

```bash
sudo apt install -y plasma-widgets-addons
kquitapp6 plasmashell && kstart plasmashell &
```

## SDDM Login Theme

```bash
sudo unzip -o plasma6macos-sddm.zip -d /
ls /usr/share/sddm/themes
```

## Plymouth Boot Screen

```bash
sudo apt install -y plymouth plymouth-themes plymouth-x11
sudo unzip -o plasma6macos-plymouth-config.zip -d /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R macos
```

## Albert Launcher

```bash
cd ~/Downloads
wget https://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/amd64/albert_0.27.8-0+701.2_amd64.deb
sudo apt install ./albert_0.27.8-0+701.2_amd64.deb
```

Configure:

```bash
unzip -o plasma6macos-albertlauncher-config.zip -d ~/
sudo unzip -o plasma6macos-albertlauncher-theme.zip -d /
```

## Zsh + Oh-My-Zsh + Starship

```bash
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" <<'EOF'
Y
EOF

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search

curl -sS https://starship.rs/install.sh | sh

unzip -o plasma6macos-zshstarship-konsole.zip -d ~/
```

## Apply Global KDE Config

```bash
kquitapp6 plasmashell
unzip -o plasma6macos-kde-config.zip -d ~/
unzip -o plasma6macos-kde-config-manjaro.zip -d ~/
kstart plasmashell &
```

## Restart or Logout

If `qdbus6-qt6` fails:

```bash
sudo apt install -y qdbus-qt6 qt6-base-dev-tools
/usr/lib/qt6/bin/qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
```

or simply restart:

```bash
kquitapp6 plasmashell && kstart plasmashell &
sudo reboot
```

## Troubleshooting

| Problem                                                   | Fix                                                                                                           |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `module org.kde.plasma.private.quicklaunch not installed` | `sudo apt install -y plasma-widgets-addons` then `kquitapp6 plasmashell && kstart plasmashell &`              |
| Darkly build fails with KirigamiPlatform                  | Run `sed -i 's/KF6::KirigamiPlatform[ ]*//g' kstyle*/CMakeLists.txt` and rebuild                              |
| `qdbus` not found                                         | `sudo apt install -y qdbus-qt6 qt6-base-dev-tools`                                                            |
| Widgets cover other apps (un-clickable)                   | Open *System Settings → Window Management → KWin Scripts* and disable aggressive overlays                     |
| Incorrect paths (`~/Donwloads` typo)                      | Use `~/Downloads`                                                                                             |
| Boot screen not changing                                  | Ensure folder `/usr/share/plymouth/themes/macos/` exists and rerun `sudo plymouth-set-default-theme -R macos` |


**Author:** [misuminitt](https://github.com/misuminitt)
