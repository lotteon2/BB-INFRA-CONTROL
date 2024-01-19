
# Check if admin-service-blue deployment is running
if kubectl get deployment admin-service-blue &> /dev/null; then
    # Apply admin-service-green deployment
    kubectl apply -f service/product/green-deployment.yml

    # Wait for admin-service-green pods to be ready
    until kubectl get pods -l app=admin-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for admin-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service admin-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down admin-service-blue deployment
    kubectl scale deployment admin-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if admin-service-green deployment is running
elif kubectl get deployment admin-service-green &> /dev/null; then
    echo "admin-service-blue deployment not found."
    # Apply admin-service-blue deployment
    kubectl apply -f service/product/blue-deployment.yml

    # Wait for admin-service-blue pods to be ready
    until kubectl get pods -l app=admin-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for admin-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service admin-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down admin-service-green deployment
    kubectl scale deployment admin-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "admin-service-green deployment not found."
    echo "start admin service"
    kubectl delete service admin-db
    kubectl delete statefulset admin-db
    kubectl delete pvc pvc-admin
    kubectl delete pv pv-admin

    kubectl apply -f database/admin/initdb-config.yml
    kubectl apply -f database/admin/pv-pvc.yml
    kubectl apply -f database/admin/statefulset.yml
    kubectl apply -f database/admin/service.yml
    kubectl apply -f service/admin/blue-deployment.yml
    kubectl apply -f service/admin/blue-service.yml
    exit 1
fi

