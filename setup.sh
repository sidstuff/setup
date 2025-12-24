[ "$(id -u)" -ne 0 ] && printf "Script needs to be run as root.\nExiting...\n" >&2 && exit 1
echo "en_US.UTF-8 UTF-8" >| /etc/locale.gen && locale-gen
printf 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' >| /etc/default/locale

exit1() {
  printf "Script currently only supports Debian >= 13 and Ubuntu >= 24.04\nExiting...\n" >&2
  exit 1
}
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y
. /etc/os-release

case "$ID" in
  ubuntu)
    case "$(printf %.0f $VERSION_ID)" in
      24) snap install neovim --classic ; add-apt-repository ppa:zhangsongcui3371/fastfetch ;;
      25) snap install neovim --classic ;;
      26) apt install -y --no-install-recommends neovim ;;
       *) exit1 ;;
    esac
    add-apt-repository ppa:mozillateam/ppa
    timedatectl set-timezone "$(curl -fsSL https://ipapi.co/timezone)"
    ;;
  debian)
    case "$VERSION_CODENAME" in
      trixie)    apt install -y --no-install-recommends snapd ; snap install neovim --classic ;;
      forky|sid) apt install -y --no-install-recommends neovim ;;
      *)         exit1 ;;
    esac
    apt install -y --no-install-recommends curl || \
    apt install -y --no-install-recommends -t trixie-backports curl # https://github.com/r0b0/debian-installer/issues/103
    apt install -y --no-install-recommends sudo git gawk tmux
    ;;
  *)
    exit1
    ;;
esac
apt install -y meson
apt install -y --no-install-recommends libudev-dev libxkbcommon-dev libpango1.0-dev pkgconf check unzip chafa fastfetch fbgrab pulseaudio mpd ncmpcpp bear
sed -i '/^load-module module-suspend-on-idle/s/^/#/' /etc/pulse/default.pa

# https://github.com/browsh-org/browsh/blob/master/Dockerfile
apt install -y --mark-auto --no-install-recommends curl ca-certificates git autoconf automake g++ protobuf-compiler zlib1g-dev libncurses-dev libssl-dev pkgconf libprotobuf-dev make bzip2
curl -fLO https://github.com/browsh-org/browsh/archive/vim-mode-2022.zip
unzip vim-mode-2022.zip && cd browsh-vim-mode-2022
sed -i 's/^browsh_supporter.*/browsh_supporter = "I have shown my support for Browsh"/' interfacer/src/browsh/config_sample.go
export GOROOT=/go
export GOPATH=/go-home
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
export BASE=$GOPATH/src/browsh/interfacer
curl -fL https://github.com/browsh-org/browsh/releases/download/v1.8.3/browsh-1.8.3.xpi --create-dirs -o $BASE/src/browsh/browsh.xpi
cp -r interfacer/. $BASE
./ctl.sh install_golang $BASE
./ctl.sh build_browsh_binary $BASE
mv $BASE/browsh /usr/local/bin
apt install -y --no-install-recommends xvfb libgtk-3-0 curl ca-certificates libdbus-glib-1-2 procps libasound2t64 libxtst6 firefox-esr
apt autopurge -y
TERM=xterm script --return -c "browsh" /dev/null >/dev/null &
cd ..
rm -rf vim-mode-2022.zip browsh-vim-mode-2022 $GOPATH $GOROOT

git clone --single-branch -b main https://github.com/kmscon/libtsm && cd libtsm
meson setup build/
meson install -C build/
cd ..

git clone --single-branch -b main https://github.com/kmscon/kmscon && cd kmscon
meson setup build/
meson install -C build/
cd ..

ldconfig
systemctl disable getty@tty1.service
systemctl enable kmsconvt@tty1.service

sed -i 's/^#\?font-name=.*/font-name=JetBrainsMono Nerd Font/' /usr/local/etc/kmscon/kmscon.conf
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
usermod -aG sudo,video $USR

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
