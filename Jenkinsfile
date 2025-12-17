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
				git branch: 'master',
					url: 'https://github.com/Viresh1994/simple-java-maven-app.git'

			script {
				env.GIT_SHA = sh(
					script: 'git rev-parse --short HEAD',
					returnStdout: true
				).trim()

				env.GIT_BRANCH = sh(
					script: 'git branch --show-current',
					returnStdout: true
				).trim()

				echo "Branch: ${env.GIT_BRANCH}"
				echo "Commit: ${env.GIT_SHA}"
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
                expression { env.GIT_BRANCH.endsWith('/master') }
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
		
		stage('Trivy Scan') {
			when {
				expression { env.GIT_BRANCH.endsWith('/master') }
			}
			steps {
				sh '''
				  TRIVY_CONFIG=/dev/null trivy image \
					--scanners vuln \
					--severity CRITICAL \
					--exit-code 1 \
					${IMAGE_NAME}:${GIT_SHA}
				'''
			}
		}
		
		stage('Docker Push') {
            when {
                expression { env.GIT_BRANCH.endsWith('/master') }
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