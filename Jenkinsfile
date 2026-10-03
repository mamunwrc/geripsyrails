pipeline {
    agent any

    environment {
        ACR_NAME = "mamunacr.azurecr.io"
        IMAGE_NAME = "geripsy-app"
        AKS_RESOURCE_GROUP = "Mamun_group"
        AKS_CLUSTER_NAME = "mamun-aks"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                    sh """
                        echo \$ACR_PASS | docker login ${ACR_NAME} -u \$ACR_USER --password-stdin
                        docker push ${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker tag ${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER} ${ACR_NAME}/${IMAGE_NAME}:latest
                        docker push ${ACR_NAME}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl set image deployment/geripsy-app geripsy-app=${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER} --kubeconfig=\$KUBECONFIG
                    """
                }
            }
        }
    }
}

