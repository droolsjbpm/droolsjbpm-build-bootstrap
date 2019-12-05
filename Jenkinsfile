@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'submarine-static || kie-rhel7'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 10, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                echo "LOG:A1-1"
                sh 'printenv'
                echo "LOG:A1-2"
            }
        }
        stage('Build lienzo-tests') {
            steps {
                script {
                    echo "LOG:A2-1"
                    load("$WORKSPACE/lienzo-tests/Jenkinsfile")
                    echo "LOG:A2-2"
                }
            }
        }
        stage('Build kie-parent') {
            steps {
                script {
                    echo "LOG:A3-1"
                    maven.runMavenWithSubmarineSettings('clean install -DskipTests', false)
                    echo "LOG:A3-2"
                }
            }
        }
    }
    post {
        unstable {
            script {
                mailer.sendEmailFailure()
            }
        }
        failure {
            script {
                mailer.sendEmailFailure()
            }
        }
        always {
            // Currently there are no tests in submarine-examples
            //junit '**/target/surefire-reports/**/*.xml'
            cleanWs()
        }
    }
}