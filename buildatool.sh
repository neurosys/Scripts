curl http://download.savannah.gnu.org/releases/atool/atool-0.39.0.tar.gz
tar xzf atool-0.39.0.tar.gz
cd atool-0.39.0
./configure --prefix=$HOME/.local/stow/atool --exec-prefix=$HOME/.local/stow/atool
make
make install
cd $HOME/.local/stow
stow --no-folding atool
