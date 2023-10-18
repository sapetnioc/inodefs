db_port=5555
db_user=user
db_password=password
db_name=db

target=`realpath "$1"`

mkdir "$target"
git  -C "$target" clone git://git.andreasbaumann.cc/pgfuse.git
cd "$target"
cd ..
if [ ! -e Mambaforge-Linux-x86_64.sh ]; then
    wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
fi
sh Mambaforge-Linux-x86_64.sh -b -p "$target/conda"
"$target/conda/bin/mamba" update -y mamba
"$target/conda/bin/mamba" install -y postgresql 'libfuse<3' libpq

activate_script=`"$target/conda/bin/conda" shell.posix activate base`
eval "$activate_script"

set -x

cat > "$target/conda/lib/pkgconfig/fuse.pc" << END
prefix=${target}/conda
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: fuse
Description: Filesystem in Userspace
Version: 2.9.9
Libs: -L\${libdir} -lfuse -pthread
Libs.private: -ldl  
Cflags: -I\${includedir}/fuse -D_FILE_OFFSET_BITS=64
END

echo "CFLAGS += -I$target/conda/include" >> "$target/pgfuse/inc.mak"

cd "$target/pgfuse"
make
make install prefix="$target/conda"

mkdir "$target/database"
initdb --set port=$db_port "$target/database"
pg_ctl -D "$target/database" -l "$target/database/log" start
createuser -p $db_port -S -R -D $db_user
psql -p $db_port -c "ALTER USER $db_user WITH PASSWORD '$db_password';"
createdb -p $db_port -O $db_user $db_name
psql -p $db_port -U $db_user $db_name < "$target/pgfuse/schema.sql"
cat > "$target/secret" << END
localhost:$db_port:$db_name:$db_user:$db_password
END
