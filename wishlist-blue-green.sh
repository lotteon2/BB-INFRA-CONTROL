
# Check if wishlist-service-blue deployment is running
if kubectl get deployment wishlist-service-blue &> /dev/null; then
    # Apply wishlist-service-green deployment
    kubectl apply -f service/wishlist/green-deployment.yml

    # Wait for wishlist-service-green pods to be ready
    until kubectl get pods -l app=wishlist-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for wishlist-service-green pods to be ready..."
        sleep 5
    done

    # Scale down wishlist-service-blue deployment
    kubectl scale deployment wishlist-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if wishlist-service-green deployment is running
elif kubectl get deployment wishlist-service-green &> /dev/null; then
    echo "wishlist-service-blue deployment not found."
    # Apply wishlist-service-blue deployment
    kubectl apply -f service/wishlist/blue-deployment.yml

    # Wait for wishlist-service-blue pods to be ready
    until kubectl get pods -l app=wishlist-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for wishlist-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down wishlist-service-green deployment
    kubectl scale deployment wishlist-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "wishlist-service-green deployment not found."
    exit 1
fi

