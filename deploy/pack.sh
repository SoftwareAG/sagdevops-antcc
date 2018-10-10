#!/bin/bash
###############################################################################
#  Copyright 2013 - 2018 Software AG, Darmstadt, Germany and/or its licensors
#
#   SPDX-License-Identifier: Apache-2.0
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.                                                            
#
###############################################################################
# Execute only on linux and skip osx
if [ `uname` = "Linux" ]
then
        pwd
	cd $HOME
	#setting default values
	CC_VERSION=${CC_VERSION:-10.3-stable}
	CC_DISTRO=${CC_DISTRO:-antcc-nojava}
	# set distribution filename
	CC_DISTRO_FILENAME="$CC_DISTRO-$CC_VERSION-any.zip"
#	CC_DISTRO_FILENAME="antcc-nojava-10.3-stable-any.zip"

	echo "zipping built project to  $HOME/$CC_DISTRO_FILENAME"
	zip -r $HOME/$CC_DISTRO_FILENAME ./.sag/tools/CommandCentral ./.sag/tools/common ./.sag/tools/sagdevops-antcc
fi
