def call() {
 pipeline {
     agent {
         label 'submarine-static || kie-rhel7'
     }
     tools {
         maven 'kie-maven-3.5.4'
         jdk 'kie-jdk1.8'
     }
     stages {
         stage('Initialize') {
             steps {
                 echo "LOG:B1-1"
                 sh 'printenv'
                 echo "LOG:B1-2"
             }
         }
         stage('Build lienzo-core') {
             steps {
                 echo "LOG:B2"
                 dir("lienzo-core") {
                     script {
                         echo "LOG:B3"
                         githubscm.checkoutIfExists('lienzo-core', "$CHANGE_AUTHOR", "$CHANGE_BRANCH", 'kiegroup', "$CHANGE_TARGET")
                         maven.runMavenWithSubmarineSettings('clean install', true)
                     }
                 }
             }
         }
         stage('Build lienzo-tests') {
             steps {
                 script {
                     echo "LOG:B4"
                     maven.runMavenWithSubmarineSettings('clean install', false)
                 }
             }
         }
     }
 }
}