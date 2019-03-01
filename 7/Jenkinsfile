pipeline {
  agent any

  options {
    skipDefaultCheckout true
    disableConcurrentBuilds()
    buildDiscarder(logRotator(
      artifactDaysToKeepStr: '1',
      artifactNumToKeepStr: '3',
      daysToKeepStr: '30',
      numToKeepStr: '50'
    ))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          submoduleCfg: [],
          branches: scm.branches,
          extensions: scm.extensions + [
          [$class: 'CleanBeforeCheckout', cleanSubmodule: true],
          ],
          userRemoteConfigs: scm.userRemoteConfigs,
          doGenerateSubmoduleConfigurations: false,
        ])
      }
    }

    stage('Run the tests') {
      agent {
        dockerfile {
          reuseNode true
        }
      }
      steps {
        sh "python3 -m unittest"
      }
    }
  }

  post {
    failure {
      mail to: "${env.CHANGE_AUTHOR_EMAIL}",
      cc: "omg@example.com",
      subject: "FAILED: ${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}",
      mimeType: "text/html",
      body: "<p>Check <a href='${env.RUN_DISPLAY_URL}'>${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}'>"
    }
  }
}
