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
                echo "--- 1. Verification (Host): Checking if file exists on host ---"
                // This must succeed. If it fails, SCM checkout is the problem.
                sh 'ls -al ./test-plans/api-performance.jmx'

                echo "--- 2. Permission Fix (Host): Granting all users read access ---"
                // Fix permissions on host before mounting
                sh 'chmod -R a+rX ./test-plans'
                
                // --- THE CRITICAL FIX: EXPLICITLY PASSING WORKSPACE ---
                echo "--- 3. Execution: Setting absolute path and running docker compose ---"
                
                // This multi-line step is the most reliable way to inject the absolute path.
                sh '''
                    # 3a. Set the absolute path variable for docker-compose substitution
                    export JENKINS_WORKSPACE_PATH="${WORKSPACE}"
                    
                    # 3b. Run build and start the test container. 
                    # The YAML (must be updated) will use ${JENKINS_WORKSPACE_PATH}
                    docker compose build jmeter-master
                    docker compose up --build --exit-code-from jmeter-master
                '''
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