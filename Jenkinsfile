pipeline {
    agent any
    environment {
        ARTIFACTORY_CRED = credentials('artifactory-cred')  // Jenkins credential ID for Artifactory username/password or API key
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/soodrajesh/JFrog-Jenkins-Artifact-Demo.git', branch: 'main'
            }
        }
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        stage('Publish to Artifactory') {
            steps {
                rtServer (
                    id: 'artifactory',
                    url: 'https://<your-artifactory-url>/artifactory',  // Replace with your Artifactory URL
                    credentialsId: 'artifactory-cred'
                )
                rtUpload (
                    serverId: 'artifactory',
                    spec: '''{
                        "files": [
                            {
                                "pattern": "build/*.zip",
                                "target": "generic-local/demo-app/"
                            }
                        ]
                    }'''
                )
            }
        }
        stage('Notify') {
            steps {
                slackSend(channel: '#jenkins-alerts', message: "Build #${env.BUILD_NUMBER} completed successfully!")
            }
        }
    }
    post {
        failure {
            slackSend(channel: '#jenkins-alerts', color: 'danger', message: "Build #${env.BUILD_NUMBER} failed!")
        }
    }
}