[![Build Status](https://travis-ci.org/SoftwareAG/sagdevops-antcc.svg?branch=master)](https://travis-ci.org/SoftwareAG/sagdevops-antcc/builds)



# Command Central Project Automation Tool

AntCC is Software AG DevOps library to support Infrastructure as Code 
projects for Command Central.
It is based on well-known Apache Ant build automation framework.

The tool defines a typical Command Central Infrastructure project structure
and provides default targets (commands) for developing and testing 

## Requirements and Dependencies

* [Apache Ant 1.9.x](https://ant.apache.org/)
* [Java 1.8.x](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## Quick Start

Short usage help

```
ant -f main.xml -p
```

More help:

```
ant -f main.xml -S
```

# Project Structure and Default Targets

Complete project structure looks like this:

```
build.xml

bootstrap/
  default.properties
  other.properties

clients/
  default.properties
  other.properties
  default/
    cc.properties
  other/
    cc.properties

environments/
   default/
     env.properties
   other/
     env.properties

templates/
   template1/
     template.yaml
   template2/
     template.yaml

tests/
  suite1/
     test1.xml
     test2.xml
  test3.xml
  test4.xml
```

Most folders and files are optional and each of them are described below.

## Build.xml

The project MUST have build.xml file in its root.

The build.xml content at a minimum MUST import main.xml from the ANTCC distribution.

```
<?xml version="1.0"?>
<project>
	<import file="antcc/main.xml" />
</project>
```

The import provides access to default ANTCC targets and is enough to start using
the project, however more often you will add your own automation targets to this
main build.xml script.

The build.xml is a standard Apache Ant script you can use all the facilities
that Ant provides for writing cross-platform automation scripts by leveraging

* Generic targets imported from ANTCC
* Any Command Central REST API available via CC CLI commands
* Any generic automation facilities provided by Ant tasks and libraries
* Any 3-rd party tooling that provide CLI or API

For GIT based automation projects it is recommended to include ANTCC as a submodule

```
git submodule add _clone_url_to_this_project.git_ antcc
```

If your project is not on GIT you can clone ANTCC project anywhere on the local
file system and reference it using relative or absolute path.

## Bootstrap

ANTCC tool provides generic targets to download
and then bootstrap Command Central server, CC CLI or SPM.
Bootstrap folder is optional and allows to customize bootstrap parameters.

```
bootstrap
  default.properties
  custom.properties
```

Default targets provided by bootstrap plugin:

```
ant -f lib/bootstrap.xml -S

Optional parameter for any target:

-Dbootstrap=other                Bootstrap local Command Central server
                                 using defaults from 'bootstrap/default.properties'
                                 or custom 'bootstrap/other.properties'
Targets:

ant boot                         Bootstrap local Command Central server
ant client                       Bootstrap local CC CLI (client)
ant agent                        Bootstrap local SPM (agent)
ant installers -Dinstallers=f1,f2 Download bootstrap installers
ant upgrade                      Upgrade local Command Central server
ant startcc                      Start local Command Central server
ant stopcc                       Stop local Command Central server
```

You MUST bootstrap at least 'client' if not complete Command Central server
locally in order to execute other project targets.

## Clients

After Command Central server or client is bootstrapped the default client
configuration is available for the current user, typically in ~/.sag/cc.properties file.

This configuration is used by default.

If you want your project to use a different client configuration file make a copy of
the configuration file and store it as client/default.properties.

You can have as many client configuration files as you need.

```
clients
  default.properties
  custom.properties
```

Default targets provided by sagcc plugin:

```
ant -f lib/sagcc.xml -S

Optional parameter for any target:

-Dcc=other                       Connection to Command Central server
                                 using global settings in '~/.sag/cc.properties'
                                 or project defaults from 'clients/cc.properties'
                                 or custom 'clients/other.properties'
Targets:

ant waitcc                       Wait for Command Central ready status
ant restartcc                    Restart local or remote Command Central server
ant jobs                         List recent jogs
ant killjobs                     Cancel active and remove completed jobs
ant log                          Show tail of Command Central default log
ant logs                         Show tail of agents default log
```

## Environments

Project can operate with a single default environment or multiple environments.

The default environment configuration is stored in 
environments/default/env.properties file.

For additonal environments create a separate folder and place env.properties
file there. The final structure looks like this:

```
environments
  default
    env.properties
  other
    env.properties
```

After the environments are defined you can apply existing templates 

Default targets provided by sagenv plugin:

```
ant -f lib/sagenv.xml -S

Optional parameter for any target:

-Denv=other                      Environment configuration to use from
                                 project defaults in 'environments/default/env.properties'
                                 or custom 'environments/other/env.properties'
Targets:

ant apply -Dalias=template       Apply template using its alias
```

## Templates

Project normally provide custom templates, at least one.

The templates are placed under templates/ folder, each template in a separate
folder. The template folder must have at least template.yaml file but may provide
any additional files to package with the template.

```
templates
   template1
     template.yaml
   template2
     template.yaml
     otherfolder
       otherfile
```

After the template(s) have been created they can be imported and applied.

Default targets provided by sagenv plugin:

```
ant -f lib/sagenv.xml -S

Optional parameter for any target:

-Denv=other                      Environment configuration to use from
                                 project defaults in 'environments/default/env.properties'
                                 or custom 'environments/other/env.properties'
Targets:

ant up                           Import and apply all project 'templates/*'
ant apply -Dalias=template       Apply template using its alias
ant import -Dt=templateFolder    Reimport template from source folder by do not apply
ant apply -Dt=templateFolder     Reimport and apply template from source folder
ant migrate -Dt=templateFolder   Reimport and migrate using template from source folder
```

## Tests

Your project should have tests. 

ANTCC allows you easily define tests using [AntUnit](https://ant.apache.org/antlibs/antunit/) framework.

Create AntUnit tests and save them as tests/test*.xml files.

```
tests
  test1.xml
  test2.xml
```

Default targets provided by sagtest.xml plugin:

```
ant -f lib/sagtest.xml -S

Optional parameter for any target:

-Dsuite=some                     Run only tests from 'tests/some/*' folder

Targets:

ant test                         Run tests/test*.xml AntUnit tests

```

# Enabling your project for Infrastructure automation

Create the project folder or cd into existing project

```bash
mkdir ~/myproj1
cd ~/myproj1
```

Initialze git repository (if not done yet) and add antcc submodule

```bash
git init
git submodule add <antcc_clone_url.git> antcc
```

Create build.xml in the root of the project: 

```xml
<?xml version="1.0"?>
<project>
	<import file="antcc/main.xml" />
</project>
```

If the project is already Ant-enabled add this to the existing build.xml

```xml
<import file="antcc/main.xml" />
```

Create bootstrap configuration file, customize as needed.


```bash
mkdir -p bootstrap
cat <<EOF > bootstrap/default.properties
accept.license=true
installer=cc-def-9.12-fix2-\${platform}
install.dir=\${user.home}/sag/cc
cce.http.port=8090
cce.https.port=8091
spm.http.port=8092
spm.https.port=8093
EOF
```

IMPORTANT: By setting ```accept.license=true``` property you are accepting [End User License Agreement](http://documentation.softwareag.com/legal/general_license.txt)

Download the bootstrap installer from [Empower](https://empower.softwareag.com/Products/DownloadProducts/sdc/default.asp) 
and save it under ~/Downloads folder

Run bootstrap process

```bash
ant boot
```

Verify connection

```bash
ant jobs
```

Create basic template

```bash
mkdir templates/default
cat <<EOF > templates/default/template.yaml
alias: default
environments:
  default:
    foo: bar
EOF
```

Create default environment configuration

```bash
mkdir environments/default
cat <<EOF > environments/default/env.properties
foo=baz
EOF
```

Apply template, check logs and jobs

```bash
ant up 
ant jobs log logs
```


## Working with remote servers

Create default or custom client configuration file

```bash
mkdir -p clients/default
cat <<EOF > clients/default/cc.properties
server=http://localhost:8090
username=Administrator
password=manage
cc.cli.home=\${user.home}/sag/cc/CommandCentral/client
EOF
```

Any command will now execute against this remote server by default.

```bash
ant waitcc up jobs log logs
```
_____________
Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
_____________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
