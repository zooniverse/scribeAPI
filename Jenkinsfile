pipeline {
  agent none

  options {
    disableConcurrentBuilds()
  }

  stages {
    stage('Notify Slack') {
      when { branch 'old-weather-whaling-production' }
      agent any
      steps {
        slackSend (
          color: '#00FF00',
          message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
          channel: "#ops"
        )
      }
    }
    stage('Build Docker image') {
      agent any
      steps {
        script {
          def dockerRepoName = 'zooniverse/scribeapi'
          def dockerImageName = "${dockerRepoName}:whaling-${GIT_COMMIT}"
          def newImage = null

          newImage = docker.build(dockerImageName)
          newImage.push()

          if (BRANCH_NAME == 'master') {
            newImage.push('latest')
          }
        }
      }
    }
    stage('Deploy to Kubernetes') {
      when { branch 'old-weather-whaling-production' }
      agent any
      steps {
        sh "kubectl apply --record -f kubernetes/"
        sh "sed 's/__IMAGE_TAG__/${GIT_COMMIT}/g' kubernetes/deployment.tmpl | kubectl apply --record -f -"
      }
    }
  }
  post {
    success {
      script {
        if (BRANCH_NAME == 'old-weather-whaling-production') {
          slackSend (
            color: '#00FF00',
            message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }

    failure {
      script {
        if (BRANCH_NAME == 'old-weather-whaling-production') {
          slackSend (
            color: '#FF0000',
            message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            channel: "#ops"
          )
        }
      }
    }
  }
}
