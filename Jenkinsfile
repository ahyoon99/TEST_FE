pipeline {
    agent any
    
    tools {
        nodejs 'Node16'
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE_FE = "your-dockerhub-username/test-fe"
        VERSION = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        // CI: 모든 브랜치에서 실행되는 테스트
        stage('Install & Test') {
            steps {
                sh 'npm install'
                sh 'npm run test' // Vue 프로젝트에 테스트가 설정되어 있어야 함
            }
            post {
                success {
                    echo '테스트 성공! 코드가 품질 기준을 통과했습니다.'
                }
                failure {
                    echo '테스트 실패! 코드를 수정해주세요.'
                }
            }
        }
        
        // CD: main/master 브랜치에서만 실행되는 배포 단계
        stage('Build') {
            when {
                branch 'master' // 또는 'main'
            }
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Build & Push Docker Image') {
            when {
                branch 'master' // 또는 'main'
            }
            steps {
                // Docker Hub 로그인
                sh 'echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin'
                
                // Docker 이미지 빌드 및 푸시
                sh "docker build -t ${DOCKER_IMAGE_FE}:${VERSION} -t ${DOCKER_IMAGE_FE}:latest ."
                sh "docker push ${DOCKER_IMAGE_FE}:${VERSION}"
                sh "docker push ${DOCKER_IMAGE_FE}:latest"
            }
        }
        
        stage('Trigger Deployment') {
            when {
                branch 'master' // 또는 'main'
            }
            steps {
                // 배포 작업 트리거
                build job: 'TEST-Deploy', wait: false,
                parameters: [
                    string(name: 'FE_VERSION', value: "${VERSION}"),
                    string(name: 'COMPONENT', value: "frontend")
                ]
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo '프론트엔드 파이프라인이 성공적으로 완료되었습니다!'
        }
        failure {
            echo '프론트엔드 파이프라인이 실패했습니다.'
        }
    }
}