pipeline {
    agent { 
        node {
            label 'slave1'
            }
      }
    // triggers {
    //     pollSCM '* * * * *'
    // }
    stages {
        stage('Build') {
            steps {
                echo "Building.."
                sh '''
                echo "building"
                '''
            }
        }
        stage('Test') {
            steps {
                echo "Testing.."
                sh '''
                robot "sanity-check(login,network,nvme,gpu).robot"
                '''
            }
        }
        stage('Deliver') {
            steps {
                echo 'Deliver....'
                sh '''
                echo "doing delivery stuff.."
                '''
            }
        }
    }
}
