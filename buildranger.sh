git clone https://github.com/hut/ranger.git
cd ranger 
export DESTDIR=$HOME/.local/stow/ranger
make install
#cd $HOME/.local/stow/ranger/usr/
#stow -t $HOME/.local/ local
