pipeline {
    agent any

    environment {
        // Define key variables used in the script
        JMETER_IMAGE = 'justb4/jmeter:latest' // Or your image name
        JMETER_CONTAINER_NAME = "jmeter-performance-${BUILD_NUMBER}"
        TEST_PLAN_DIR = 'test-plans'
        RESULTS_DIR = 'results'
        
        TEST_PLAN_FILE = 'api-performance.jmx' 
        
        OUT_DIR = "${WORKSPACE}/${RESULTS_DIR}"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/santiabo17/aboal-santiago-tarea-5-jenkins', branch: 'master'
                echo "Code checked out to: ${WORKSPACE}"
            }
        }
        
        // stage('Run Performance Tests') {
        //     steps {
        //         sh """
        //             echo "=== Starting JMeter Performance Tests ==="

        //             # Clean old results
        //             rm -rf results/*
                    
        //             # Run JMeter using docker-compose
        //             docker-compose run --rm jmeter-master \
        //             -n -t /test-plans/api-performance.jmx \
        //             -l /results/results.jtl \
        //             -e -o /results/html-report \
        //             -Jthreads=50 -Jrampup=120 -Jbase.url=httpbin.org \
        //             -f

        //             # Verify results
        //             if [ ! -f results/results.jtl ]; then
        //                 echo "ERROR: No results generated!"
        //                 exit 1
        //             fi
        //         """
        //     }
        // }

        stage('Run Performance Tests (Docker CP Method)') {
            steps {
                sh """
                    echo "=== Starting JMeter Performance Tests (Docker CP) ==="
                    
                    # 1. Clean and recreate output directory on HOST
                    rm -rf ${OUT_DIR}
                    mkdir -p ${OUT_DIR}

                    # 2. Clean previous container
                    docker rm -f ${JMETER_CONTAINER_NAME} >/dev/null 2>&1 || true

                    # 3. Create and start container in background (using a non-root user for security, if possible)
                    docker run -d \
                        --name ${JMETER_CONTAINER_NAME} \
                        --user=root \
                        --entrypoint=sleep \
                        ${JMETER_IMAGE} infinity
                    
                    # 4. Create directory structure in the running container (as root)
                    docker exec ${JMETER_CONTAINER_NAME} mkdir -p /work/jmeter /work/out
                    
                    # 5. COPY JMeter files into the container (THE CRITICAL STEP)
                    echo "=== Copying test plan directory ${TEST_PLAN_DIR}/ to container ==="
                    # Copy the whole test-plans directory contents
                    docker cp ${TEST_PLAN_DIR}/. ${JMETER_CONTAINER_NAME}:/work/jmeter/
                    
                    # 6. Verify files are copied
                    echo "=== DEBUG: Container JMeter directory contents ==="
                    docker exec ${JMETER_CONTAINER_NAME} ls -la /work/jmeter/ || exit 1
                    
                    # 7. Execute JMeter inside the running container
                    echo "=== Executing JMeter ==="
                    # Execute JMeter on the copied file path: /work/jmeter/api-performance.jmx
                    docker exec ${JMETER_CONTAINER_NAME} jmeter -n \
                        -t /work/jmeter/${TEST_PLAN_FILE} \
                        -l /work/out/results.jtl \
                        -e -o /work/out/jmeter-report \
                        -f \
                        -Jthreads=50 -Jrampup=120 -Jbase.url=httpbin.org
                    JMETER_EXIT_CODE=\$?
                    echo "=== JMeter exit code: \$JMETER_EXIT_CODE ==="
                    
                    # 8. Copy results back from container to Jenkins workspace
                    echo "=== Copying results from container to workspace ${OUT_DIR} ==="
                    docker cp ${JMETER_CONTAINER_NAME}:/work/out/. ${OUT_DIR}/
                    
                    # 9. Clean up and remove container
                    docker rm -f ${JMETER_CONTAINER_NAME} >/dev/null 2>&1 || true
                    
                    # 10. Verify results
                    if [ -f "${OUT_DIR}/results.jtl" ]; then
                        echo "=== SUCCESS: Results generated ==="
                    else
                        echo "ERROR: No results.jtl file generated."
                        exit 1
                    fi
                    
                    exit \$JMETER_EXIT_CODE
                """
            }
        }
        
        stage('Collect Results') {
            steps {
                // Now results are guaranteed to be in ${OUT_DIR}
                archiveArtifacts artifacts: "${RESULTS_DIR}/**", fingerprint: true
            }
        }
    }
    
    post {
        always {
            // Ensure any residual container is removed, just in case
            sh "docker rm -f ${JMETER_CONTAINER_NAME} >/dev/null 2>&1 || true"
        }
    }
}