sed -i '$ d' ~/.profile

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
sed -i 's/^OSH_THEME.*/OSH_THEME="powerline"/' ~/.bashrc

git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/tmux
cat > ~/.config/tmux/tmux.conf << 'EOF'
set -as terminal-overrides ",*:Tc"

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin '2kabhishek/tmux2k'
set -g @tmux2k-theme 'catppuccin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

git clone https://github.com/NvChad/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git
echo 'require("nvchad.configs.lspconfig").defaults()' >| ~/.config/nvim/lua/configs/lspconfig.lua
curl --output-dir ~/.config/nvim/lua/plugins/ \
     -fLO https://raw.githubusercontent.com/sidstuff/setup/master/custom.lua
curl --output-dir ~/.config/nvim/lua/configs/ \
     -fLO https://raw.githubusercontent.com/jyf111/neovim-config/master/lua/configs/scrollview.lua

echo "if [ \"\$(cat /sys/class/tty/tty0/active)\" = tty1 ]; then
  if [ \"\$TMUX\" ]; then
    nvim +terminal
  else
    tmux a || exec tmux && exit
  fi
fi
$(cat ~/.profile)" >| ~/.profile

curl --create-dirs --output-dir ~/.config/fastfetch \
     -fLO https://raw.githubusercontent.com/sidstuff/setup/master/config.jsonc
source /etc/os-release
curl -fsSL https://raw.githubusercontent.com/sidstuff/setup/master/$ID.png | chafa -s 30x30 > ~/.config/fastfetch/logo.txt
echo "fastfetch" >> ~/.bashrc

git clone --single-branch -b vim-mode https://github.com/jooaf/browsh
sed -i -e '6s/.*/browsh_supporter = "I have shown my support for Browsh"/' browsh/interfacer/src/browsh/config_sample.go
docker build -t browsh-vim browsh
echo "alias browsh='docker run --rm -w ~/browsh -ti browsh-vim'" >> ~/.bash_aliases

mkdir -p ~/music/playlists
curl --create-dirs --output-dir ~/.config/mpd \
     -fLO https://raw.githubusercontent.com/sidstuff/setup/master/mpd.conf
systemctl --user enable --now mpd.socket
curl --create-dirs --output-dir ~/.config/ncmpcpp \
     -fLO https://raw.githubusercontent.com/sidstuff/setup/master/config

tmux new-session '/snap/bin/nvim + <(echo "Almost done! Press Ctrl-b followed by (an uppercase) I, \
then run :MasonInstallAll and :TSInstall all, then finally open the theme selector \
by sequentially pressing <space>th and select the catpuccin theme. \
When editing code, you can run :LspInstall to install the relevant LSP. \
Once these steps have been completed, reboot into your newly setup system.")'
