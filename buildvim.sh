
git clone https://github.com/vim/vim.git
cd vim

INSTALL_PATH=$HOME/.local/stow/vim 
./configure --enable-pythoninterp=yes --enable-cscope --enable-multibyte CFLAGS=-O3 --prefix=$INSTALL_PATH --exec-prefix=$INSTALL_PATH --with-features=huge
make
make install
cd $INSTALL_PATH
cd ..
stow --no-folding vim

