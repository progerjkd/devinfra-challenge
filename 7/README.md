# Jenkins pipeline to GitLab pipeline

This task involves the conversion of a Jenkins pipeline to a GitLab pipeline.
The `post` step was dropped, because GitLab has a per-project built-in notification engine, acessible via "Project -> Settings -> Integrations -> Pipelines emails".
![enter image description here](https://github.com/progerjkd/devinfra-challenge/raw/master/7/email_integration.png)

This feature has the option to 'Notify only broken pipelines', as suggested in the Jenkinsfile.

Bellow is a example of the email notification sent.

![enter image description here](https://github.com/progerjkd/devinfra-challenge/raw/master/7/email_received.png)

## GitLab pipeline

```yaml
    stages:
      - checkout
      - test

    checkout job:
      stage: checkout
      variables:
        GIT_STRATEGY: clone
        GIT_CHECKOUT: "false"
      script:
        - REPO_URL=""
        - git clone $REPO_URL
      artifacts:
        expire_in: 30 days

    Run the tests:
      stage: test
      script:
        - docker build -t my-image .
        - docker run my-image python3 -m unittest
   ```

## Jenkins pipeline
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
