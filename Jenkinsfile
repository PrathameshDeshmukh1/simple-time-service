pipeline {
    agent any

    environment {
        IMAGE_NAME = "simple-time-service"
        APP_ENV = "dev"
        SONAR_HOST = "http://localhost:9000"
        SONAR_CRED = "sonar-token"    // Jenkins credential ID for SonarQube token
    }

    triggers {
        // Run on every commit or daily
        pollSCM('@daily')
        // cron('H 2 * * *')  // optional: daily at ~2 AM
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Unit Tests') {
            steps {
                sh 'python -m pip install -r requirements.txt'
                sh 'pytest -q || true'   // Optional: don't fail pipeline yet
            }
        }

        stage('Static Code Analysis - SonarQube') {
            environment {
                SONAR_TOKEN = credentials("${SONAR_CRED}")
            }
            steps {
                sh '''
                sonar-scanner \
                  -Dsonar.projectKey=${JOB_NAME} \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=${SONAR_HOST} \
                  -Dsonar.login=${SONAR_TOKEN}
                '''
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Use Minikube Docker daemon to avoid external registry
                    sh 'eval $(minikube -p minikube docker-env) && docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                which trivy || (echo "Install trivy on Jenkins agent or run as docker container" && exit 0)
                trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${BUILD_NUMBER} || true
                '''
            }
        }

        stage('Deploy to Dev (Minikube)') {
            steps {
                sh '''
                # Apply K8s deployment and service
                kubectl apply -f k8s-deployment.yaml -n dev || kubectl create namespace dev || true

                # Update deployment image
                kubectl set image deployment/simple-time-service simple-time-service=${IMAGE_NAME}:${BUILD_NUMBER} -n dev --record

                # Wait for rollout
                kubectl rollout status deployment/simple-time-service -n dev --timeout=120s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods -n dev'
                sh 'kubectl get svc -n dev'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded! Application deployed to Dev"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
