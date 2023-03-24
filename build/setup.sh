#this installs lua 5.4 + luarocks + pallene
#this is adapted from default pallene install instructions https://github.com/pallene-lang/pallene
#pallene docs at https://github.com/pallene-lang/pallene/blob/master/doc/manual.md
#pallene can use lua functions as well
#be sure to have wget build-essential and unzip

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
cd luarocks/bin/
cd ../..
./luarocks/bin/luarocks config local_by_default true

git clone https://github.com/pallene-lang/pallene/
cd pallene
../luarocks/bin/luarocks make pallene-dev-1.rockspec --local
cd ..
rm -r luarocks-3.9.1 lua-internals *.tar.gz -f

mkdir bin
ln -rs luarocks/bin/* ./bin/
ln -rs lua/bin/* ./bin/
ls -rs pallene/bin/* ./bin/