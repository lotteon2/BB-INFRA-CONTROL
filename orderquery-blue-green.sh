
# Check if orderquery-service-blue deployment is running
if kubectl get deployment orderquery-service-blue | grep "1/1" &> /dev/null; then
    # Apply orderquery-service-green deployment
    kubectl apply -f service/orderquery/green-deployment.yml

    # Wait for orderquery-service-green pods to be ready
    until kubectl get pods -l app=orderquery-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for orderquery-service-green pods to be ready..."
        sleep 5
    done

    # Scale down orderquery-service-blue deployment
    kubectl scale deployment orderquery-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if orderquery-service-green deployment is running
elif kubectl get deployment orderquery-service-green | grep "1/1" &> /dev/null; then
    echo "orderquery-service-blue deployment not found."
    # Apply orderquery-service-blue deployment
    kubectl apply -f service/orderquery/blue-deployment.yml

    # Wait for orderquery-service-blue pods to be ready
    until kubectl get pods -l app=orderquery-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for orderquery-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down orderquery-service-green deployment
    kubectl scale deployment orderquery-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "orderquery-service-green deployment not found."
    exit 1
fi

