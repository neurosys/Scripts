
git clone https://github.com/tmux/tmux.git
cd tmux
INSTALL_PATH=$HOME/.local/stow/tmux
./autogen.sh
./configure --prefix=$INSTALL_PATH --exec-prefix=$INSTALL_PATH CFLAGS=-O3 --enable-static
make
make install
cd $INSTALL_PATH/..
stow --no-folding tmux
