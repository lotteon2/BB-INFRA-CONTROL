#kubectl delete service product-db
#kubectl delete statefulset product-db
#kubectl delete pvc pvc-product
#kubectl delete pv pv-product
#
#kubectl apply -f database/product/initdb-config.yml
#kubectl apply -f database/product/pv-pvc.yml
#kubectl apply -f database/product/statefulset.yml
#kubectl apply -f database/product/service.yml

# Check if product-service-blue deployment is running
if kubectl get deployment product-service-blue | grep "2/2" &> /dev/null; then
    # Apply product-service-green deployment
    kubectl apply -f service/product/green-deployment.yml

    # Wait for product-service-green pods to be ready
    until kubectl get pods -l app=product-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for product-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service product-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down product-service-blue deployment
    kubectl scale deployment product-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if product-service-green deployment is running
elif kubectl get deployment product-service-green | grep "2/2" &> /dev/null; then
    echo "product-service-blue deployment not found."
    # Apply product-service-blue deployment
    kubectl apply -f service/product/blue-deployment.yml

    # Wait for product-service-blue pods to be ready
    until kubectl get pods -l app=product-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for product-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service product-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down product-service-green deployment
    kubectl scale deployment product-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "product-service-green deployment not found."
    echo "start product service"

    kubectl apply -f database/product/initdb-config.yml
    kubectl apply -f database/product/pv-pvc.yml
    kubectl apply -f database/product/statefulset.yml
    kubectl apply -f database/product/service.yml
    kubectl apply -f service/product/blue-deployment.yml
    kubectl apply -f service/product/blue-service.yml
    exit 1
fi

