@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'kie-rhel7 && kie-mem24g && !master'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 1200, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'printenv'

            }
        }
        stage('Build projects') {
            steps {
                script {
                    def file =  (JOB_NAME =~ /\/[a-z,A-Z\-]*\.downstream\.production/).find() ? 'downstream.production.stages' :
                                (JOB_NAME =~ /\/[a-z,A-Z\-]*\.downstream/).find() ? 'downstream.stages' :
                                'upstream.stages'
                    if(fileExists("$WORKSPACE/${file}")) {
                        println "File ${file} exists, loading it."
                        load("$WORKSPACE/${file}")
                    } else {
                        dir("droolsjbpm-build-bootstrap") {
                            def changeAuthor = env.CHANGE_AUTHOR ?: env.ghprbPullAuthorLogin
                            def changeBranch = env.CHANGE_BRANCH ?: env.ghprbSourceBranch
                            def changeTarget = env.CHANGE_TARGET ?: env.ghprbTargetBranch

                            println "File ${file} does not exist. Loading the one from droolsjbpm-build-bootstrap project. Author [${changeAuthor}], branch [${changeBranch}]..."
                            githubscm.checkoutIfExists('droolsjbpm-build-bootstrap', "${changeAuthor}", "${changeBranch}", 'kiegroup', "${changeTarget}")
                            println "Loading ${file} file..."
                            load("${file}")
                        }
                    }
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
            junit allowEmptyResults: true, healthScaleFactor: 1.0, testResults: '**/target/*-reports/TEST-*.xml'
            archiveArtifacts excludes: '**/target/checkstyle.log', artifacts: '**/target/*.log,**/target/testStatusListener*,**/target/screenshots/**,**/target/business-central*wildfly*.war,**/target/business-central*eap*.war,**/target/kie-server-*ee7.war,**/target/kie-server-*webc.war,**/target/jbpm-server*dist*.zip', fingerprint: false, defaultExcludes: true, caseSensitive: true, allowEmptyArchive: true
            cleanWs()
        }
    }
}
