
git clone https://github.com/vim/vim.git
cd vim
./configure --enable-pythoninterp=yes --enable-cscope --enable-multibyte CFLAGS=-O3 --prefix=/home/camza/.local/stow/vim --exec-prefix=/home/camza/.local/stow/vim --with-features=huge
make
make install
