/* import shared library */
@Library('jenkins-shared-library')_

pipeline {
    agent any
    environment {
        //be sure to replace "willbla" with your own Docker Hub username
        DOCKER_IMAGE = "sampriyadarshi/"
        CANARY_REPLICAS = 0
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/multi-k8s.zip'
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    //app = docker.build(DOCKER_IMAGE_NAME)
                    app = docker.build("${DOCKER_IMAGE}multi-server", "./server/")
                    client = docker.build("${DOCKER_IMAGE}multi-client", "./client/")
                    worker = docker.build("${DOCKER_IMAGE}multi-worker", "./worker/")
                    //docker.build("my-image:${env.BUILD_ID}", "-f ${dockerfile} ./dockerfiles")
                    app.inside {
                        sh 'echo Hello, World!'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                        client.push("${env.BUILD_NUMBER}")
                        client.push("latest")
                        worker.push("${env.BUILD_NUMBER}")
                        worker.push("latest")
                    }
                }
            }
        }
       
        stage('CanaryDeploy') {
            when {
                branch 'master'
            }
            environment { 
                CANARY_REPLICAS = 1
            }
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'canray-deployment.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        /*stage('SmokeTest') {
            when {
                branch 'master'
            }
            steps {
                script {
                    sleep (time: 10)
                    def response = httpRequest (
                        url: "http://$KUBE_MASTER_IP:30020/",
                        timeout: 30
                    )
                    if (response.status != 200) {
                        error("Smoke test against canary deployment failed.")
                    }
                }
            }
        }*/
        /* 
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            steps {
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: '**/*.yaml',
                    enableConfigSubstitution: true
                )
            }
        }*/
    }
    post {
	/*cleanup {
            kubernetesDeploy (
                kubeconfigId: 'kubeconfig',
                configs: 'train-schedule-kube-canary.yml',
                enableConfigSubstitution: true
            )
        }*/
        always {
	    /* Use slackNotifier.groovy from shared library and provide current build result as parameter */   
            slackNotifier(currentBuild.currentResult)
            // cleanWs()
        }
    }
}
