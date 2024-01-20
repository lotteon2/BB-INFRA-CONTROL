#kubectl delete service delivery-db
#kubectl delete statefulset delivery-db
#kubectl delete pvc pvc-delivery
#kubectl delete pv pv-delivery
#
#kubectl apply -f database/delivery/initdb-config.yml
#kubectl apply -f database/delivery/pv-pvc.yml
#kubectl apply -f database/delivery/statefulset.yml
#kubectl apply -f database/delivery/service.yml

# Check if delivery-service-blue deployment is running
if kubectl get deployment delivery-service-blue | grep "1/1" &> /dev/null; then
    # Apply delivery-service-green deployment
    kubectl apply -f service/delivery/green-deployment.yml

    # Wait for delivery-service-green pods to be ready
    until kubectl get pods -l app=delivery-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for delivery-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service delivery-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down delivery-service-blue deployment
    kubectl scale deployment delivery-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if delivery-service-green deployment is running
elif kubectl get deployment delivery-service-green | grep "1/1" &> /dev/null; then
    echo "delivery-service-blue deployment not found."
    # Apply delivery-service-blue deployment
    kubectl apply -f service/delivery/blue-deployment.yml

    # Wait for delivery-service-blue pods to be ready
    until kubectl get pods -l app=delivery-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for delivery-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service delivery-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down delivery-service-green deployment
    kubectl scale deployment delivery-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "delivery-service-green deployment not found."
    echo "start delivery service"

    kubectl apply -f database/delivery/initdb-config.yml
    kubectl apply -f database/delivery/pv-pvc.yml
    kubectl apply -f database/delivery/statefulset.yml
    kubectl apply -f database/delivery/service.yml
    kubectl apply -f service/delivery/blue-deployment.yml
    kubectl apply -f service/delivery/blue-service.yml
    exit 1
fi

