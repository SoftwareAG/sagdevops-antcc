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

if ( $env:CC_INSTALLER.Length -eq 0 ) {
	$CC_VERSION=set-unless $env:CC_VERSION "10.2-fix1"
	$CC_INSTALLER="cc-def-$CC_VERSION-w64.exe"
}

$URL=set-unless $env:CC_INSTALLER_URL "http://empowersdc.softwareag.com/ccinstallers"
$ANTCC_URL="https://github.com/SoftwareAG/sagdevops-antcc.git"
$CC_HOME="$env:USERPROFILE\.sag\tools"
$CC_CLI_HOME="$CC_HOME\CommandCentral\client"
$ANTCC_HOME="$CC_HOME\sagdevops-antcc"
if(! (test-path "$env:USERPROFILE\Downloads")){
	mkdir "$env:USERPROFILE\Downloads"
}
$file="$env:USERPROFILE\Downloads\$CC_INSTALLER"
$HTTP_CODE=0
if(test-path $file){
	"Found local copy of $file"
	"Download skipped"
	$EXIT_CODE=0
	$HTTP_CODE=200
} else {
	"Downloading $URL/$CC_INSTALLER ..."
    $ProgressPreference = 'SilentlyContinue'
	try { 
		Invoke-WebRequest $URL/$CC_INSTALLER -OutFile $file
        $HTTP_CODE=200
	} catch {
		$HTTP_CODE=$_.Exception.Response.StatusCode.Value__
	}
    $ProgressPreference = 'Continue'
}
if ( $HTTP_CODE -eq 200 ){
	"Installing CCE CLI"
	$LASTEXITCODE=0
	try{
		Start-Process -Wait -FilePath "$file" -ArgumentList "-D","CLI","-L", "-d","$CC_HOME"
	}catch{
		$LASTEXITCODE=1
	}
	if ( $LASTEXITCODE -ne 0 ){
		"Something went wrong with executable file:"
		$file
		"Try to remove it manually and rerun the command"
		die("file not executable",2)
	}
	"Cloning antcc repo to $ANTCC_HOME"
	if (test-path $ANTCC_HOME ){
		del $ANTCC_HOME -Recurse -Force
	}
	try{
    "git clone $ANTCC_URL $ANTCC_HOME"
		invoke-expression "git clone $ANTCC_URL $ANTCC_HOME"
	}catch{
		die ("Failed to clone antcc repo",3)
	}
	"Trying to add  environment variables to current user's profile"
	[Environment]::SetEnvironmentVariable("CC_CLI_HOME",$CC_CLI_HOME,"User")
    [Environment]::SetEnvironmentVariable("CC_CLI_HOME",$CC_CLI_HOME,"Process")
	[Environment]::SetEnvironmentVariable("ANTCC_HOME",$ANTCC_HOME,"User")
    [Environment]::SetEnvironmentVariable("ANTCC_HOME",$ANTCC_HOME,"Process")
    $ANT_HOME="$CC_HOME\common\lib\ant"
	[Environment]::SetEnvironmentVariable("ANT_HOME","$ANT_HOME","User")
	[Environment]::SetEnvironmentVariable("ANT_HOME","$ANT_HOME","Process")
	$JAVA_HOME=set-unless $env:JAVA_HOME "$CC_CLI_HOME\jvm\jvm\"
	[Environment]::SetEnvironmentVariable("JAVA_HOME","$JAVA_HOME","User")
	[Environment]::SetEnvironmentVariable("JAVA_HOME","$JAVA_HOME","Process")
	# checking if antcc is not in path already
    $USER_PATH=[Environment]::GetEnvironmentVariable("Path","User")
    $PROCESS_PATH=[Environment]::GetEnvironmentVariable("Path","Process")
	if(! ($PROCESS_PATH.Contains("$CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin"))){
        "Adding $CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin to current shell PATH variable"
		[Environment]::SetEnvironmentVariable("Path","$PROCESS_PATH;$CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin","Process")
	}
	if( $USER_PATH -and ! ($USER_PATH.Contains("$CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin"))){
        "Adding $CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin to PATH for all session of current user"
		[Environment]::SetEnvironmentVariable("Path","$USER_PATH;$CC_CLI_HOME\bin;$ANTCC_HOME\bin;$ANT_HOME\bin","User")
	}

    ""
    "Verify by running 'antcc help'"
    #"Please run the following commands manually, logout and login again or open a new command prompt"
	#"set CC_CLI_HOME=$CC_CLI_HOME"
	#"set ANTCC_HOME=$ANTCC_HOME"
	#"set ANT_HOME=$CC_HOME\common\lib\ant"
	#"set JAVA_HOME=$JAVA_HOME"
	#"set PATH=$env:PATH;$CC_CLI_HOME\bin:$ANTCC_HOME\bin:$ANT_HOME\bin"
}else{
	die "Download failed with http code: $HTTP_CODE" 1
}