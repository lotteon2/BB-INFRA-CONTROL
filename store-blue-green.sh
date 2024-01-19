
# Check if store-service-blue deployment is running
if kubectl get deployment store-service-blue | grep "2/2" &> /dev/null; then
    # Apply store-service-green deployment
    kubectl apply -f service/store/green-deployment.yml

    # Wait for store-service-green pods to be ready
    until kubectl get pods -l app=store-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for store-service-green pods to be ready..."
        sleep 5
    done

    # Scale down store-service-blue deployment
    kubectl scale deployment store-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if store-service-green deployment is running
elif kubectl get deployment store-service-green | grep "2/2" &> /dev/null; then
    echo "store-service-blue deployment not found."
    # Apply store-service-blue deployment
    kubectl apply -f service/store/blue-deployment.yml

    # Wait for store-service-blue pods to be ready
    until kubectl get pods -l app=store-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for store-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down store-service-green deployment
    kubectl scale deployment store-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "store-service-green deployment not found."
    exit 1
fi

