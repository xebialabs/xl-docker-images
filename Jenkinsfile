#!groovy

@Library('jenkins-pipeline-libs@master')
import com.xebialabs.pipeline.utils.Branches
import groovy.transform.Field

def xlr_LatestVersion = ""
def xld_LatestVersion = ""
def xlclient_LatestVersion = ""

pipeline {
    agent none

    parameters {
        booleanParam(
            name: 'xl_release',
            defaultValue: true,
            description: 'Specifies if you want to generate Docker Image for XLRelease')
        string(
            name: 'xlr_version',
            defaultValue: '',
            description: "Version of XL Release you want to create Docker Images for")
        booleanParam(
            name: 'xl_deploy',
            defaultValue: true,
            description: 'Specifies if you want to generate Docker Image for XLDeploy')
        string(
            name: 'xld_version',
            defaultValue: '',
            description: "Version of XL Deploy you want to create Docker Images for")
         booleanParam(
            name: 'xl_client',
            defaultValue: true,
            description: 'Specifies if you want to generate Docker Image for XLClient')
        string(
            name: 'xlclient_version',
            defaultValue: '',
            description: "Version of XL Client you want to create Docker Images for")
        booleanParam(
            name: 'Linux',
            defaultValue: true,
            description: 'Specifies if Target OS is "Debian-slim, CentOS, Amazon" which defines what tags will be generated')
        booleanParam(
            name: 'RHEL',
            defaultValue: false,
            description: 'Specifies if Target OS is "RHEL" which defines what tags will be generated')
        choice(
            name: 'ReleaseType',
            choices: ['nightly', 'final'],
            description: "Type of Release if it is nightly or final")
        choice(
            name: 'Registry',
            choices: ['xl-docker.xebialabs.com', 'xebialabs', 'xebialabsunsupported', 'xebialabsearlyaccess'],
            description: "Docker Registry you want to push non RHEL Docker Images to")
        booleanParam(
            name: 'TestXLUP',
            defaultValue: false,
            description: 'Specifies if We need to test new docker images with xlup or not')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20', artifactDaysToKeepStr: '7', artifactNumToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        ansiColor('xterm')
    }

    environment {
        xlrelease_RHEL_registry_url = 'p762626407e78baea07bf3901fb89bdaf24e2db505'
        xldeploy_RHEL_registry_url = 'p213351287537b1081d854572a246c48cdf8f9d5585'
        DIST_SERVER_CRED = credentials('distserver')
        NEXUS_CRED = credentials('nexus-ci')
        XLR_RHEL_TOKEN = credentials('xlr-rhel-token')
        XLD_RHEL_TOKEN = credentials('xld-rhel-token')
        SEED_VERSION = '9.6.1-alpha.4'
    }

    stages {

        stage('Rendering and Build Docker Images for XLProducts') {
            parallel {
                stage('Rendering and Build Docker Images for debian-slim alpine centos amazonlinux') {
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

                            if (params.xl_release == true) {

                                xlr_LatestVersion = getLatestVersion("xl_release")

                                if ((params.ReleaseType == "final") && (params.Registry == "xebialabs")) {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlr_LatestVersion} --product xl-release --registry ${params.Registry} --commit"
                                } else {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlr_LatestVersion} --product xl-release --registry ${params.Registry}"
                                }

                                // Build Docker Image and push it
                                sh "pipenv run ./applejack.py build --xl-version ${xlr_LatestVersion} --download-source nexus --download-username ${NEXUS_CRED_USR} --download-password ${NEXUS_CRED_PSW}  --product xl-release  --target-os debian-slim --target-os centos --target-os amazonlinux --push --registry ${params.Registry}"
                            }

                            if (params.xl_deploy == true) {

                                xld_LatestVersion = getLatestVersion("xl_deploy")

                                if ((params.ReleaseType == "final") && (params.Registry == "xebialabs")) {
                                    sh "pipenv run ./applejack.py render --xl-version ${xld_LatestVersion} --product xl-deploy --registry ${params.Registry} --commit"
                                } else {
                                    sh "pipenv run ./applejack.py render --xl-version ${xld_LatestVersion} --product xl-deploy --registry ${params.Registry}"
                                }

                                // Build Docker Image and push it
                                sh "pipenv run ./applejack.py build --xl-version ${xld_LatestVersion} --download-source nexus --download-username ${NEXUS_CRED_USR} --download-password ${NEXUS_CRED_PSW}  --product xl-deploy  --target-os debian-slim --target-os centos --target-os amazonlinux --push --registry ${params.Registry}"
                            }                        
                            if (params.xl_client == true) {

                                xlclient_LatestVersion = getLatestVersion("xl_client")

                                if ((params.ReleaseType == "final") && (params.Registry == "xebialabsunsupported")) {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlclient_LatestVersion} --product xl-client --registry ${params.Registry}"
                                } else {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlclient_LatestVersion} --product xl-client --registry ${params.Registry} --commit"
                                }

                                // Build Docker Image and push it
                                sh "pipenv run ./applejack.py build --xl-version ${xlclient_LatestVersion} --download-source nexus --download-username ${NEXUS_CRED_USR} --download-password ${NEXUS_CRED_PSW}  --product xl-client  --target-os alpine --target-os debian-slim --target-os centos --target-os amazonlinux --push --registry ${params.Registry}"
                                
                            }

                        }
                        script {
                            cleanWs()
                        }
                    }
                }

                stage('Rendering and Build Docker Images for rhel') {
                    when {
                         expression { params.RHEL == true }
                    }
                    agent {
                            label 'xl-client'
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

                            if (params.xl_release == true) {

                                xlr_LatestVersion = getLatestVersion("xl_release")

                                if (params.ReleaseType == "final") {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlr_LatestVersion} --product xl-release --commit"
                                } else {
                                    sh "pipenv run ./applejack.py render --xl-version ${xlr_LatestVersion} --product xl-release"
                                }

                                // build docker images and push it to internal docker registry
                                sh "pipenv run ./applejack.py build --xl-version ${xlr_LatestVersion} --download-source nexus --download-username ${NEXUS_CRED_USR} --download-password ${NEXUS_CRED_PSW}  --product xl-release  --target-os rhel --push --registry xl-docker.xebialabs.com"

                                if (params.ReleaseType == "final") {
                                    // push to redhat resgistry
                                    def imageid = sh(script: "docker images | grep xl-release | grep ${xlr_LatestVersion} | awk -e '{print \$3}'", returnStdout: true).trim()
                                    // Login to rhel Docker
                                    sh "docker login -u unused -e none scan.connect.redhat.com -p ${XLR_RHEL_TOKEN}"
                                    // tag and push
                                    sh "docker tag ${imageid} scan.connect.redhat.com/${env.xlrelease_RHEL_registry_url}/xl-release:${xlr_LatestVersion}-rhel"
                                    sh "docker push scan.connect.redhat.com/${env.xlrelease_RHEL_registry_url}/xl-release:${xlr_LatestVersion}-rhel"
                                }
                            }

                            if (params.xl_deploy == true) {

                                xld_LatestVersion = getLatestVersion("xl_deploy")

                                if (params.ReleaseType == "final") {
                                    sh "pipenv run ./applejack.py render --xl-version ${xld_LatestVersion} --product xl-deploy --commit"
                                } else {
                                    sh "pipenv run ./applejack.py render --xl-version ${xld_LatestVersion} --product xl-deploy"
                                }

                                // build docker images and push it to internal docker registry
                                sh "pipenv run ./applejack.py build --xl-version ${xld_LatestVersion} --download-source nexus --download-username ${NEXUS_CRED_USR} --download-password ${NEXUS_CRED_PSW}  --product xl-deploy  --target-os rhel --push --registry xl-docker.xebialabs.com"

                                if (params.ReleaseType == "final") {
                                    // push to redhat resgistry
                                    def imageid = sh(script: "docker images | grep xl-deploy | grep ${xld_LatestVersion} | awk -e '{print \$3}'", returnStdout: true).trim()
                                    // Login to rhel Docker
                                    sh "docker login -u unused -e none scan.connect.redhat.com -p ${XLD_RHEL_TOKEN}"
                                    // tag and push
                                    sh "docker tag ${imageid} scan.connect.redhat.com/${env.xldeploy_RHEL_registry_url}/xl-deploy:${xld_LatestVersion}-rhel"
                                    sh "docker push scan.connect.redhat.com/${env.xldeploy_RHEL_registry_url}/xl-deploy:${xld_LatestVersion}-rhel"
                                }
                            }
                        }
                        script {
                            cleanWs()
                        }
                    }
                }
            }
        }

        stage('Test Docker Images for XLProducts') {
            parallel {
                stage('Test Docker Images for debian-slim') {
                    when {
                         expression { params.Linux == true }
                    }
                    agent {
                            label 'xl-client'
                    }
                    steps {
                        script {
                            if (params.xl_release == true) {
                                // Run Docker
                                def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 6616:5516 --name xl-release ${params.Registry}/xl-release:${xlr_LatestVersion}", returnStatus: true)
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

                            } else if (params.xl_deploy == true) {
                                // Run Docker
                                def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 5616:4516 --name xl-deploy ${params.Registry}/xl-deploy:${xld_LatestVersion}", returnStatus: true)
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
                        script {
                            cleanWs()
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
                                if (params.xl_release == true) {
                                    // Run Docker
                                    def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 6616:5516 --name xl-release xl-docker.xebialabs.com/xl-release:${xlr_LatestVersion}-rhel", returnStatus: true)
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

                                }

                                if (params.xl_deploy == true) {
                                    // Run Docker
                                    def status = sh (script: "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p 5616:4516 --name xl-deploy xl-docker.xebialabs.com/xl-deploy:${xld_LatestVersion}-rhel", returnStatus: true)
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
                            script{
                                cleanWs()
                            }
                        }
                    }
                }

                stage('Test XLUP with New Docker Images for debian-slim') {
                    when {
                         expression {
                            params.Linux == true && params.TestXLUP == true
                         }
                    }
                    agent {
                            label 'docker_minikube'
                    }
                    steps {
                        // Clean old workspace
                        step([$class: 'WsCleanup'])
                        checkout scm

                        script {

                            runXlUpOnMiniKube()

                        }
                        script {
                            cleanWs()
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
                    slackSend color: "good", tokenCredentialId: "slack-token", message: "XL Official Docker Images build *SUCCESS* - <${env.BUILD_URL}|click to open>", channel: 'docker-images-release'
                }
            }
        }
        failure {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend color: "danger", tokenCredentialId: "slack-token", message: "XL Official Docker Images build *FAILED* - <${env.BUILD_URL}|click to open>", channel: 'docker-images-release'
                }
            }
        }
    }
}

def getLatestVersion(xl_product) {
    script {
        if (xl_product == 'xl_release') {
            if (params.xlr_version == '') {

                def xlr_Version = sh(script: 'curl -su ${NEXUS_CRED} https://nexus.xebialabs.com/nexus/service/local/repositories/releases/content/com/xebialabs/xlrelease/xl-release/maven-metadata.xml | grep "<version>" | cut -d ">" -f 2 | cut -d "<" -f 1 | sort -n | tail -1', returnStdout: true).trim()

                writeFile (file: "${env.WORKSPACE}/xl-release-latest", text: "${xlr_Version}")
                xlr_LatestVersion = readFile "${env.WORKSPACE}/xl-release-latest"

            } else {

                writeFile (file: "${env.WORKSPACE}/xl-release-latest", text: "${params.xlr_version}")
                xlr_LatestVersion = readFile "${env.WORKSPACE}/xl-release-latest"

            }
            return xlr_LatestVersion

        }
        if (xl_product == 'xl_deploy') {
            if (params.xld_version == '') {

                def xld_Version = sh(script: 'curl -su ${NEXUS_CRED} https://nexus.xebialabs.com/nexus/service/local/repositories/releases/content/com/xebialabs/deployit/xl-deploy/maven-metadata.xml | grep "<version>" | cut -d ">" -f 2 | cut -d "<" -f 1 | sort -n | tail -1', returnStdout: true).trim()

                writeFile (file: "${env.WORKSPACE}/xl-deploy-latest", text: "${xld_Version}")
                xld_LatestVersion = readFile "${env.WORKSPACE}/xl-deploy-latest"

            } else {

                writeFile (file: "${env.WORKSPACE}/xl-deploy-latest", text: "${params.xld_version}")
                xld_LatestVersion = readFile "${env.WORKSPACE}/xl-deploy-latest"

            }
            return xld_LatestVersion
        }
        
        if (xl_product == 'xl_client') {
            if (params.xlclient_version == '') {

                def xlclient_version = sh(script: 'curl -su ${NEXUS_CRED} https://nexus.xebialabs.com/nexus/service/local/repositories/releases/content/com/xebialabs/xlclient/xl-client/maven-metadata.xml | grep "<version>" | cut -d ">" -f 2 | cut -d "<" -f 1 | sort -n | tail -1', returnStdout: true).trim()

                writeFile (file: "${env.WORKSPACE}/xl-client-latest", text: "${xlclient_version}")
                xlclient_LatestVersion = readFile "${env.WORKSPACE}/xl-client-latest"
        
            } else {

                writeFile (file: "${env.WORKSPACE}/xl-client-latest", text: "${params.xlclient_version}")
                xlclient_LatestVersion = readFile "${env.WORKSPACE}/xl-client-latest"
            

            }
            return xlclient_LatestVersion
        }
    }
}

def runXlUpOnMiniKube() {

    sh "git clone git@github.com:xebialabs/xl-up-blueprint.git"

    sh """
        sudo cat  /root/.minikube/client.crt > xlup/k8sClientCert-minikube-tmp.crt
        sudo tr ' ' '\\n' < xlup/k8sClientCert-minikube-tmp.crt > xlup/k8sClientCert-minikube-tmp2.crt
        sudo tr '%' ' ' < xlup/k8sClientCert-minikube-tmp2.crt > xlup/k8sClientCert-minikube.crt
        sudo rm -f xlup/k8sClientCert-minikube-tmp.crt | rm -f xlup/k8sClientCert-minikube-tmp2.crt
    """

    sh """
        sudo cat  /root/.minikube/client.key > xlup/k8sClientCert-minikube-tmp.key
        sudo tr ' ' '\\n' < xlup/k8sClientCert-minikube-tmp.key > xlup/k8sClientCert-minikube-tmp2.key
        sudo tr '%' ' ' < xlup/k8sClientCert-minikube-tmp2.key > xlup/k8sClientCert-minikube.key
        sudo rm -f xlup/k8sClientCert-minikube-tmp.key | rm -f xlup/k8sClientCert-minikube-tmp2.key
    """

    def minikube_host = sh(script: 'hostname -f', returnStdout: true).trim()

    sh "sed -ie 's@k8s.com@${minikube_host}@g' xlup/xl_generated_answers.yaml"
    sh "sed -ie 's@K8sClientCertFile: cert-temp-file@K8sClientCertFile: xlup/k8sClientCert-minikube.crt@g' xlup/xl_generated_answers.yaml"
    sh "sed -ie 's@K8sClientKeyFile: key-temp-file@K8sClientKeyFile: xlup/k8sClientCert-minikube.key@g' xlup/xl_generated_answers.yaml"
    sh "sed -ie 's@XlKeyStore: repository-keystore-temp@XlKeyStore: xlup/repository-keystore.jceks@g' xlup/xl_generated_answers.yaml"
    // create empty files for lic as answer file always validate it.
    sh "touch xlrelease-temp-license  xldeploy-temp-license"

    if ((params.xl_release == true) && (params.xl_deploy == false)) {

        sh "curl https://dist.xebialabs.com/customer/licenses/download/v3/xl-release-license.lic -u ${DIST_SERVER_CRED} -o xlup/xl-release.lic"
        sh "sed -ie 's@InstallXLR: false@InstallXLR: true@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XlrLic: xlrelease-temp-license@XlrLic: xlup/xl-release.lic@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XlrVersion: xl-release:0.0.0@XlrVersion: xl-release:${xlr_LatestVersion}@g' xlup/xl_generated_answers.yaml"

    }

    if ((params.xl_release == false) && (params.xl_deploy == true)) {

        sh "curl https://dist.xebialabs.com/customer/licenses/download/v3/deployit-license.lic -u ${DIST_SERVER_CRED} -o xlup/xl-deploy.lic"
        sh "sed -ie 's@InstallXLD: false@InstallXLD: true@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XldLic: xldeploy-temp-license@XldLic: xlup/xl-deploy.lic@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XldVersion: xl-deploy:0.0.0@XldVersion: xl-deploy:${xld_LatestVersion}@g' xlup/xl_generated_answers.yaml"

    }

    if ((params.xl_release == true) && (params.xl_deploy == true)){

        sh "curl https://dist.xebialabs.com/customer/licenses/download/v3/xl-release-license.lic -u ${DIST_SERVER_CRED} -o xlup/xl-release.lic"
        sh "sed -ie 's@InstallXLR: false@InstallXLR: true@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XlrLic: xlrelease-temp-license@XlrLic: xlup/xl-release.lic@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XlrVersion: xl-release:0.0.0@XlrVersion: xl-release:${xlr_LatestVersion}@g' xlup/xl_generated_answers.yaml"

        sh "curl https://dist.xebialabs.com/customer/licenses/download/v3/deployit-license.lic -u ${DIST_SERVER_CRED} -o xlup/xl-deploy.lic"
        sh "sed -ie 's@InstallXLD: false@InstallXLD: true@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XldLic: xldeploy-temp-license@XldLic: xlup/xl-deploy.lic@g' xlup/xl_generated_answers.yaml"
        sh "sed -ie 's@XldVersion: xl-deploy:0.0.0@XldVersion: xl-deploy:${xld_LatestVersion}@g' xlup/xl_generated_answers.yaml"

    }

    sh "sudo /opt/xl up -a xlup/xl_generated_answers.yaml -b xl-infra -l xl-up-blueprint --seed-version ${SEED_VERSION} --undeploy --skip-prompts"
    sh "sudo /opt/xl up -a xlup/xl_generated_answers.yaml -b xl-infra -l xl-up-blueprint --seed-version ${SEED_VERSION} --skip-prompts"
    sh "sudo /opt/xl up -a xlup/xl_generated_answers.yaml -b xl-infra -l xl-up-blueprint --seed-version ${SEED_VERSION} --undeploy --skip-prompts"
}
