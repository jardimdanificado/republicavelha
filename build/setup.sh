#this is from https://github.com/pallene-lang/pallene
#this installs lua 5.4 + luarocks + pallene

git clone https://www.github.com/pallene-lang/lua-internals/
cd lua-internals
make guess -j4
sudo make install

wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz
tar xf luarocks-3.9.1.tar.gz
cd luarocks-3.9.1
./configure --with-lua=/usr/local
make
sudo make install

luarocks config local_by_default true

eval "$(luarocks path)"

git clone https://github.com/pallene-lang/pallene/
luarocks make pallene-dev-1.rockspec
