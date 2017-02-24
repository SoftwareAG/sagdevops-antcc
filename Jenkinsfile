#!groovy​

pipeline {
    agent none

    environment {
        INSTALLER_URL = "http://aquarius-bg.eur.ad.sag/cc/installers" // internal download site
        P = '333' // TODO: random free port range
    }

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    stages {
        stage("Prepare") {
            agent {
                label 'master'
            }
            steps {
                checkout scm
                stash(name:'scripts', includes:'**')
            }
        }
        
        stage("Unit Test") {
            agent {
                label 'lnxamd64'
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }
            steps {
                unstash 'scripts'
                timeout(time:2, unit:'MINUTES') {
                    sh "ant -f main.xml -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cli client"
                }
            }
            post {
                always {
                    sh "ant -f main.xml -Dinstall.dir=`pwd`/build/cc/cli uninstall"
                }
            }
        }
        
        stage("Restart VMs") {
            agent {
                label 'master'
            }
            steps {
                // TODO: clean this up
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt11'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt02'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt22'], serverName: 'daevvc02'
                sleep 10
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt11'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt02'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt22'], serverName: 'daevvc02'
                sleep 80
            }
        }
        stage("Platform Tests") {     
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            } 
            steps {
                parallel (
                    "Linux": {
                        node('lnxamd64') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                sh "ant -f main.xml ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                    , "Solaris": {
                        node('solamd64') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                sh "ant -f main.xml ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                    , "Windows": {
                        node('w64') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                bat "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=${pwd()}\\build\\cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                bat "ant -f main.xml ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                )
            }
        } 
    }
}
