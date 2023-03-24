#this installs lua 5.4 + pallene
#this is adapted from default pallene install instructions https://github.com/pallene-lang/pallene
#pallene docs at https://github.com/pallene-lang/pallene/blob/master/doc/manual.md
#apt install build-essential wget unzip

rm -r lua lua-internals luarocks* pallene bin -f

git clone https://www.github.com/pallene-lang/lua-internals/
cd lua-internals
make guess -j4
make install

mv src ../lua
cd ../lua
mkdir bin include include/lua54 lib
mv *.h ./include/lua54/
mv *.c ./include/lua54/
mv *.hpp ./include/lua54/
mv *.cpp ./include/lua54/
mv *.o ./lib/
mv *.a ./lib/
mv *.awk ./lib/
mv lua ./bin/
mv luac ./bin/
cd ..

mkdir luarocks
wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz
tar xf luarocks-3.9.1.tar.gz
cd luarocks-3.9.1
./configure --prefix=../luarocks/ --with-lua=../lua
make
make install
cd ..
git clone https://github.com/pallene-lang/pallene/
mv pallene pallene
cd pallene
../luarocks/bin/luarocks make pallene-dev-1.rockspec --tree ../lua
cd ..

rm -r luarocks* lua-internals pallene -f