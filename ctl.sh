#!/bin/bash

# /**
# * Docker Hub2 CTL
# * 	@author soulteary
# **/

BUILD_SCRIPT='/bin/scripts/build.sh';
RUN_SCRIPT='/bin/scripts/run.sh';
RELEASE_SCRIPT='/bin/scripts/release.sh';

echo $PWD;

ACTION='';

for ARGV in "$@"
    do
        case $ARGV in
            'build')
                ACTION='BUILD';
            ;;
            'dev')
                ACTION='RUN';
            ;;
            'release')
                ACTION='RELEASE';
            ;;
        esac
done

case $ACTION in
    'BUILD')
		echo "[INFO] Try to build docker image.";
		[ -s "${PWD}${BUILD_SCRIPT}" ] && . "${PWD}${BUILD_SCRIPT}" && exit 0;
        echo "[ERROR] Build docker image from \`${PWD}${BUILD_SCRIPT}\` failed.";
        exit 1;
    ;;
    'RUN')
		echo "[INFO] Try to start dev mode";
		[ -s "${PWD}${RUN_SCRIPT}" ] && . "${PWD}${RUN_SCRIPT}" && exit 0;
        echo "[ERROR] Start Docker Container Failed.";
        exit 1;
    ;;
    'RELEASE')
		echo "[INFO] Try to release website";
		[ -s "${PWD}${RELEASE_SCRIPT}" ] && . "${PWD}${RELEASE_SCRIPT}" && exit 0;
        echo "[ERROR] Start Docker Container Failed.";
        exit 1;
    ;;
    *)
        echo -ne "Usage: \n\t${0} Command MirrorType --argument1 --argument2 ... --argumentN\n\n";
        exit 2;
esac
