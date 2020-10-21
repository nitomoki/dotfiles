wget https://ja.osdn.net/dl/jnethack/jnethack-3.6.6-0.1.diff.gz
wget https://www.nethack.org/download/3.6.6/nethack-366-src.tgz
tar zxvf nethack-366-src.tgz
cd NetHack-NetHack-3.6.6_Released/
zcat ../jnethack-3.6.6-0.1.diff.gz | patch -p1
find ./ -type f | xargs -i nkf -e -Lu --overwrite {};
cd sys/unix
sh setup.sh hints/linux
cd ../../
make all
make install
cd ..
