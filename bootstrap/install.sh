#!/bin/bash

###
# Command Central client tools install script
###
function die
{
  echo "Failed with: $1, exittingi with $2"
  exit $2
}

function addEnvVars
{
cat >> $1 << _EOF_
export CC_CLI_HOME=${CC_CLI_HOME}
export ANTCC_HOME=${CC_CLI_HOME}
export PATH=$PATH:$CC_CLI_HOME/bin:$ANTCC_HOME/bin
_EOF_
}
if [ -z $CC_INSTALLER ]; then
  # latest public GA version
  CC_VERSION=${CC_VERSION:-10.2-fix1}
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

mkdir -p "$HOME/Downloads"
file="$HOME/Downloads/$CC_INSTALLER"

if [ -f "$file" ]; then
  echo "Found $file"
  EXIT_CODE=0
  HTTP_CODE=200
else
  echo "Downloading ${URL}/${CC_INSTALLER} ..."
  HTTP_CODE=`curl -o "$file" -w "%{http_code}"  "${URL}/${CC_INSTALLER}"`
  EXIT_CODE=$?
fi
if [ "$EXIT_CODE" -eq 0  -a  "$HTTP_CODE" -eq 200 ]
then
  echo "Installing ..."
  chmod +x $file
  $file -D CLI -L -d "$CC_HOME"
  if [ $? -ne 0 ]
    then
    echo "Something went wrong with executable file:"
    echo "$file"
    echo "Try to remove it manually and rerun the command"
    die "file not executable" 2
  fi
  echo $?
else
  if [ -f "$file" ]
  then
    rm -f "$file"
  fi
  die "Download failed with http code: $HTTP_CODE, curl exit code: $EXIT_CODE" 1
fi
echo "Trying to add  vatiables to $HOME/.bash_profile and $HOME/.profile if exist"
if [ -f "$HOME/.bash_profile" ]
then
  echo .bash_profile
  addEnvVars  "$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]
then
  echo .profile
  addEnvVars  "$HOME/.profile"
else
  echo "It was not possible to add the environment variables to shell profile."
fi
echo "Please run the following commands manually"
echo
echo "export CC_CLI_HOME=${CC_CLI_HOME}"
echo "export ANTCC_HOME=${CC_CLI_HOME}"
echo "export PATH=$PATH:$CC_CLI_HOME/bin"

echo "Verify by running 'antcc'"
