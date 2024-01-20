kubectl apply -f service/apigateway/deployment.yml
kubectl apply -f service/apigateway/service.yml

# Check if apigateway-service-blue deployment is running
if kubectl get deployment apigateway-service-blue &> /dev/null; then
    # Apply apigateway-service-green deployment
    kubectl apply -f service/apigateway/green-deployment.yml

    # Wait for apigateway-service-green pods to be ready
    until kubectl get pods -l app=apigateway-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for apigateway-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service apigateway-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down apigateway-service-blue deployment
    kubectl scale deployment apigateway-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if apigateway-service-green deployment is running
elif kubectl get deployment apigateway-service-green &> /dev/null; then
    echo "apigateway-service-blue deployment not found."
    # Apply apigateway-service-blue deployment
    kubectl apply -f service/apigateway/blue-deployment.yml

    # Wait for apigateway-service-blue pods to be ready
    until kubectl get pods -l app=apigateway-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for apigateway-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service apigateway-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down apigateway-service-green deployment
    kubectl scale deployment apigateway-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "apigateway-service-green deployment not found."
    echo "start apigateway service"

    kubectl apply -f service/apigateway/blue-deployment.yml
    kubectl apply -f service/apigateway/blue-service.yml
    exit 1
fi

