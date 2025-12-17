pipeline {
    agent any

    tools {
        maven 'Maven_Home'   // must match Jenkins Tools name
    }

    environment {
        IMAGE_NAME = 'viresh1994/my-app'
        DOCKER_CREDS = credentials('dockerhub-creds')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    GIT_SHA = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
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
            when {
                expression { env.GIT_BRANCH == 'master' }
            }
            steps {
                sh '''
                  docker build \
                    -t ${IMAGE_NAME}:${GIT_SHA} \
                    -t ${IMAGE_NAME}:latest \
                    .
                '''
            }
        }
		
		stage('Docker Push') {
            when {
                expression { env.GIT_BRANCH == 'master' }
            }
            steps {
                sh '''
                  echo "$DOCKER_CREDS_PSW" | docker login \
                    -u "$DOCKER_CREDS_USR" \
                    --password-stdin

                  docker push ${IMAGE_NAME}:${GIT_SHA}
                  docker push ${IMAGE_NAME}:latest
                '''
            }
        }
    }

     post {
        success {
            echo "Pipeline SUCCESS"
            echo "Branch: ${env.GIT_BRANCH}"
			echo "Docker image pushed: ${IMAGE_NAME}:${GIT_SHA}"
        }
        failure {
            echo "Pipeline FAILED"
        }
    }
}