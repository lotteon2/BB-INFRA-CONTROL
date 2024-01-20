
#kubectl delete service payment-db
#kubectl delete statefulset payment-db
#kubectl delete pvc pvc-payment
#kubectl delete pv pv-payment
#
#kubectl apply -f database/payment/initdb-config.yml
#kubectl apply -f database/payment/pv-pvc.yml
#kubectl apply -f database/payment/statefulset.yml
#kubectl apply -f database/payment/service.yml

# Check if payment-service-blue deployment is running
if kubectl get deployment payment-service-blue | grep "2/2" &> /dev/null; then
    # Apply payment-service-green deployment
    kubectl apply -f service/payment/green-deployment.yml

    # Wait for payment-service-green pods to be ready
    until kubectl get pods -l app=payment-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for payment-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service payment-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down payment-service-blue deployment
    kubectl scale deployment payment-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if payment-service-green deployment is running
elif kubectl get deployment payment-service-green | grep "2/2" &> /dev/null; then
    echo "payment-service-blue deployment not found."
    # Apply payment-service-blue deployment
    kubectl apply -f service/payment/blue-deployment.yml

    # Wait for payment-service-blue pods to be ready
    until kubectl get pods -l app=payment-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for payment-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service payment-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down payment-service-green deployment
    kubectl scale deployment payment-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "payment-service-green deployment not found."
    echo "start payment service"

    kubectl apply -f database/payment/initdb-config.yml
    kubectl apply -f database/payment/pv-pvc.yml
    kubectl apply -f database/payment/statefulset.yml
    kubectl apply -f database/payment/service.yml
    kubectl apply -f service/payment/blue-deployment.yml
    kubectl apply -f service/payment/blue-service.yml
    exit 1
fi

