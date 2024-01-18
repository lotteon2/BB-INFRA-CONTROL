#!/bin/bash

CURRENT_COLOR=$(kubectl get service product-service -o jsonpath='{.spec.selector.color}' 2>/dev/null)

if [ "$CURRENT_COLOR" == "green" ]; then
    echo "Detected product-green running. Deploying product-blue..."

    # Deploy product-blue
    kubectl apply -f service-local/product/blue-deployment.yml

    # Wait for product-service-blue pods to be ready
    until kubectl get pods -l app=product-service,color=blue | grep "1/1" &> /dev/null; do
        echo "Waiting for product-service-blue pods to be ready..."
        sleep 10
    done

    # Update Service to point to product-blue
    kubectl patch service product-service -p '{"spec":{"selector":{"color":"blue"}}}'

    kubectl scale deployment product-service-green --replicas=0

    echo "Deployment complete. Traffic switched to product-blue."
elif [ "$CURRENT_COLOR" == "blue" ]; then
    echo "Detected product-blue running. Deploying product-green..."

    # Deploy product-green
    kubectl apply -f service-local/product/green-deployment.yml

    # Wait for product-service-green pods to be ready
    until kubectl get pods -l app=product-service,color=green | grep "1/1" &> /dev/null; do
        echo "Waiting for product-service-green pods to be ready..."
        sleep 10
    done

    # Update Service to point to product-green
    kubectl patch service product-service -p '{"spec":{"selector":{"color":"green"}}}'

    kubectl scale deployment product-service-blue --replicas=0

    echo "Deployment complete. Traffic switched to product-green."
else
    echo "No specific color detected. Please check your service configuration."
fi
