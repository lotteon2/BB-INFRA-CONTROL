
# Check if order-service-blue deployment is running
if kubectl get deployment order-service-blue | grep "2/2" &> /dev/null; then
    # Apply order-service-green deployment
    kubectl apply -f service/product/green-deployment.yml

    # Wait for order-service-green pods to be ready
    until kubectl get pods -l app=order-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for order-service-green pods to be ready..."
        sleep 5
    done

    # Scale down order-service-blue deployment
    kubectl scale deployment order-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if order-service-green deployment is running
elif kubectl get deployment order-service-green | grep "2/2" &> /dev/null; then
    echo "order-service-blue deployment not found."
    # Apply order-service-blue deployment
    kubectl apply -f service/product/blue-deployment.yml

    # Wait for order-service-blue pods to be ready
    until kubectl get pods -l app=order-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for order-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down order-service-green deployment
    kubectl scale deployment order-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "order-service-green deployment not found."
    exit 1
fi

