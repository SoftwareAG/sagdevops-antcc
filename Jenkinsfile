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
        stage("Platform Tests") {     
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            } 
            steps {
                parallel (
                    "Linux": {
                        node('master') {
                            vSphere buildStep: [$class: 'PowerOff', vm: 'bgcctbp05', evenIfSuspended: false, shutdownGracefully: false], serverName: 'daevvc02'
                            vSphere buildStep: [$class: 'PowerOn',  vm: 'bgcctbp05', timeoutInSeconds: 180], serverName: 'daevvc02'
                        }
                        node('bgcctbp05') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                sh "ant -f main.xml -Dinstallers=cc-def-9.12-fix4-lnxamd64.sh,cc-def-9.10-fix4-lnxamd64.sh installers ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                    , "Solaris": {
                        node('master') {
                            vSphere buildStep: [$class: 'PowerOff', vm: 'bgcctbp21', evenIfSuspended: false, shutdownGracefully: false], serverName: 'daevvc02'
                            vSphere buildStep: [$class: 'PowerOn',  vm: 'bgcctbp21', timeoutInSeconds: 180], serverName: 'daevvc02'
                        }
                        node('solamd64') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                sh "ant -f main.xml -Dinstallers=cc-def-9.12-fix4-solamd64.sh,cc-def-9.10-fix4-solamd64.sh installers ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                    , "Windows": {
                        node('master') {
                            vSphere buildStep: [$class: 'PowerOff', vm: 'bgcctbp21', evenIfSuspended: false, shutdownGracefully: false], serverName: 'daevvc02'
                            vSphere buildStep: [$class: 'PowerOn',  vm: 'bgcctbp21', timeoutInSeconds: 180], serverName: 'daevvc02'
                        }
                        node('bgcctbp21') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                bat "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=${pwd()}\\build\\cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot"
                                bat "ant -f main.xml -Dinstallers=cc-def-9.12-fix4-w64.sh,cc-def-9.10-fix4-w64.sh installers ps jobs killjobs log logs restartcc waitcc stopcc"
                            }
                        }
                    }
                )
            }
        } 
    }
}
