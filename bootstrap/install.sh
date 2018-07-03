#!/bin/sh

###
# Command Central client tools install script
###

if [ -z $CC_INSTALLER ]; then
  # latest public GA version
  CC_VERSION=${CC_VERSION:-10.2-fix2}
  case "`uname`" in
    Darwin) CC_INSTALLER=cc-def-$CC_VERSION-osx.sh ;;
     Linux) CC_INSTALLER=cc-def-$CC_VERSION-lnxamd64.sh ;;
         *) echo "Not supported OS" && exit 1 ;;
  esac
fi

# default public download site
URL=${CC_INSTALLER_URL:-http://empowersdc.softwareag.com/ccinstallers}

# default installation dir
export CC_HOME="$HOME/.sag/tools"
export CC_CLI_HOME="$CC_HOME/CommandCentral/client"
export ANTCC_HOME="`dirname $0`/.."

mkdir -p "$HOME/Downloads"
file="$HOME/Downloads/$CC_INSTALLER"

if [ -f "$file" ]; then
  echo "Found $file"
else
  echo "Downloading ${URL}/${CC_INSTALLER} ..."
  curl -o "$file" "${URL}/${CC_INSTALLER}"
  chmod +x $file
fi

echo "Installing ..."
$file -D CLI -d "$CC_HOME"

echo "Update your environment:"

echo "export CC_CLI_HOME=${CC_CLI_HOME}"
echo "export ANTCC_HOME=${ANTCC_HOME}"
echo "export PATH=\$PATH:\$CC_CLI_HOME/bin:\$ANTCC_HOME/bin"

echo "Verify by running 'antcc help'"

#echo "ln -s ${CC_CLI_HOME}/bin/sagcc /usr/local/bin/"
#echo "ln -s ${ANTCC_HOME}/bin/antcc  /usr/local/bin/"
