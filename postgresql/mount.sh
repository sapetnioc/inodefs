db_port=5555
db_user=user
db_password=password
db_name=db

db_dir=`realpath "$1"`
mountpoint=`realpath "$2"`

if [ ! -e "$mountpoint" ]; then
    mkdir "$mountpoint"
fi
env PASSFILE="$db_dir/secret" pgfuse "user=$db_user dbname=$db_name host=localhost port=$db_port" "$mountpoint"
