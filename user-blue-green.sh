
# Check if user-service-blue deployment is running
if kubectl get deployment user-service-blue &> /dev/null; then
    # Apply user-service-green deployment
    kubectl apply -f service/user/green-deployment.yml

    # Wait for user-service-green pods to be ready
    until kubectl get pods -l app=user-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for user-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service user-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down user-service-blue deployment
    kubectl scale deployment user-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if user-service-green deployment is running
elif kubectl get deployment user-service-green &> /dev/null; then
    echo "user-service-blue deployment not found."
    # Apply user-service-blue deployment
    kubectl apply -f service/user/blue-deployment.yml

    # Wait for user-service-blue pods to be ready
    until kubectl get pods -l app=user-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for user-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service user-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down user-service-green deployment
    kubectl scale deployment user-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "user-service-green deployment not found."
    echo "start user service"

    kubectl apply -f database/user/initdb-config.yml
    kubectl apply -f database/user/pv-pvc.yml
    kubectl apply -f database/user/statefulset.yml
    kubectl apply -f database/user/service.yml
    kubectl apply -f service/user/blue-deployment.yml
    kubectl apply -f service/user/blue-service.yml
    exit 1
fi

