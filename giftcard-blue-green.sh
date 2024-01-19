
# Check if giftcard-service-blue deployment is running
if kubectl get deployment giftcard-service-blue | grep "1/1" &> /dev/null; then
    # Apply giftcard-service-green deployment
    kubectl apply -f service/giftcard/green-deployment.yml

    # Wait for giftcard-service-green pods to be ready
    until kubectl get pods -l app=giftcard-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for giftcard-service-green pods to be ready..."
        sleep 5
    done

    # Scale down giftcard-service-blue deployment
    kubectl scale deployment giftcard-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if giftcard-service-green deployment is running
elif kubectl get deployment giftcard-service-green | grep "1/1" &> /dev/null; then
    echo "giftcard-service-blue deployment not found."
    # Apply giftcard-service-blue deployment
    kubectl apply -f service/giftcard/blue-deployment.yml

    # Wait for giftcard-service-blue pods to be ready
    until kubectl get pods -l app=giftcard-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for giftcard-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down giftcard-service-green deployment
    kubectl scale deployment giftcard-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "giftcard-service-green deployment not found."
    exit 1
fi

