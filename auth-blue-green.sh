
# Check if auth-service-blue deployment is running
if kubectl get deployment auth-service-blue | grep "1/1" &> /dev/null; then
    # Apply auth-service-green deployment
    kubectl apply -f service/auth/green-deployment.yml

    # Wait for auth-service-green pods to be ready
    until kubectl get pods -l app=auth-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for auth-service-green pods to be ready..."
        sleep 5
    done

    # Scale down auth-service-blue deployment
    kubectl scale deployment auth-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if auth-service-green deployment is running
elif kubectl get deployment auth-service-green | grep "1/1" &> /dev/null; then
    echo "auth-service-blue deployment not found."
    # Apply auth-service-blue deployment
    kubectl apply -f service/auth/blue-deployment.yml

    # Wait for auth-service-blue pods to be ready
    until kubectl get pods -l app=auth-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for auth-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down auth-service-green deployment
    kubectl scale deployment auth-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "auth-service-green deployment not found."
    exit 1
fi

