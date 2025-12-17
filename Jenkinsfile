pipeline {
    agent any

    tools {
        maven 'Maven_Home'   // MUST match Jenkins Tools name
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
                withSonarQubeEnv('Sonar Scanner') {   // MUST match server name
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
    }

    post {
        success {
            echo 'Build & SonarQube passed'
        }
        failure {
            echo 'Pipeline failed'
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
            echo "Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
