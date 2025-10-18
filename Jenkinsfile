pipeline {
    agent any

    environment {
        COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        stage('Checkout') {
            steps {
                // If Jenkins has your code in GitHub or GitLab
                // you can enable this, otherwise skip it
                git url: 'https://github.com/santiabo17/aboal-santiago-tarea-5-jenkins', branch: 'master'
                echo "Starting pipeline..."
            }
        }

        stage('Build JMeter image') {
            steps {
                sh 'docker compose build jmeter-master'
            }
        }

        stage('Run JMeter tests') {
            steps {
                echo "--- 3. ADVANCED DEBUG: Checking permissions INSIDE the container ---"
        
                // Use '--entrypoint sh' to override JMeter and run a shell instead.
                sh "docker compose run --rm --entrypoint sh jmeter-master -c 'ls -al /test-plans/ && whoami'"
                
                echo "--- 1. Verification: Checking host path './test-plans' ---"
                sh 'ls -al ./test-plans/api-performance.jmx'
                
                echo "--- 2. Permission Fix: Ensuring container can read files ---"
                sh 'chmod -R a+rX ./test-plans'
            
                // Runs your JMeter container, executes the tests, and exits
                sh 'docker compose up --build --exit-code-from jmeter-master'
            }
        }

        stage('Collect Results') {
            steps {
                // Example of saving results
                sh 'ls -l ./test-results || echo "No results found"'
                archiveArtifacts artifacts: 'test-results/**', fingerprint: true
            }
        }
    }

    post {
        always {
            // Clean up containers after run
            sh 'docker compose down'
        }
    }
}