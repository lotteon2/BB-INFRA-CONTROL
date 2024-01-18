# Check if product-service-blue deployment is running
if kubectl get deployment order-service-blue &> /dev/null; then
    # Apply product-service-green deployment
    kubectl apply -f service/order/green-deployment.yml

    # Wait for product-service-green pods to be ready
    until kubectl get pods -l app=order-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for product-service-green pods to be ready..."
        sleep 5
    done

    # Scale down product-service-blue deployment
    kubectl scale deployment order-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."
else
  echo "blue service is unavailable"
  exit 1
fi
# Check if product-service-green deployment is running
if kubectl get deployment order-service-green &> /dev/null; then
    echo "order-service-blue deployment not found."
    # Apply product-service-blue deployment
    kubectl apply -f service/order/blue-deployment.yml

    # Wait for product-service-blue pods to be ready
    until kubectl get pods -l app=order-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for order-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down product-service-green deployment
    kubectl scale deployment order-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "order-service-green deployment not found."
    exit 1
fi