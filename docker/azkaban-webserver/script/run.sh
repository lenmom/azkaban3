#!/bin/sh


## Run azkaban exec server ####################################

START_CMD="bin/azkaban-web-start.sh"
AZK_PROPERTIES="conf/azkaban.properties"

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

change_properties $AZK_PROPERTIES 'azkaban.name' $AZK_NAME
change_properties $AZK_PROPERTIES 'azkaban.label' $AZK_LABEL
change_properties $AZK_PROPERTIES 'azkaban.color' $AZK_COLOR

change_properties $AZK_PROPERTIES 'mysql.host' $MYSQL_HOST
change_properties $AZK_PROPERTIES 'mysql.port' $MYSQL_PORT
change_properties $AZK_PROPERTIES 'mysql.user' $MYSQL_USER
change_properties $AZK_PROPERTIES 'mysql.password' $MYSQL_PASSWORD
change_properties $AZK_PROPERTIES 'mysql.database' $MYSQL_DB 

exec $START_CMD