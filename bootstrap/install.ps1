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
function die($text,$code) {
    "Failed with: $text, exitting with $code"
    exit $2
}

function set-unless($name,$value){
	$rv=""
	if ( $name.Length -eq 0 ){
	    $rv=$value
	}else{
	    $rv=$name
	}
"$rv".trim()
}	

function getUrlDate($url){
    try{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $LAST_MODIFIED_HEADER=((Invoke-WebRequest -URI $url -Method Head).headers['Last-modified'])
    } catch {
		(Get-Date)
        return
    }
    if($LAST_MODIFIED_HEADER){
        "$LAST_MODIFIED_HEADER"
    }else{
        (Get-Date)
    }
}

function installFromZip($filename){
    "Installing CCE CLI"
    Expand-Archive -Force -Path $filename -DestinationPath $env:USERPROFILE
    if(!$?){
        "Something went wrong with zip file:"
        "$filename"
        "Try to remove it manually and rerun the command"
        die ("Faild to unzip antcc",4)
    }

}
$ANTCC_VERSION=set-unless $env:ANTCC_VERSION 10.4-stable
$ANTCC_DISTRO=set-unless $env:ANTCC_DISTRO antcc-nojava
$CC_INSTALLER="$ANTCC_DISTRO-$ANTCC_VERSION-any.zip"
$URL=set-unless $env:ANTCC_INSTALLER_URL "https://github.com/SoftwareAG/sagdevops-antcc/releases/download/v10.4"
$CC_HOME="$env:USERPROFILE\.sag\tools"
$CC_CLI_HOME="$CC_HOME\CommandCentral\client"
$ANTCC_HOME="$CC_HOME\sagdevops-antcc"
if(! (test-path "$env:USERPROFILE\Downloads")){
	mkdir "$env:USERPROFILE\Downloads"
}
$file="$env:USERPROFILE\Downloads\$CC_INSTALLER"
$HTTP_CODE=0

$LAST_MODIFIED_URL_DATE=getUrlDate "$URL/$CC_INSTALLER"
if( (test-path $file) -and !(Test-Path $file -OlderThan $LAST_MODIFIED_URL_DATE)){
	"Found newer file $file locally, skipping download"
	$EXIT_CODE=0
	$HTTP_CODE=200
} else {
	"Downloading $URL/$CC_INSTALLER ..."
    $ProgressPreference = 'SilentlyContinue'
	try { 
         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		Invoke-WebRequest $URL/$CC_INSTALLER -OutFile $file
        $HTTP_CODE=200
	} catch {
		$HTTP_CODE=$_.Exception.Response.StatusCode.Value__
	}
    $ProgressPreference = 'Continue'
}
if ( $HTTP_CODE -eq 200 ){
    installFromZip($file)
    "Trying to add  environment variables to current user's profile"
    [Environment]::SetEnvironmentVariable("CC_CLI_HOME",$CC_CLI_HOME,"User")
    [Environment]::SetEnvironmentVariable("CC_CLI_HOME",$CC_CLI_HOME,"Process")
    $ANT_HOME="$CC_HOME\common\lib\ant"
	[Environment]::SetEnvironmentVariable("ANT_HOME","$ANT_HOME","User")
	[Environment]::SetEnvironmentVariable("ANT_HOME","$ANT_HOME","Process")
    # checking if antcc is not in path already
	$ANTCC_CUSTOM_PATH="$CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin"
    $PROCESS_PATH=[Environment]::GetEnvironmentVariable("Path","Process")
	if(! ($PROCESS_PATH.Contains($ANTCC_CUSTOM_PATH))){
        "Adding $ANTCC_CUSTOM_PATH to current shell PATH variable"
		[Environment]::SetEnvironmentVariable("Path","$PROCESS_PATH;$ANTCC_CUSTOM_PATH","Process")
	}
    $USER_PATH=[Environment]::GetEnvironmentVariable("Path","User")
	if(! $USER_PATH ){
		"Setting $ANTCC_CUSTOM_PATH to PATH for all sessions of current user"
		[Environment]::SetEnvironmentVariable("Path","$ANTCC_CUSTOM_PATH","User")
	}elseif(! ($USER_PATH.Contains($ANTCC_CUSTOM_PATH))){
        "Adding $ANTCC_CUSTOM_PATH to PATH for all sessions of current user"
		[Environment]::SetEnvironmentVariable("Path","$USER_PATH;$ANTCC_CUSTOM_PATH","User")
	}
    ""
    "Verify by running 'antcc help'"
    #"Please run the following commands manually, logout and login again or open a new command prompt"
	#"set CC_CLI_HOME=$CC_CLI_HOME"
	#"set ANT_HOME=$CC_HOME\common\lib\ant"
	#"set PATH=$env:PATH;$CC_CLI_HOME\bin:$ANTCC_HOME\bin:$ANT_HOME\bin"
    

}else{
	die "Download failed with http code: $HTTP_CODE" 1
}

