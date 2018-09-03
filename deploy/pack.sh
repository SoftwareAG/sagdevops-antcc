#!/bin/bash -x
# Execute only on linux and skip osx
if [ `uname` = "Linux" ]
then
	cd $HOME
	#setting default values
#	CC_VERSION=${CC_VERSION:-10.3-stable}
#	CC_DISTRO=${CC_DISTRO:-antcc-nojava}
	# set distribution filename
#	CC_DISTRO_FILENAME="$CC_DISTRO-$CC_VERSION-any.zip"
	CC_DISTRO_FILENAME="antcc-nojava-10.3-stable-any.zip"
#	echo "Currently in folder `pwd`"
#	echo "Environment variables values:"
#	env
#	echo
	echo "zipping built project to  $CC_DISTRO_FILENAME"
	zip -r $HOME/$CC_DISTRO_FILENAME ./.sag/tools/CommandCentral ./.sag/tools/common ./.sag/tools/sagdevops-antcc
fi
