#!/bin/bash

# OVN_gateway_deploy.sh v.01 written by bencab (tested with Debian BUSTER/10 only)
#
# Arguments check looks only for an no empty entry, not the format/type of the entry. If you put a bad IP/Key, it's your problem.
# 
# This is a really basic and simple (and crappy) script POC, for Install/Reinstall/Upgrade OVN Gateway (and mongo).
# Distributed under the GPL License, use it at your own risk.
#
# Dependecies: Docker installed 
#

SCRIPTNAME=$(basename $0)
DOCKERBIN=$(which docker)
ARGSFILE="config"
PUBLICIP=""
BPIKEY=""

if [ ! $(id -u) -eq "0" ]
then
	echo "This script must be executed by root user" && exit 1
fi

function GenErrorClean {
			if [ ! $? -eq 0 ]
				then
					echo -e "Something went wrong, exiting script\n" && exit 1
				else	
					echo -e "Done\n\n"
			fi
}

function GenCheckCreaOvlNet {
			if [ ! $? -eq 0 ]
			then
				echo -e "Problem creating the network\n" && exit 1
			else
				echo -e "Network Created succesfully\n"
			fi
}

function GenCheckCreaMonCon {
			if [ ! $? -eq 0 ]
			then
				echo -e "Problem creating OVL-MONGO container\n" && exit 1
			else
				echo -e "OVL-MONGO container created succesfully\n"
			fi
}

function GenCheckCreaGatCon {
			if [ ! $? -eq 0 ]
			then
				echo -e "Problem creating OVN GATEWAY container\n" && exit 1
			else
				echo -e "OVN GATEWAY container created succesfully\n"
			fi
}

#CHECK ARGS
if [ $# -lt 1 ]
then
	echo -e "\n**Arguments not filled**"
	echo -e "\nUsage:\n\n./$SCRIPTNAME install\n\nOR\n\n./$SCRIPTNAME reinstall\n\nOR\n\n./$SCRIPTNAME upgrade\n" && exit 1
fi

case "$1" in

	install)
		echo -e "Installing:\n"
		echo "Please provide your Public IP:"
		read PUBLICIP
			if [ -z $PUBLICIP ]
			then
				echo "Your PUBLIC IP seems wrong" && exit 1
			fi
		echo "PUBLICIP=$PUBLICIP" > $ARGSFILE
		echo -e "Your IP is: $PUBLICIP\n"
		echo "Your BPKEY:"
		read BPIKEY
			if [ -z $BPIKEY ]
			then
				echo "Your BPIKEY seems wrong" && exit 1
			fi
		echo -e "Your BPIKEY is: $BPIKEY\n" && sleep 3
		echo "BPIKEY=$BPIKEY" >> $ARGSFILE
		echo -e "\nCreating docker network:\n"
		CHECKDOCKERNETWORK=$(docker network ls --filter name=ovl-net | grep bridge)
			if [ -n "$CHECKDOCKERNETWORK" ]
			then
				echo -e "Network seems already created, maybe you want to reinstall? exiting script\n" && exit 1
			fi
		$DOCKERBIN network create "ovl-net" > /dev/null 2>&1
			GenCheckCreaOvlNet
		echo -e "\nCreating the OVL MONGO container:\n"
		$DOCKERBIN run -d --name "ovl-mongo" --network "ovl-net" -p "27017:27017" "mongo:latest" > /dev/null 2>&1
			GenCheckCreaMonCon
		echo -e "\nCreating the OVN Gateway container:\n"
		$DOCKERBIN run -dit --name "overledger-network-gateway" --network "ovl-net" -p "8080:8080" -p "11337:11337" -e GATEWAY_ID="$BPIKEY" -e GATEWAY_HOST="$PUBLICIP" -e MONGO_DB_HOST="ovl-mongo" "quantnetwork/overledger-network-gateway:latest" >/dev/null 2>&1
			GenCheckCreaGatCon

		;;

	reinstall)
		# CLEAN ALL PREVIOUS CONFIGURATION (network / containers)
		# Network remove
		echo -e "Reinstalling:\n"
		echo "Please provide your Public IP:"
		read PUBLICIP
			if [ -z $PUBLICIP ]
			then
				echo "Your PUBLIC IP seems wrong" && exit 1
			fi
		echo "PUBLICIP=$PUBLICIP" > $ARGSFILE
		echo -e "Your IP is: $PUBLICIP\n"
		echo "Your BPKEY:"
		read BPIKEY
			if [ -z $BPIKEY ]
			then
				echo "Your BPIKEY seems wrong" && exit 1
			fi
		echo -e "Your BPIKEY is: $BPIKEY\n" && sleep 3
		echo "BPIKEY=$BPIKEY" >> $ARGSFILE
		# CLEAN ALL PREVIOUS DOCKER CONTAINERS 
		echo -e "Stopping containers:\n"
		$DOCKERBIN stop "ovl-mongo" > /dev/null 2>&1 && $DOCKERBIN stop "overledger-network-gateway" > /dev/null 2>&1
			GenErrorClean
		echo -e "Removing docker containers and network:\n"
		$DOCKERBIN network rm "ovl-net" > /dev/null 2>&1 && $DOCKERBIN container rm "ovl-mongo" > /dev/null 2>&1 && $DOCKERBIN container rm "overledger-network-gateway" > /dev/null 2>&1
			GenErrorClean
		echo -e "Creationg the OVL Network:\n"
		$DOCKERBIN network create "ovl-net" > /dev/null 2>&1
			GenCheckCreaOvlNet
		echo -e "Creating the OVL MONGO container:\n"
		$DOCKERBIN run -d --name "ovl-mongo" --network "ovl-net" -p "27017:27017" "mongo:latest" > /dev/null 2>&1
			GenCheckCreaMonCon
		echo -e "Creating the OVN Gateway container"
		$DOCKERBIN run -dit --name "overledger-network-gateway" --network "ovl-net" -p "8080:8080" -p "11337:11337" -e GATEWAY_ID="$BPIKEY" -e GATEWAY_HOST="$PUBLICIP" -e MONGO_DB_HOST="ovl-mongo" "quantnetwork/overledger-network-gateway:latest" > /dev/null 2>&1
			GenCheckCreaGatCon
		;;

	upgrade) 
		echo "Upgrading:"
			if [ ! -e ./$ARGSFILE ]
			then
				echo "File \"config\" not found, exiting" && exit 1
			fi
		SAVEIP=$(grep PUBLICIP config | cut -d= -f2)
		SAVEKEY=$(grep BPIKEY config | cut -d= -f2)
		$DOCKERBIN stop "overledger-network-gateway" > /dev/null 2>&1
		$DOCKERBIN container rm "overledger-network-gateway" > /dev/null 2>&1
		$DOCKERBIN rmi "overledger-network-gateway" > /dev/null 2>&1
		$DOCKERBIN pull "quantnetwork/overledger-network-gateway:latest"
		$DOCKERBIN run -dit --name "overledger-network-gateway" --network "ovl-net" -p "8080:8080" -p "11337:11337" -e GATEWAY_ID="$SAVEKEY" -e GATEWAY_HOST="$SAVEIP" -e MONGO_DB_HOST="ovl-mongo" "quantnetwork/overledger-network-gateway:latest"

		;;

	cleanall)
		echo -e "\nStopping containers:\n"
		$DOCKERBIN stop "ovl-mongo"
		$DOCKERBIN stop "overledger-network-gateway" 
		echo -e "\nRemoving containers:\n"
		$DOCKERBIN container rm "ovl-mongo"
	       	$DOCKERBIN container rm "overledger-network-gateway"
		echo -e "\nRemoving OVN network:\n"
		$DOCKERBIN network rm "ovl-net" 
		;;

	*) echo "invalid option"
		;;
esac

exit
