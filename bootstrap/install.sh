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
export PATH=$PATH:$CC_CLI_HOME/bin:$ANTCC_HOME/bin:$ANT_HOME/bin
_EOF_
  [ "$IS_ANTCC_BUILDER" = "true" ] &&  echo export "JAVA_HOME=${JAVA_HOME:-$CC_CLI_HOME//jvm/jvm/}" >> $1
else
  echo "Skipping $1"
fi
}
function getUrlDate
{

        LAST_MODIFIED_HEADER=`curl -sIL $1 | grep 'Last-Modified'`
        if [ -z "$LAST_MODIFIED_HEADER" ]
        then
                date +%s
        else
                date -d "`echo $LAST_MODIFIED_HEADER| cut -f2- -d:`" +%s
        fi
}

function getFileDate
{
        if [ -f $1 ]
        then
                date -r $1 +%s
        else
                echo 0
        fi
}
function installBuilder
{
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
}
function installFromZip
{
  echo "Installing CCE CLI"
  pushd `pwd`
  cd $HOME
  unzip -o  $file
  if [ $? -ne 0 ]
  then
    popd
    echo "Something went wrong with zip file:"
    echo "$file"
    echo "Try to remove it manually and rerun the command"
    die "Faild to unzip antcc" 4
  fi
  popd 
}
# latest public GA version
CC_VERSION=${CC_VERSION:-10.3-stable}
CC_DISTRO=${CC_DISTRO:-antcc-nojava}


if [ "$IS_ANTCC_BUILDER" = "true" ]
then
  if [ -z $CC_INSTALLER ]; then
    case "`uname`" in
      Darwin) CC_INSTALLER=$CC_DISTRO-$CC_VERSION-osx.sh ;;
       Linux) CC_INSTALLER=$CC_DISTRO-$CC_VERSION-lnxamd64.sh ;;
           *) die "Not supported OS" && exit 4 ;;
    esac
  fi
else
 CC_INSTALLER=$CC_DISTRO-$CC_VERSION-any.zip
fi


# default public download site used for builder
#URL=${CC_INSTALLER_URL:-http://empowersdc.softwareag.com/ccinstallers}
# default public download site used for antcc installation
URL=${CC_INSTALLER_URL:-https://github.com/SoftwareAG/sagdevops-antcc/releases/download/v10.3-rc13}

# default installation dir
export ANTCC_URL=https://github.com/SoftwareAG/sagdevops-antcc.git
export CC_HOME="$HOME/.sag/tools"
export CC_CLI_HOME="$CC_HOME/CommandCentral/client"
export ANTCC_HOME=$CC_HOME/sagdevops-antcc

export ANT_HOME=$CC_HOME/common/lib/ant
export JAVA_HOME=$CC_HOME/jvm/jvm/



mkdir -p "$HOME/Downloads"
file="$HOME/Downloads/$CC_INSTALLER"

LAST_MODIFIED_URL_DATE=`getUrlDate ${URL}/${CC_INSTALLER}`
LAST_MODIFIED_FILE_DATE=`getFileDate $file`

if [ $LAST_MODIFIED_FILE_DATE -ge $LAST_MODIFIED_URL_DATE  ]; then
  echo "Found newer file $file locally, skipping download"

  EXIT_CODE=0
  HTTP_CODE=200
else
  echo "Downloading ${URL}/${CC_INSTALLER} ..."
  HTTP_CODE=`curl -o "$file" -w "%{http_code}" --remote-time -L "${URL}/${CC_INSTALLER}"`
  EXIT_CODE=$?
fi
if [ "$EXIT_CODE" -eq 0  -a  "$HTTP_CODE" -eq 200 ]
then
  if [ "$IS_ANTCC_BUILDER" = "true" ]
  then
    # build the installer
    echo "Creating builder"
    installBuilder
  else
    # install from zip
    echo "Installing from zip"
    installFromZip
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
  [ "$IS_ANTCC_BUILDER" = "true" ] &&  echo export JAVA_HOME=${JAVA_HOME:-$CC_CLI_HOME//jvm/jvm/}
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
