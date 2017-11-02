#!groovy​

def antbuild (command) {
    if (isUnix()) {
        sh "ant $command"
    } else {
        bat "ant $command"
    }
}

pipeline {
    agent { label 'master' }

    environment {
        INSTALLER_URL = "http://aquarius-bg.eur.ad.sag/cc/installers" // internal download site
    }
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }
    stages {
        stage("Prepare") {
            steps {
                //checkout scm
                stash 'scripts'
            }
        }
        stage("Unit Test") {
            // tools {
            //     ant "ant-1.9"
            //     jdk "jdk-1.8"
            // }
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    antbuild "-f main.xml -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=`pwd`/build/cli client"
                }
            }
            post {
                always {
                    antbuild "-f main.xml -Dinstall.dir=`pwd`/build/cc/cli uninstall"
                }
            }
        }
        stage("Platform Tests") {     
            environment {
                reboot = "-f main.xml -Daccept.license=true -Dinstaller.url=${env.INSTALLER_URL} -Dinstall.dir=${pwd()}/build/cc -Dport.range=33 uninstall boot"
                test = "-f main.xml ps jobs killjobs log logs restartcc waitcc stopcc"
            }
            steps {
                unstash 'scripts'
                script {
                    def labels = ['lnxamd64','w64','solamd64']
                    def builders = [:]
                    for (x in labels) {
                        def label = x
                        builders[label] = {
                            node(label) {
                                // tools {
                                //     ant "ant-1.9"
                                //     jdk "jdk-1.8"
                                // }                                
                                timeout(time:20, unit:'MINUTES') {
                                    antbuild "${reboot}"
                                    antbuild "${test}"
                                }
                            }
                        }                        
                    }
                    parallel builders // kick off parallel provisioning
                }                
            }
        } 
    }
}
