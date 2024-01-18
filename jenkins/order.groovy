pipeline {
  agent any
  stages {
    stage('clone git lab repository') {
      steps {
        script {
            pwd
        }
      }
    }
  }
}