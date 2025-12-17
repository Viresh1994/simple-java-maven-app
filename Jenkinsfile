pipeline {
    agent any

    tools {
        maven 'Maven_Home'   // must match Jenkins Tools name
    }

    environment {
        IMAGE_NAME = 'my-app'
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar Scanner') {   // must match Sonar server name
                    sh '''
                      mvn sonar:sonar \
                        -Dsonar.projectKey=my-app \
                        -Dsonar.projectName=my-app \
                        -Dsonar.java.binaries=target
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                  docker build \
                    -t ${IMAGE_NAME}:${IMAGE_TAG} \
                    .
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline successful. Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}