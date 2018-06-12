#!/bin/sh

###
# Command Central client tools install script
###

# latest public GA version
CC_VERSION=10.2-fix1

case "`uname`" in
  Darwin) CC_INSTALLER=cc-def-$CC_VERSION-osx.sh ;;
   Linux) CC_INSTALLER=cc-def-$CC_VERSION-lnxamd64.sh ;;
       *) echo "Not supported OS" && exit 1 ;;
esac

# default public download site
URL=${CC_INSTALLER_URL:-http://empowersdc.softwareag.com/ccinstallers}

# default installation dir
export CC_HOME="$HOME/.sag/tools"
export CC_CLI_HOME="$CC_HOME/CommandCentral/client"

mkdir -p "$HOME/Downloads"
file="$HOME/Downloads/$CC_INSTALLER"
echo "Downloading ${URL}/${CC_INSTALLER} ..."
curl -o "$file" "${URL}/${CC_INSTALLER}"
chmod +x $file
echo "Installing ..."
$file -D CLI -L -d "$CC_HOME"
# rm $file

# case "`uname`" in
#     Darwin) ;;
#      Linux) ln --symbolic "${CC_CLI_HOME}/bin/sagcc" /usr/bin/sagcc && ln --symbolic "${CC_CLI_HOME}/bin/sagccant" /usr/bin/sagccant ;;
# esac
