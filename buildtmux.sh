
git clone https://github.com/tmux/tmux.git
cd tmux
./autogen.sh
./configure --prefix=/home/camza/.local/stow/tmux --exec-prefix=/home/camza/.local/stow/tmux CFLAGS=-O3 --enable-static
make
make install
