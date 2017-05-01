cd ~
git clone "ssh://git@github.com/chris-ca/dotfiles" .dotfiles
rm ~/.bashrc ~/.profile
git clone "ssh://git@github.com/chris-ca/vim" .vim
ln -sd ~/.vim/.vimrc
cd ~/.vim
git submodule init
git submodule update
