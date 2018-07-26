#!/bin/bash

###
# Command Central client tools install script
###
function die
{
  echo "Failed with: $1, exiting with $2"
  exit $2
}

function addEnvVars
{
INSTALL_LABEL="#Installed by antcc cli installer"
grep -q "^$INSTALL_LABEL" $1
if [ $? -ne 0 ]
then
  echo "Adding variables to $1"
  echo $INSTALL_LABEL >> $1
  cat >> $1 << _EOF_
export CC_CLI_HOME=$CC_CLI_HOME
export ANTCC_HOME=$ANTCC_HOME
export ANT_HOME=$CC_HOME/common/lib/ant
export JAVA_HOME=${JAVA_HOME:-$CC_CLI_HOME//jvm/jvm/}
export PATH=$PATH:$CC_CLI_HOME/bin:$ANTCC_HOME/bin:$ANT_HOME/bin
_EOF_
else
  echo "Skipping $1"
fi
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
export ANTCC_URL=https://github.com/SoftwareAG/sagdevops-antcc.git
export CC_HOME="$HOME/.sag/tools"
export CC_CLI_HOME="$CC_HOME/CommandCentral/client"
export ANTCC_HOME=$CC_HOME/sagdevops-antcc

export ANT_HOME=$CC_HOME/common/lib/ant
export JAVA_HOME=$CC_HOME/jvm/jvm/



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
  echo "Installing CCE CLI"
  chmod +x $file
  $file -D CLI -L -d "$CC_HOME"
  if [ $? -ne 0 ]
  then
    echo "Something went wrong with executable file:"
    echo "$file"
    echo "Try to remove it manually and rerun the command"
    die "file not executable" 2
  fi
  echo "Cloning antcc repo to $ANTCC_HOME"
  if [ -d "$ANTCC_HOME" ]
  then
    rm -rf $ANTCC_HOME
  fi
  git clone $ANTCC_URL $ANTCC_HOME
  EXIT_CODE=$?
  if [ "$EXIT_CODE" -ne 0 ]
  then
    die "Failed to clone antcc repo" 3
  fi

  echo "Trying to add  vatiables to all shell profiles in $HOME"
  for profile in .profile .bashrc .zshrc .cshrc
  do
    if [ -f "$HOME/$profile" ]
    then
      addEnvVars $HOME/$profile
    fi
  done
  echo "Please run the following commands manually, logout and login again or source your shell profile (.profile, .bash_profile etc)"
  echo
  echo export CC_CLI_HOME=$CC_CLI_HOME
  echo export ANTCC_HOME=$ANTCC_HOME
  echo export ANT_HOME=$CC_HOME/common/lib/ant
  echo export JAVA_HOME=${JAVA_HOME:-$CC_CLI_HOME//jvm/jvm/}
  echo export PATH=$PATH:$CC_CLI_HOME/bin:$ANTCC_HOME/bin:$ANT_HOME/bin
  echo
  echo "Verify by running 'antcc help'"
else
  if [ -f "$file" ]
  then
    rm -f "$file"
  fi
  die "Download failed with http code: $HTTP_CODE, curl exit code: $EXIT_CODE" 1
fi
