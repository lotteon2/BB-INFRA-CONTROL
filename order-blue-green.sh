
#kubectl delete service order-db
#kubectl delete statefulset order-db
#kubectl delete pvc pvc-order
#kubectl delete pv pv-order
#
#kubectl apply -f database/order/initdb-config.yml
#kubectl apply -f database/order/pv-pvc.yml
#kubectl apply -f database/order/statefulset.yml
#kubectl apply -f database/order/service.yml

# Check if order-service-blue deployment is running
if kubectl get deployment order-service-blue | grep "1/1" &> /dev/null; then
    # Apply order-service-green deployment
    kubectl apply -f service/order/green-deployment.yml

    # Wait for order-service-green pods to be ready
    until kubectl get pods -l app=order-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for order-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service order-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down order-service-blue deployment
    kubectl scale deployment order-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if order-service-green deployment is running
elif kubectl get deployment order-service-green | grep "1/1" &> /dev/null; then
    echo "order-service-blue deployment not found."
    # Apply order-service-blue deployment
    kubectl apply -f service/order/blue-deployment.yml

    # Wait for order-service-blue pods to be ready
    until kubectl get pods -l app=order-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for order-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service order-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down order-service-green deployment
    kubectl scale deployment order-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "order-service-green deployment not found."
    echo "start order service"

    kubectl apply -f database/order/initdb-config.yml
    kubectl apply -f database/order/pv-pvc.yml
    kubectl apply -f database/order/statefulset.yml
    kubectl apply -f database/order/service.yml
    kubectl apply -f service/order/blue-deployment.yml
    kubectl apply -f service/order/blue-service.yml
    exit 1
fi

