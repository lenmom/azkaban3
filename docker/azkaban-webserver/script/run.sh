#!/bin/bash


## Run azkaban exec server ####################################

START_CMD="bin/azkaban-web-start.sh"
AZK_PROPERTIES="conf/azkaban.properties"

change_properties() {
    local file=$1
    local key_name=$2
    local value=$3
    if [ ! -z "$value" ]; then
        echo "change : $key_name=$value ($file)"
        eval "sed -i -e '/$key_name=/s/=.*/=$value/' $file"
    fi
}

## parse args 
optspec=":-:"
while getopts "$optspec" o; do
	case "${o}" in
		-)
			case "${OPTARG}" in
				azkaban.name=*)
					AZK_NAME=${OPTARG#*=}
					;;
				azkaban.label=*)
					AZK_LABEL=${OPTARG#*=}
					;;
				azkaban.color=*)
					AZK_COLOR=${OPTARG#*=}
					;;
				mysql.host=*)
					MYSQL_HOST=${OPTARG#*=}
					;;
				mysql.port=*)
					MYSQL_PORT=${OPTARG#*=}
					;;
				mysql.user=*)
					MYSQL_USER=${OPTARG#*=}
					;;
				mysql.password=*)
					MYSQL_PASSWORD=${OPTARG#*=}
					;;
				mysql.database=*)
					MYSQL_DATABASE=${OPTARG#*=}
					;;
				*)
					if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
						echo "Unknown option --${OPTARG}" >&2
					fi
					;;
			esac
			;;
		*)
			if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
				echo "Non-option argument: '-${OPTARG}'" >&2
			fi
			;;
	esac
done


if [ ! -z "$AZK_NAME" ]; then
	change_properties $AZK_PROPERTIES 'azkaban.name' $AZK_NAME
fi
if [ ! -z "$AZK_LABEL" ]; then
	change_properties $AZK_PROPERTIES 'azkaban.label' $AZK_LABEL
fi
if [ ! -z "$AZK_COLOR" ]; then
	change_properties $AZK_PROPERTIES 'azkaban.color' $AZK_COLOR
fi
if [ ! -z "$MYSQL_HOST" ]; then
	change_properties $AZK_PROPERTIES 'mysql.host' $MYSQL_HOST
fi
if [ ! -z "$MYSQL_PORT" ]; then
	change_properties $AZK_PROPERTIES 'mysql.port' $MYSQL_PORT
fi
if [ ! -z "$MYSQL_USER" ]; then
	change_properties $AZK_PROPERTIES 'mysql.user' $MYSQL_USER
fi
if [ ! -z "$MYSQL_PASSWORD" ]; then
	change_properties $AZK_PROPERTIES 'mysql.password' $MYSQL_PASSWORD
fi
if [ ! -z "$MYSQL_DATABASE" ]; then
	change_properties $AZK_PROPERTIES 'mysql.database' $MYSQL_DATABASE
fi


exec $START_CMD