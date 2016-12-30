#!/bin/bash

## Run azkaban exec server ####################################

START_CMD="bin/azkaban-executor-start.sh"
AZK_PROPERTIES="conf/azkaban.properties"
GLOBAL_PROPERTIES="plugins/jobtypes/common.properties"

change_properties() {
    local file=$1
    local key_name=$2
    local value=$3
    if [ ! -z "$value" ]; then
        echo "change : $key_name=$value ($file)"
        cmd=`sed -i -e '/$key_name=/s/=.*/=$value/' $file`
        eval $cmd
	fi
}

append_properties() {
	local file=$1
	local key_name=$2
	local value=$3
    if [ ! -z "$value" ]; then
        echo "append : $key_name=$value ($file)"
        cmd=`$echo $key_name=$value >> $file`
        eval $cmd
	fi

}

change_properties $AZK_PROPERTIES 'mysql.host' $MYSQL_HOST
change_properties $AZK_PROPERTIES 'mysql.port' $MYSQL_PORT
change_properties $AZK_PROPERTIES 'mysql.user' $MYSQL_USER
change_properties $AZK_PROPERTIES 'mysql.password' $MYSQL_PASSWORD
change_properties $AZK_PROPERTIES 'mysql.database' $MYSQL_DB

#generate global properties
for gp in $(env | grep GP_)
do
	gp=${gp:3}
	key=${gp%%\=*}
	value=${gp#*=}
	key=${key,,}
	key=${key/_/.}
	append_properties $GLOBAL_PROPERTIES $key $value
done

exec $START_CMD
