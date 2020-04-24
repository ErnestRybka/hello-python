properties([
        parameters(
                [
                        stringParam(
                                name: 'VERSION',
                                defaultValue: ''
                        ),
                        choiceParam(
                                name: 'ENV',
                                choices: ['dev', 'prod']
                        )
                ]
        )
])
pipeline {
    agent {
    kubernetes {
      yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-539ddefcae3fd6b411a95982a830d987f4214251
    imagePullPolicy: Always
    resources:
      requests:
        cpu: "256m"
        memory: "256Mi"
    command:
    - cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
  - name: helm
    image: alpine/helm:3.2.0
    imagePullPolicy: Always
    resources:
      requests:
        cpu: "256m"
        memory: "256Mi"
    command: ["cat"]
    tty: true
  volumes:
    - name: docker-config
      configMap:
        name: docker-config
"""
    }
  }
    stages {
        stage('build') {
            steps {
                container('kaniko'){
                    git 'https://github.com/ErnestRybka/hello-python.git'
                    sh "/kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination=rybkaer/test-app:latest --destination=rybkaer/test-app:${params.VERSION}"
                }
            }
        }
        stage('deploy'){
            steps{
                container('helm'){
                    script{
                        if (params.ENV == 'dev'){
                            withCredentials([usernamePassword(credentialsId: 'dev-cred', passwordVariable: 'pass', usernameVariable: 'username')]) {
                                print("${username}:${pass}")
                                sh "chmod 777 -R helm;" +
                                   "./helm/setVersion.sh ${params.VERSION};" +
                                   "helm upgrade hello-python helm/ --install --debug --namespace ${params.ENV} --set registry=rybkaer --set replicas=1"
                            }
                        } else if (params.ENV == 'prod'){
                            withCredentials([usernamePassword(credentialsId: 'prod-cred', passwordVariable: 'pass', usernameVariable: 'username')]) {
                                println("${username}:${pass}")
                                sh "chmod 777 -R helm"
                                sh "./helm/setVersion.sh ${params.VERSION}"
                                sh "helm upgrade hello-python helm/ --install --debug --namespace ${params.ENV} --set registry=rybkaer --set replicas=3"
                            }
                        }
                        sh "helm get manifest hello-python -n ${params.ENV}"
                        
                    }
                }
            }
            
        }
    }
}
