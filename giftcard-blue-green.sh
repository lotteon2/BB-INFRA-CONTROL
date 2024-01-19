
# Check if giftcard-service-blue deployment is running
if kubectl get deployment giftcard-service-blue | grep "1/1" &> /dev/null; then
    # Apply giftcard-service-green deployment
    kubectl apply -f service/giftcard/green-deployment.yml

    # Wait for giftcard-service-green pods to be ready
    until kubectl get pods -l app=giftcard-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for giftcard-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service giftcard-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

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

    kubectl patch service giftcard-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down giftcard-service-green deployment
    kubectl scale deployment giftcard-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "giftcard-service-green deployment not found."
    echo "start giftcard service"

    kubectl apply -f database/giftcard/initdb-config.yml
    kubectl apply -f database/giftcard/pv-pvc.yml
    kubectl apply -f database/giftcard/statefulset.yml
    kubectl apply -f database/giftcard/service.yml
    kubectl apply -f service/giftcard/blue-deployment.yml
    kubectl apply -f service/giftcard/blue-service.yml
    exit 1
fi

