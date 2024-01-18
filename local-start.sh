#!/bin/bash


declare -A services=(
    [1]='giftcard'
    [3]='auth'
    [4]='delivery'
    [5]='notification'
    [6]='order'
    [7]='payment'
    [8]='product'
    [9]='store'
    [10]='user'
    [12]='wishlist'
)

kubectl apply -f kube-util-local/util/namespace.yml
kubectl apply -f kube-util-local/util/mysql-config.yml
kubectl apply -f kube-util-local/util/redis-config.yml

kubectl apply -f kube-util-local/zookeeper/deployment.yml
kubectl apply -f kube-util-local/zookeeper/service.yml

kubectl apply -f kube-util-local/kafka/pv-pvc.yml
kubectl apply -f kube-util-local/kafka/deployment.yml
kubectl apply -f kube-util-local/kafka/service.yml

kubectl apply -f database-local/redis/pv-pvc.yml
kubectl apply -f database-local/redis/statefulset.yml
kubectl apply -f database-local/redis/service.yml

kubectl apply -f database-local/mongodb/pv-pvc.yml
kubectl apply -f database-local/mongodb/statefulset.yml
kubectl apply -f database-local/mongodb/service.yml

kubectl apply -f service-local/discovery/deployment.yml
kubectl apply -f service-local/discovery/service.yml

kubectl apply -f service-local/config/config-local.yml
kubectl apply -f service-local/config/deployment.yml
kubectl apply -f service-local/config/service.yml

kubectl apply -f service-local/apigateway/deployment.yml
kubectl apply -f service-local/apigateway/service.yml

kubectl apply -f service-local/orderquery/deployment.yml
kubectl apply -f service-local/orderquery/service.yml

selected_services=("${!services[@]}")

while true; do
    # Display the menu for choosing a service
    echo "Choose one service:"

    # Display the available services
    for key in "${selected_services[@]}"; do
        echo "$key) ${services[$key]}"
    done

    echo "0) Quit"

    # Prompt the user to choose a service
    read -p "> " service_choice

    case $service_choice in
        0)
            kubectl apply -f service-local/apigateway/ingress.yml
            kubectl apply -f kube-util-local/prometheus/deployment-service.yml
            kubectl apply -f kube-util-local/grafana/deploy-grafana.yml


            echo "Exiting the script"
            exit 0
            ;;
        [1-9]|1[0-2])
            selected_service=${services[$service_choice]}
            echo "$selected_service service running start"
            # Add your code for the selected service here

            kubectl apply -f database-local/$selected_service/initdb-config.yml
            kubectl apply -f database-local/$selected_service/pv-pvc.yml
            kubectl apply -f database-local/$selected_service/statefulset.yml
            kubectl apply -f database-local/$selected_service/service.yml

            kubectl apply -f service-local/$selected_service/deployment.yml
            kubectl apply -f service-local/$selected_service/service.yml

            # Update the available services for the next iteration
            unset "services[$service_choice]"
            selected_services=("${!services[@]}")
            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
    esac
done
