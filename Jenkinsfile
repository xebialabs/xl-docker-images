#!groovy
@Library('jenkins-pipeline-libs@master')
import java.lang.Object

pipeline {
    agent none

    parameters {
        choice(
                name: 'product',
                choices: ['all', 'xl-client', 'xl-release', 'xl-deploy', 'deploy-task-engine', 'central-configuration'],
                description: 'Select the product you want to generate docker image for (not all)')
        string(
                name: 'version',
                defaultValue: '',
                description: "Version of the product you want to create Docker Images for (leave empty for latest)")
        string(
                name: 'branch',
                defaultValue: 'master',
                description: "Git branch to build from")
        choice(
                name: 'targetOs',
                choices: ['all', 'ubuntu', 'redhat'],
                description: "Target OS for docker images (ignored for xl-client which uses alpine only)")
        choice(
                name: 'releaseType',
                choices: ['nightly', 'final'],
                description: "Type of Release if it is nightly or final. Dockerfiles will be committed only for final releases to xebialabs registry.")
        choice(
                name: 'registry',
                choices: ['xebialabsunsupported', 'xebialabs', 'xebialabsearlyaccess'],
                description: "Docker registry where docker images will be pushed to")
        booleanParam(
                name: 'pushImages',
                defaultValue: false,
                description: "Whether to push images to registry (Disabled for PR builds)")
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20', artifactDaysToKeepStr: '7', artifactNumToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        ansiColor('xterm')
    }

    environment {
        NEXUS_CRED = credentials('nexus-ci')
    }

    stages {

        stage('Determine Product Version') {
            agent any
            steps {
                script {
                    def products = productsAsList()

                    products.each { product ->
                        def version = getLatestVersion(product)
                        setEnvProductVersion(product, version)
                    }
                }
            }
        }

        stage('Rendering and Build Docker Images for Products') {
            when {
                expression {
                    (params.targetOs == 'all' || params.targetOs in ['ubuntu', 'redhat'])
                }
            }
            agent {
                label 'docker_linux'
            }
            steps {
                // Clean old workspace
                step([$class: 'WsCleanup'])

                // Checkout from specified branch
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${params.branch}"]],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])

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
                    def products = productsAsList()

                    products.each { currentProduct ->
                        echo "Processing product: ${currentProduct}"
                        def productVersion = getEnvProductVersion(currentProduct)
                        def targetOsList = getTargetOsList(params.targetOs, currentProduct)

                        // Add --commit flag only for final releases to xebialabs registry
                        def commitFlag = ((params.releaseType == "final") && (params.registry == "xebialabs")) ? '--commit' : ''
                        sh "pipenv run ./applejack.py render --xl-version ${productVersion} --product ${currentProduct} --registry ${params.registry} ${commitFlag}"

                        // Build Docker Image
                        def pushFlag = params.pushImages ? '--push' : ''
                        def targetOsArgs = (currentProduct == 'xl-client') ? '--target-os alpine' : targetOsList.collect { "--target-os ${it}" }.join(' ')
                        sh "pipenv run ./applejack.py build --xl-version ${productVersion} --download-source nexus --download-username \${NEXUS_CRED_USR} --download-password \${NEXUS_CRED_PSW} --product ${currentProduct} ${targetOsArgs} ${pushFlag} --registry ${params.registry}"
                    }
                }
                script {
                    cleanWs()
                }
            }
        }

        stage('Test Docker Images') {
            parallel {
                stage('Test Docker Images for Ubuntu') {
                    when {
                        expression {
                            (params.targetOs == 'all' || params.targetOs == 'ubuntu')
                        }
                    }
                    agent {
                        label 'docker_linux'
                    }
                    steps {
                        script {
                            def products = productsAsList()

                            products.each { currentProduct ->
                                echo "Testing ${currentProduct} on Ubuntu"
                                def productVersion = getEnvProductVersion(currentProduct)
                                testDockerImage(currentProduct, productVersion, params.registry, 'ubuntu')
                            }
                        }
                        script {
                            cleanWs()
                        }
                    }
                }

                stage('Test Docker Images for Redhat') {
                    when {
                        expression {
                            (params.targetOs == 'all' || params.targetOs == 'redhat')
                        }
                    }
                    agent {
                        label 'docker_linux'
                    }
                    steps {
                        script {
                            def products = productsAsList()

                            products.each { currentProduct ->
                                echo "Testing ${currentProduct} on RedHat"
                                def productVersion = getEnvProductVersion(currentProduct)
                                testDockerImage(currentProduct, productVersion, params.registry, 'redhat')
                            }
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

def productsAsList() {
    return (params.product == 'all') ?
        ['xl-client', 'xl-release', 'xl-deploy', 'deploy-task-engine', 'central-configuration'] :
        [params.product]
}

/**
 * Sets the product version in environment variables.
 * Uses naming convention: env.{PRODUCT_NAME}_VERSION
 *
 * @param xl_product The product name (e.g., 'xl-deploy', 'xl-release')
 * @param version The version to store
 */
def setEnvProductVersion(xl_product, version) {
    def envVarName = "${xl_product.replace('-', '_').toUpperCase()}_VERSION"
    env."${envVarName}" = version
    echo "Set environment variable ${envVarName} = ${version}"
}

/**
 * Retrieves the product version from environment variables.
 * Uses naming convention: env.{PRODUCT_NAME}_VERSION
 * 
 * @param xl_product The product name (e.g., 'xl-deploy', 'xl-release')
 * @return The version string from environment variables
 */
def getEnvProductVersion(xl_product) {
    def envVarName = "${xl_product.replace('-', '_').toUpperCase()}_VERSION"
    def version = env."${envVarName}"

    if (!version) {
        error("No version found for product ${xl_product}. Expected environment variable: ${envVarName}")
    }

    return version
}

/**
 * Determines product version - uses specified version, fetches latest if no version specified,
 * or fetches latest version corresponding to PR builds.
 *
 * @return The resolved product version string
 */
def getLatestVersion(xl_product) {
    script {
        // Use provided version first incase of pipeline job with build parameters
        if (params.version != '') {
            echo "Using explicitly provided version: ${params.version}"
            return params.version
        }

        // Determine target branch (PR target branch or build branch parameter)
        def targetBranch = env.CHANGE_TARGET ?: env.ghprbTargetBranch ?: params.branch

        def groupId = getGroupId(xl_product)
        def artifactId = getArtifactId(xl_product)
        def versionPattern = getVersionForNexusSearch(targetBranch)

        def productVersion = getLatestVersionFromNexus(groupId, artifactId, versionPattern)

        if (!productVersion) {
            error("No version found for ${xl_product} corresponding to branch ${targetBranch}. Cannot proceed with build.")
        }

        echo "Selected version ${productVersion} for ${xl_product} targeting branch ${targetBranch}"
        return productVersion
    }
}

/**
 * Determines the specific major.minor version to form search url.
 *
 * Returns branch name for maintenance branch (e.g. "25.3").
 * Returns null for master/other branches to get latest available version.
 */
def getVersionForNexusSearch(targetBranch) {
    return (targetBranch ==~ /^\d+\.\d+$/) ? targetBranch : null
}

/**
* Fetches the latest version from Nexus for given groupId, artifactId, and optional version pattern.
*/
def getLatestVersionFromNexus(groupId, artifactId, versionPattern) {
    def searchUrl = "https://nexus.xebialabs.com/nexus/service/local/lucene/search?g=${groupId}&a=${artifactId}"

    if (versionPattern) {
        searchUrl += "&v=${versionPattern}*"
        echo "Searching for versions matching: ${versionPattern}.*"
    }

    def versionCmd = """
        curl -su \${NEXUS_CRED} '${searchUrl}' 2>/dev/null | \\
        grep -o '<version>[^<]*</version>' | \\
        sed 's/<version>\\(.*\\)<\\/version>/\\1/' | \\
        sort -V | \\
        tail -1
    """

    def version = sh(script: versionCmd, returnStdout: true).trim()

    return version
}

def getGroupId(xl_product) {
    switch(xl_product) {
        case 'xl-client':
            return 'com.xebialabs.xlclient'
        case 'xl-release':
            return 'com.xebialabs.xlrelease'
        case 'xl-deploy':
            return 'com.xebialabs.deployit'
        case 'central-configuration':
            return 'ai.digital.config'
        case 'deploy-task-engine':
            return 'com.xebialabs.deployit'
        default:
            error("Unknown product: ${xl_product}")
    }
}

def getArtifactId(xl_product) {
    switch(xl_product) {
        case 'xl-client':
            return 'xl-client'
        case 'xl-release':
            return 'xl-release'
        case 'xl-deploy':
            return 'xl-deploy'
        case 'central-configuration':
            return 'central-configuration-server'
        case 'deploy-task-engine':
            return 'xl-deploy'  // Uses same artifact as xl-deploy
        default:
            error("Unknown product: ${xl_product}")
    }
}

def getTargetOsList(target_os, product) {
    def osList = []

    if (target_os == 'all') {
        if (product == 'xl-client') {
            osList = ['alpine']
        } else {
            osList = ['ubuntu', 'redhat']
        }
    } else if (target_os in ['ubuntu', 'redhat']) {
        osList = [target_os]
    }

    return osList
}

def testDockerImage(product, productVersion, registry, targetOs) {
    // Get product-specific test configuration
    def config = getProductTestConfig(product, productVersion, registry, targetOs)

    if (config.dockerCmd) {
        // Run Docker container
        def status = sh(script: config.dockerCmd, returnStatus: true)

        // Check if container started successfully
        if (status != 0) {
            currentBuild.result = 'FAILURE'
            error("Docker container failed to start: ${registry}/${product}:${productVersion}-${targetOs}")
        }

        // Wait for service to be ready and test if accessible (if test URL provided)
        if (config.testUrl) {
            def initialWait = 30 // seconds
            sh "sleep ${initialWait}"

            def retryCount = 7
            def retryInterval = 10 // seconds
            def totalWaitTime = initialWait

            while (retryCount > 0) {
                def success = sh(script: "curl -s ${config.testUrl} > /dev/null 2>&1", returnStatus: true) == 0

                // Check if service is accessible
                if (success) {
                    echo "Service is accessible after ${totalWaitTime} seconds"
                    break
                } else {
                    retryCount--
                    sh "sleep ${retryInterval}"
                    totalWaitTime += retryInterval
                }
            }

            // Check if service is accessible
            if (retryCount == 0) {
                currentBuild.result = 'FAILURE'
                error("Service is not accessible in container: ${registry}/${product}:${productVersion}-${targetOs}")
            }
        }
    }
}

/**
 * Provides the configuration to test for given product viz. docker command and test URL
 * @return Map containing 'dockerCmd' and 'testUrl' keys
 */
def getProductTestConfig(product, productVersion, registry, targetOs) {
    def config = [:]
    def imageSuffix = (targetOs == 'redhat') ? '-redhat' : ''
    def portOffset = (targetOs == 'redhat') ? 1 : 0  // Add 1 to port for redhat to avoid conflicts

    switch(product) {
        case 'xl-release':
            def hostPort = 6616 + portOffset
            config.dockerCmd = "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p ${hostPort}:5516 --name xl-release-${targetOs} ${registry}/xl-release:${productVersion}${imageSuffix}"
            config.testUrl = "localhost:${hostPort}"
            break
        case 'xl-deploy':
            def hostPort = 5616 + portOffset
            config.dockerCmd = "docker run -d -e ADMIN_PASSWORD=admin -e ACCEPT_EULA=Y -p ${hostPort}:4516 --name xl-deploy-${targetOs} ${registry}/xl-deploy:${productVersion}${imageSuffix}"
            config.testUrl = "localhost:${hostPort}"
            break
        case 'central-configuration':
            def hostPort = 8888 + portOffset
            config.dockerCmd = "docker run -d -p ${hostPort}:8888 --name central-configuration-${targetOs} ${registry}/central-configuration:${productVersion}${imageSuffix}"
            config.testUrl = "localhost:${hostPort}"
            break
        case 'deploy-task-engine':
            def hostPort = 9180 + portOffset
            config.dockerCmd = "docker run -d -p ${hostPort}:8180 --name deploy-task-engine-${targetOs} ${registry}/deploy-task-engine:${productVersion}${imageSuffix}"
            config.testUrl = null // No URL test for this product
            break
        default:
            config.dockerCmd = null
            config.testUrl = null
    }

    return config
}
