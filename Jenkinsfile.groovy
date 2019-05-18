server = Artifactory.server "artifactory"
rtFullUrl = server.url
rtIpAddress = rtFullUrl - ~/^http?.:\/\// - ~/\/artifactory$/

buildInfo = Artifactory.newBuildInfo()

setNewProps();

podTemplate(label: 'jenkins-pipeline' , cloud: 'k8s' , containers: [
        containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true , privileged: true)],
        volumes: [hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')]) {

    node('jenkins-pipeline') {

        stage('Cleanup') {
            cleanWs()
        }

        stage('Clone sources') {
            git url: 'https://github.com/eladh/jfrog-data-generator', credentialsId: 'github'
        }

        stage('Docker build') {
            def rtDocker = Artifactory.docker server: server

            container('docker') {
                for (packageType in [ 'npm', 'maven', 'generic' ]) {
                    docker.withRegistry("https://docker.$rtIpAddress", 'artifactorypass') {
                        sh("chmod 777 /var/run/docker.sock")
                        sh("cp -rf shared/* $packageType/. ")
                        def dockerImageTag = "docker.$rtIpAddress/$packageType:${env.BUILD_NUMBER}"

                        buildInfo.env.capture = true
                        docker.build(dockerImageTag, "--build-arg DOCKER_REGISTRY_URL=docker.$rtIpAddress .")

                        rtDocker.push(dockerImageTag, "docker-local", buildInfo)
                        server.publishBuildInfo buildInfo
                    }
                }
            }
        }
    }
}


void setNewProps() {
    if  (params.XRAY_SCAN == null) {
        properties([parameters([string(name: 'XRAY_SCAN', defaultValue: 'NO')])])
        currentBuild.result = 'SUCCESS'
        error('Aborting the build to generate params')
    }
}