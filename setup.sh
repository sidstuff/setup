if [ "$(id -u)" -ne 0 ]; then
  printf "Script needs to be run as root.\nExiting...\n" >&2
  exit 1
fi

echo "en_US.UTF-8 UTF-8" >| /etc/locale.gen && locale-gen
printf 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' >| /etc/default/locale
. /etc/os-release
if [ "$ID" = ubuntu ] && [ "$(printf %.0f $VERSION_ID)" -ge 24 ]; then
  timedatectl set-timezone "$(curl -fsSL https://ipapi.co/timezone)"
  add-apt-repository ppa:zhangsongcui3371/fastfetch
elif [ "$ID" = debian ] && [ "$VERSION_ID" -ge 13 ]; then
  apt install -y snapd sudo git gawk curl tmux
else
  printf "Script currently only supports Debian >= 13 and Ubuntu >= 24.04\nExiting...\n" >&2
  exit 1
fi
apt update && apt upgrade -y
apt install -y libudev-dev libxkbcommon-dev libpango1.0-dev pkgconf check meson unzip chafa fastfetch docker.io fbgrab pulseaudio mpd ncmpcpp bear
sed -i '/^load-module module-suspend-on-idle/s/^/#/' /etc/pulse/default.pa
snap install nvim --classic

git clone --single-branch -b main https://github.com/Aetf/libtsm && cd libtsm
meson setup build/
meson install -C build/
cd ..

git clone --single-branch -b main https://github.com/Aetf/kmscon && cd kmscon
meson setup -Dbackspace_sends_delete=true build/
meson install -C build/
cd ..

ldconfig
systemctl disable getty@tty1.service
systemctl enable kmsconvt@tty1.service

mkdir /usr/local/etc/kmscon
echo "font-name=JetBrainsMono Nerd Font" > /usr/local/etc/kmscon/kmscon.conf
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
JB_VER=$(curl -fsSi https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip | grep -oP 'location: https://github.com/ryanoasis/nerd-fonts/releases/download/v\K.*(?=/JetBrainsMono.zip)')
unzip JetBrainsMono.zip -d /usr/share/fonts/JetBrainsMono$JB_VER && rm JetBrainsMono.zip
fc-cache -fv

if [ "$1" ] && [ -d "/home/$1" ]; then
  USR="$1"
elif [ -z "$1" ] && [ "$(ls /home)" ]; then
  USR="$(ls /home | head -1)"
else
  printf "User not found in /home\nExiting...\n" >&2
  exit 1
fi
groupadd docker
usermod -aG sudo,docker,video $USR

echo "source <(curl -fsSL https://raw.githubusercontent.com/sidstuff/setup/master/home.sh)" >> /home/$USR/.profile
for i in 5 4 3 2 1; do
  clear
  echo "You will be switched to a new KMSCON session in $i seconds.
Login as the user for whom you wish to perform the setup, and the remainder will proceed."
  sleep 1
done

VT="$(fgconsole --next-available)"
systemctl stop getty@tty$VT.service
systemctl start kmsconvt@tty$VT.service
chvt $VT
