if [ "$(id -u)" -ne 0 ]; then
  echo -e "Script needs to be run as root.\nExiting..." >&2
  exit 1
fi
apt update && apt upgrade
snap refresh

cd /root/libtsm
if [ "$(git pull origin)" != "Already up to date." ]; then
  meson setup build/
  meson install -C build/
fi
cd /root/kmscon
if [ "$(git pull origin)" != "Already up to date." ]; then
  meson setup -Dbackspace_sends_delete=true build/
  meson install -C build/
fi
ldconfig

cd /usr/share/fonts
JB_VER=$(curl -si https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip | grep -oP 'location: https://github.com/ryanoasis/nerd-fonts/releases/download/v\K.*(?=/JetBrainsMono.zip)')
if [ ! -d "JetBrainsMono$JB_VER" ]; then
  rm -rf JetBrainsMono*
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip JetBrainsMono.zip -d JetBrainsMono$JB_VER && rm JetBrainsMono.zip
  fc-cache -fv
fi

if [ -n "$1" ] && [ -d "/home/$1" ]; then
  USR="$1"
elif [ -z "$1" ] && [ -n "$(ls /home)" ]; then
  USR="$(ls /home | head -1)"
else
  echo -e "User not found in /home\nExiting..." >&2
  exit 1
fi
su -c "bash ~/.local/share/blesh/ble.sh --update && rustup update" - $USR
clear
echo "Almost done! To update your plugins, in bash run upgrade_oh_my_bash, in tmux press Ctrl-b followed by (an uppercase) U, and in neovim run :Lazy sync"
