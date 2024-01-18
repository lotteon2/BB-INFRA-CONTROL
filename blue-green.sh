#!/bin/bash


declare -A services=(
    [1]='config'
    [2]='giftcard'
    [3]='auth'
    [4]='delivery'
    [5]='notification'
    [6]='order'
    [7]='payment'
    [8]='product'
    [9]='store'
    [10]='user'
    [12]='wishlist'
    [13]='apigateway'
    [14]='discovery'
    [15]='config'
)

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
            echo "Exiting the script"
            exit 0
            ;;
        [0-9]|1[0-5])
            selected_service=${services[$service_choice]}
            echo "$selected_service service running start"
            # Add your code for the selected service here

            # Check if product-service-blue deployment is running
            if kubectl get deployment $selected_service-service-blue &> /dev/null; then
                # Apply product-service-green deployment
                kubectl apply -f service/$selected_service/green-deployment.yml

                # Wait for product-service-green pods to be ready
                until kubectl get pods -l app=$selected_service-service,color=green | grep "1/1" &> /dev/null; do
                    echo "Waiting for product-service-green pods to be ready..."
                    sleep 5
                done

                # Scale down product-service-blue deployment
                kubectl scale deployment $selected_service-service-blue --replicas=0

                echo "Blue deployment applied, and blue deployment scaled down."
            else
              echo "blue service is unavailable"
              exit 1
            fi
            # Check if product-service-green deployment is running
            if kubectl get deployment $selected_service-service-green &> /dev/null; then
                echo "$selected_service-service-blue deployment not found."
                # Apply product-service-blue deployment
                kubectl apply -f service/$selected_service/blue-deployment.yml

                # Wait for product-service-blue pods to be ready
                until kubectl get pods -l app=$selected_service-service,color=blue | grep "1/1" &> /dev/null; do
                    echo "Waiting for $selected_service-service-blue pods to be ready..."
                    sleep 5
                done

                # Scale down product-service-green deployment
                kubectl scale deployment $selected_service-service-green --replicas=0

                echo "Blue deployment applied, and green deployment scaled down."
            else
                echo "$selected_service-service-green deployment not found."
                exit 1
            fi


            # Update the available services for the next iteration
            unset "services[$service_choice]"
            selected_services=("${!services[@]}")
            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
    esac
done

