
# Check if notification-service-blue deployment is running
if kubectl get deployment notification-service-blue | grep "1/1" &> /dev/null; then
    # Apply notification-service-green deployment
    kubectl apply -f service/notification/green-deployment.yml

    # Wait for notification-service-green pods to be ready
    until kubectl get pods -l app=notification-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for notification-service-green pods to be ready..."
        sleep 5
    done

    # Scale down notification-service-blue deployment
    kubectl scale deployment notification-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if notification-service-green deployment is running
elif kubectl get deployment notification-service-green | grep "1/1" &> /dev/null; then
    echo "notification-service-blue deployment not found."
    # Apply notification-service-blue deployment
    kubectl apply -f service/notification/blue-deployment.yml

    # Wait for notification-service-blue pods to be ready
    until kubectl get pods -l app=notification-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for notification-service-blue pods to be ready..."
        sleep 5
    done

    # Scale down notification-service-green deployment
    kubectl scale deployment notification-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "notification-service-green deployment not found."
    exit 1
fi

