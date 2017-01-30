#!groovy​

pipeline {
    agent none

    environment {
        INSTALLER_URL = "http://aquarius-bg.eur.ad.sag/PDShare/cc" // internal download site
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

        // FIXME: target install dir!
        //stage("Component Test") {
        //    agent {
        //        docker {
        //            image 'frekele/ant'
        //            label 'docker'
        //            args "-v /tmp/build/:/test/"
        //        }
        //    }
        //    steps {
        //        timeout(time:5, unit:'MINUTES') {
        //            unstash 'scripts'
        //            sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=/test/sag uninstall boot ps jobs killjobs log logs restartcc waitcc stopcc"
        //        }
        //    }
        //}

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
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot ps jobs killjobs log logs restartcc waitcc stopcc"
                                sh "ant -f main.xml uninstall"
                            }
                        }
                    }
                    , "Solaris": {
                        node('solamd64') {
                            unstash 'scripts'
                            timeout(time:10, unit:'MINUTES') {
                                sh "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot ps jobs killjobs log logs restartcc waitcc stopcc"
                                sh "ant -f main.xml uninstall"
                            }
                        }
                    }
                    // FIXME: Windows installation fails if the VM is not clean!
                    //, "Windows": {
                    //    node('w64') {
                    //        unstash 'scripts'
                    //        timeout(time:10, unit:'MINUTES') {
                    //            bat "ant -f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=${pwd()}\\build\\cc -Dcce.http.port=${P}1 -Dcce.https.port=${P}2 -Dspm.http.port=${P}3 -Dspm.https.port=${P}4 uninstall boot ps jobs killjobs log logs restartcc waitcc stopcc"
                    //            bat "ant -f main.xml uninstall"
                    //        }
                    //    }
                    // }
                )
            }
        } 
    }
}
