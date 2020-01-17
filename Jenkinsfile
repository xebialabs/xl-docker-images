#!groovy

def xl_LatestVersion = ""

pipeline {
    agent none

    parameters {
        choice(
            name: 'XLProduct',
            choices: ['xl-release', 'xl-deploy'],
            description: "Which XL Product you want to generate Docker Image for")
        string(
            name: 'Version',
            defaultValue: '',
            description: "Version of XL Product you want to create Docker Images for")
        booleanParam(
            name: 'Linux',
            defaultValue: true,
            description: 'Specifies if Target OS is "Debian-slim, CentOS, Amazon" which defines what tags will be generated')
        booleanParam(
            name: 'RHEL',
            defaultValue: false,
            description: 'Specifies if Target OS is "RHEL" which defines what tags will be generated')
        choice(
            name: 'Registry',
            choices: ['xl-docker.xebialabs.com', 'xebialabs', 'xebialabsunsupported', 'xebialabsearlyaccess'],
            description: "Docker Registry you want to push non RHEL Docker Images to")
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20', artifactDaysToKeepStr: '7', artifactNumToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        ansiColor('xterm')
    }

    environment {
        xlrelease_RHEL_registry = 'p762626407e78baea07bf3901fb89bdaf24e2db505'
        xldeploy_RHEL_registry = 'p213351287537b1081d854572a246c48cdf8f9d5585'
    }

    stages {
        stage('Rendering Docker Images for XLProducts') {
            parallel {
                stage('Rendering Docker Images for debian-slim centos amazonlinux') {
                    when {
                         expression { params.Linux == true }
                    }
                    agent {
                            label 'docker_linux'
                    }
                    steps {
                        // Clean old workspace
                        step([$class: 'WsCleanup'])
                        checkout scm

                        // Clean docker images including volumes
                        sh '''
                            docker rm -f $(docker ps -a -q) 2>/dev/null || echo "No more containers to remove."
                            docker rmi $(docker images -q) 2>/dev/null || echo "No more images to remove."
                            docker system prune -a --volumes -f 2>/dev/null || echo "No more data to prun."
                        '''

                        // install pipenv and needed dependencies
                        sh 'pipenv install'

                        // Rendering and Committing changes
                        script {
                            xl_LatestVersion = getLatestVersion()
                            if ((xl_LatestVersion.toString().contains("alpha") || xl_LatestVersion.toString().contains("rc") ) && (params.Registry != "xebialabs")) {
                                sh "pipenv run ./applejack.py render --xl-version ${xl_LatestVersion} --product ${params.XLProduct} --registry ${params.Registry}"
                            } else {
                                sh "pipenv run ./applejack.py render --xl-version ${xl_LatestVersion} --product ${params.XLProduct} --registry ${params.Registry} --commit"
                            }
                        }
                    }
                }

                stage('Rendering Docker Images for rhel') {
                    when {
                         expression { params.RHEL == true }
                    }
                    agent {
                            label 'docker_rhel'
                    }
                    steps {
                        // Clean old workspace
                        step([$class: 'WsCleanup'])
                        checkout scm

                        // Clean docker images including volumes
                        sh '''
                            docker rm -vf $(docker ps -a -q) 2>/dev/null || echo "No more containers to remove."
                            docker rmi $(docker images -q) 2>/dev/null || echo "No more images to remove."
                            docker system prune -a -f 2>/dev/null || echo "No more data to prun."
                        '''

                        // install pipenv and needed dependencies
                        sh 'pipenv install'

                        // Rendering and Committing changes
                        script {
                            xl_LatestVersion = getLatestVersion()
                            if (xl_LatestVersion.toString().contains("alpha") || xl_LatestVersion.toString().contains("rc")) {
                                sh "pipenv run ./applejack.py render --xl-version ${xl_LatestVersion} --product ${params.XLProduct}"
                            } else {
                                sh "pipenv run ./applejack.py render --xl-version ${xl_LatestVersion} --product ${params.XLProduct} --commit"
                            }
                        }
                    }
                }
            }
        }

        stage('Build Docker Images for XLProducts') {
            parallel {
                stage('Build Docker Images for debian-slim centos amazonlinux') {
                    when {
                         expression { params.Linux == true }
                    }
                    agent {
                            label 'docker_linux'
                    }
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'nexus_credentials', passwordVariable: 'nexus_pass', usernameVariable: 'nexus_user')]) {
                            // Build Docker Image and push it
                            sh "pipenv run ./applejack.py build --xl-version ${xl_LatestVersion} --download-source nexus --download-username ${nexus_user} --download-password ${nexus_pass}  --product ${params.XLProduct}  --target-os debian-slim --target-os centos --target-os amazonlinux --push --registry ${params.Registry}"
                        }
                    }
                }

                stage('Build Docker Images for rhel') {
                    when {
                         expression { params.RHEL == true }
                    }
                    agent {
                            label 'docker_rhel'
                    }
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'nexus_credentials', passwordVariable: 'nexus_pass', usernameVariable: 'nexus_user'),
                        string(credentialsId: 'xlr-rhel-token', variable: 'xlrelease_rhel_token'),
                        string(credentialsId: 'xld-rhel-token', variable: 'xldeploy_rhel_token')]) {
                            // Build Docker Image and push it
                            script {
                                // build docker images and push it to internal docker registry
                                sh "pipenv run ./applejack.py build --xl-version ${xl_LatestVersion} --download-source nexus --download-username ${nexus_user} --download-password ${nexus_pass}  --product ${params.XLProduct}  --target-os rhel --push --registry xl-docker.xebialabs.com"

                                if (!(xl_LatestVersion.toString().contains("alpha"))) {
                                    // push to redhat resgistry
                                    def imageid = sh(script: "docker images | grep ${params.XLProduct} | grep ${xl_LatestVersion} | awk -e '{print \$3}'", returnStdout: true).trim()

                                    if (params.XLProduct == 'xl-release') {
                                        // Login to rhel Docker
                                        sh "docker login -u unused -e none scan.connect.redhat.com -p xlrelease_rhel_token"
                                        // tag and push
                                        sh "docker tag ${imageid} scan.connect.redhat.com/${env.xlrelease_rhel_registry}/${params.XLProduct}:${xl_LatestVersion}-rhel"
                                        sh "docker push scan.connect.redhat.com/${env.xlrelease_rhel_registry}/${params.XLProduct}:${xl_LatestVersion}-rhel"

                                    } else if (params.XLProduct == 'xl-deploy') {
                                        // Login to rhel Docker
                                        sh "docker login -u unused -e none scan.connect.redhat.com -p xldeploy_rhel_token"
                                        // tag and push
                                        sh "docker tag ${imageid} scan.connect.redhat.com/${env.xldeploy_RHEL_registry}/${params.XLProduct}:${xl_LatestVersion}-rhel"
                                        sh "docker push scan.connect.redhat.com/${env.xldeploy_RHEL_registry}/${params.XLProduct}:${xl_LatestVersion}-rhel"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Test Docker Images for XLProducts') {
            parallel {
                stage('Test Docker Images for debian-slim centos amazonlinux') {
                    when {
                         expression { params.Linux == true }
                    }
                    agent {
                            label 'docker_linux'
                    }
                    steps {
                        script {
                            if (params.XLProduct == 'xl-release') {
                                // Run Docker
                                def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 6616:5516 --name ${params.XLProduct} ${params.Registry}/${params.XLProduct}:${xl_LatestVersion}", returnStatus: true)
                                // Result
                                if (status != 0) {
                                    currentBuild.result = 'FAILURE'
                                    error('Docker Image Start FAILED')
                                }
                                // Test if port is up
                                sh "sleep 100"
                                def pstatus = sh (script: "curl localhost:6616", returnStatus: true)
                                // Result
                                if (pstatus != 0) {
                                    currentBuild.result = 'FAILURE'
                                    error('Docker Image Start FAILED')
                                }

                            } else if (params.XLProduct == 'xl-deploy') {
                                // Run Docker
                                def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 5616:4516 --name ${params.XLProduct} ${params.Registry}/${params.XLProduct}:${xl_LatestVersion}", returnStatus: true)
                                // Result
                                if (status != 0) {
                                    currentBuild.result = 'FAILURE'
                                    error('Docker Image Start FAILED')
                                }
                                // Test if port is up
                                sh "sleep 100"
                                def pstatus = sh (script: "curl localhost:5616", returnStatus: true)
                                // Result
                                if (pstatus != 0) {
                                    currentBuild.result = 'FAILURE'
                                    error('Docker Image Start FAILED')
                                }
                            }
                        }
                    }
                }

                stage('Test Docker Images for rhel') {
                    when {
                         expression { params.RHEL == true }
                    }
                    agent {
                            label 'docker_rhel'
                    }
                    steps {
                        withCredentials([string(credentialsId: 'xlr-rhel-token', variable: 'xlr_rhel_token'),
                        string(credentialsId: 'xld-rhel-token', variable: 'xld_rhel_token')]) {
                        script {
                                if (params.XLProduct == 'xl-release') {
                                    // Run Docker
                                    def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 6616:5516 --name ${params.XLProduct} xl-docker.xebialabs.com/${params.XLProduct}:${xl_LatestVersion}-rhel", returnStatus: true)
                                    // Check Result
                                    if (status != 0) {
                                        currentBuild.result = 'FAILURE'
                                        error('Docker Image Start FAILED')
                                    }
                                    // Test if port is up
                                    sh "sleep 100"
                                    def pstatus = sh (script: "curl localhost:6616", returnStatus: true)
                                    // Result
                                    if (pstatus != 0) {
                                        currentBuild.result = 'FAILURE'
                                        error('Docker Image Start FAILED')
                                    }

                                } else if (params.XLProduct == 'xl-deploy') {
                                    // Run Docker
                                    def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 5616:4516 --name ${params.XLProduct} xl-docker.xebialabs.com/${params.XLProduct}:${xl_LatestVersion}-rhel", returnStatus: true)
                                    // Check Result
                                    if (status != 0) {
                                        currentBuild.result = 'FAILURE'
                                        error('Docker Image Start FAILED')
                                    }
                                    // Test if port is up
                                    sh "sleep 100"
                                    def pstatus = sh (script: "curl localhost:5616", returnStatus: true)
                                    // Result
                                    if (pstatus != 0) {
                                        currentBuild.result = 'FAILURE'
                                        error('Docker Image Start FAILED')
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend color: "good", tokenCredentialId: "slack-token", message: "XL Official Docker Images build *SUCCESS* - <${env.BUILD_URL}|click to open>", channel: 'team-kube-love'
                }
            }
        }
        failure {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend color: "danger", tokenCredentialId: "slack-token", message: "XL Official Docker Images build *FAILED* - <${env.BUILD_URL}|click to open>", channel: 'team-kube-love'
                }
            }
        }
    }
}

def getLatestVersion() {
    if (params.Version == '') {
        withCredentials([usernamePassword(credentialsId: 'nexus_credentials', passwordVariable: 'nexus_pass', usernameVariable: 'nexus_user')]) {
            // Get latest version
            script {
                if (params.XLProduct == 'xl-release') {

                    def xl_Version = sh(script: 'curl -su ${nexus_user}:${nexus_pass} https://nexus.xebialabs.com/nexus/service/local/repositories/alphas/content/com/xebialabs/xlrelease/xl-release/maven-metadata.xml | grep "<version>" | cut -d ">" -f 2 | cut -d "<" -f 1 | tail -1', returnStdout: true).trim()

                    writeFile (file: "${env.WORKSPACE}/${params.XLProduct}-latest", text: "${xl_Version}")
                    xl_LatestVersion = readFile "${env.WORKSPACE}/${params.XLProduct}-latest"


                } else if (params.XLProduct == 'xl-deploy') {

                    def xl_Version = sh(script: 'curl -su ${nexus_user}:${nexus_pass} https://nexus.xebialabs.com/nexus/service/local/repositories/alphas/content/com/xebialabs/deployit/xl-deploy/maven-metadata.xml | grep "<version>" | cut -d ">" -f 2 | cut -d "<" -f 1 | tail -1', returnStdout: true).trim()

                    writeFile (file: "${env.WORKSPACE}/${params.XLProduct}-latest", text: "${xl_Version}")
                    xl_LatestVersion = readFile "${env.WORKSPACE}/${params.XLProduct}-latest"

                }
            }
        }
    } else {

        writeFile (file: "${env.WORKSPACE}/${params.XLProduct}-latest", text: "${params.Version}")
        xl_LatestVersion = readFile "${env.WORKSPACE}/${params.XLProduct}-latest"
    }

    return xl_LatestVersion
}

