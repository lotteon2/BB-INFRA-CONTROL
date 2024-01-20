#kubectl delete service auth-db
#kubectl delete statefulset auth-db
#kubectl delete pvc pvc-auth
#kubectl delete pv pv-auth
#
#kubectl apply -f database/auth/initdb-config.yml
#kubectl apply -f database/auth/pv-pvc.yml
#kubectl apply -f database/auth/statefulset.yml
#kubectl apply -f database/auth/service.yml

# Check if auth-service-blue deployment is running
if kubectl get deployment auth-service-blue | grep "1/1" &> /dev/null; then
    # Apply auth-service-green deployment
    kubectl apply -f service/auth/green-deployment.yml

    # Wait for auth-service-green pods to be ready
    until kubectl get pods -l app=auth-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for auth-service-green pods to be ready..."
        sleep 5
    done

    kubectl patch service auth-service -n prod -p '{"spec":{"selector":{"color":"green"}}}'

    # Scale down auth-service-blue deployment
    kubectl scale deployment auth-service-blue --replicas=0

    echo "Blue deployment applied, and blue deployment scaled down."

# Check if auth-service-green deployment is running
elif kubectl get deployment auth-service-green | grep "1/1" &> /dev/null; then
    echo "auth-service-blue deployment not found."
    # Apply auth-service-blue deployment
    kubectl apply -f service/auth/blue-deployment.yml

    # Wait for auth-service-blue pods to be ready
    until kubectl get pods -l app=auth-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for auth-service-blue pods to be ready..."
        sleep 5
    done

    kubectl patch service auth-service -n prod -p '{"spec":{"selector":{"color":"blue"}}}'

    # Scale down auth-service-green deployment
    kubectl scale deployment auth-service-green --replicas=0

    echo "Blue deployment applied, and green deployment scaled down."
else
    echo "auth-service-green deployment not found."
    echo "start auth service"

    kubectl apply -f database/auth/initdb-config.yml
    kubectl apply -f database/auth/pv-pvc.yml
    kubectl apply -f database/auth/statefulset.yml
    kubectl apply -f database/auth/service.yml
    kubectl apply -f service/auth/blue-deployment.yml
    kubectl apply -f service/auth/blue-service.yml
    exit 1
fi

