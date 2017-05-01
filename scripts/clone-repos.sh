cd ~

# get dotfiles 
git clone "https://github.com/chris-ca/dotfiles" .dotfiles
rm ~/.bashrc ~/.profile
~/.dotfiles/install.sh

# get vim and install submodules
git clone "https://github.com/chris-ca/vim" .vim
rm ~/.vimrc
ln -sd ~/.vim/.vimrc
cd ~/.vim
git submodule init
git submodule update
