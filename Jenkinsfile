@Library('jenkins-pipeline-shared-libraries')_

agentLabel = "${env.ADDITIONAL_LABEL?.trim() ? ADDITIONAL_LABEL : 'kie-rhel7 && kie-mem24g'} && !master"
additionalArtifactsToArchive = "${env.ADDITIONAL_ARTIFACTS_TO_ARCHIVE?.trim() ?: ''}"
additionalTimeout = "${env.ADDITIONAL_TIMEOUT?.trim() ?: 1200}"
additionalExcludedArtifacts = "${env.ADDITIONAL_EXCLUDED_ARTIFACTS?.trim() ?: ''}"
checkstyleFile = env.CHECKSTYLE_FILE?.trim() ?: null
findbugsFile = env.FINDBUGS_FILE?.trim() ?: null
pr_type = env.PR_TYPE?.trim() ?: null

pipeline {
    agent {
        label agentLabel
    }
    tools {
        maven 'kie-maven-3.6.3'
        jdk 'kie-jdk1.8'
    }
    options {
        timestamps ()
        timeout(time: additionalTimeout, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'printenv'

            }
        }
        // executes a script that compresses the consoleText and attaches it to the mail
        stage('build sh script') {
            steps {
                script {
                    mailer.buildLogScriptPR()
                }
            }
        }
        stage('Build projects') {
            steps {
                script {
                    def file =  (JOB_NAME =~ /\/[a-z,A-Z\-0-9\.]*\.downstream\.production/).find() ? 'downstream.production.stages' :
                                (JOB_NAME =~ /\/new-[a-z,A-Z\-0-9\.]*\.downstream/).find() ? 'new.downstream.stages' :
                                (JOB_NAME =~ /\/[a-z,A-Z\-0-9\.]*\.downstream/).find() ? 'downstream.stages' :
                                (JOB_NAME =~ /\/[a-z,A-Z\-0-9\.]*\.pullrequest/).find() ? 'pullrequest.stages' :
                                (JOB_NAME =~ /\/[a-z,A-Z\-0-9\.]*\.compile/).find() ? 'compilation.stages' :
                                'upstream.stages'
                    if(fileExists("$WORKSPACE/.ci/${file}")) {
                        println "File ${file} exists, loading it."
                            def stage = load("$WORKSPACE/.ci/${file}")
                            stage("$WORKSPACE/.ci")
                    } else {
                        dir("droolsjbpm-build-bootstrap") {
                            def changeAuthor = env.CHANGE_AUTHOR ?: env.ghprbPullAuthorLogin
                            def changeBranch = env.CHANGE_BRANCH ?: env.ghprbSourceBranch
                            def changeTarget = env.CHANGE_TARGET ?: env.ghprbTargetBranch

                            println "File ${file} does not exist. Loading the one from droolsjbpm-build-bootstrap project. Author [${changeAuthor}], branch [${changeBranch}]..."
                            githubscm.checkoutIfExists('droolsjbpm-build-bootstrap', "${changeAuthor}", "${changeBranch}", 'kiegroup', "${changeTarget}")
                            println "Loading ${file} file..."
                            def stage = load("${file}")
                            stage("$WORKSPACE/droolsjbpm-build-bootstrap/.ci")
                        }
                    }
                }
            }
        }
    }
    post {
        fixed {
            script {
                mailer.sendEmail_fixedPR(pr_type)
            }
        }
        aborted {
            script {
                mailer.sendEmail_abortedPR(pr_type)
            }
        }
        failure {
            sh '$WORKSPACE/trace.sh'
            script {
                mailer.sendEmail_failedPR(pr_type)
            }
        }
        unstable {
            script {
                mailer.sendEmail_unstablePR(pr_type)
            }
        }
        always {
            script {
                util.printGitInformationReport()
            }
            echo 'Generating JUnit report...'
            junit allowEmptyResults: true, healthScaleFactor: 1.0, testResults: '**/target/*-reports/TEST-*.xml'

            echo 'Archiving logs...'
            archiveArtifacts excludes: '**/target/checkstyle.log', artifacts: '**/*.maven.log,**/target/*.log', fingerprint: false, defaultExcludes: true, caseSensitive: true, allowEmptyArchive: true

            echo 'Archiving testStatusListener and screenshots artifacts...'
            archiveArtifacts allowEmptyArchive: true, artifacts: '**/target/testStatusListener*,**/target/screenshots/**', excludes: additionalExcludedArtifacts, fingerprint: false, defaultExcludes: true, caseSensitive: true

            echo 'Archiving wars...'
            archiveArtifacts artifacts: '**/target/business-monitoring-webapp.war,**/target/business-central*wildfly*.war,**/target/business-central*eap*.war,**/target/kie-server-*ee7.war,**/target/kie-server-*webc.war,**/target/dashbuilder-runtime.war', fingerprint: false, defaultExcludes: true, caseSensitive: true, allowEmptyArchive: true

            echo 'Archiving zips...'
            archiveArtifacts artifacts: '**/target/jbpm-server*dist*.zip', fingerprint: false, defaultExcludes: true, caseSensitive: true, allowEmptyArchive: true

            script {
                if(additionalArtifactsToArchive) {
                    echo 'Archiving additional Artifacts ...'
                    archiveArtifacts allowEmptyArchive: true, artifacts: additionalArtifactsToArchive, excludes: additionalExcludedArtifacts, fingerprint: false, defaultExcludes: true, caseSensitive: true
                }
            }
            
            script {
                if(findbugsFile) {
                    echo 'Findbugs reports ...'
                    findbugs canComputeNew: false, defaultEncoding: '', excludePattern: '', healthy: '', includePattern: '', pattern: findbugsFile, unHealthy: ''
                }
            }
            script {
                if(checkstyleFile) {
                    echo 'Checkstyle reports ...'
                    checkstyle canComputeNew: false, defaultEncoding: '', healthy: '', pattern: checkstyleFile, unHealthy: ''
                }
            }
        }
        cleanup {
            cleanWs()
        }
    }
}
