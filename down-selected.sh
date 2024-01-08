#!/bin/bash


declare -A services=(
    [14]='orderquery'
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
)


selected_services=("${!services[@]}")

while true; do
    # Display the menu for choosing a service
    echo "Choose one service to down:"

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
        [0-9]|1[0-4])
            selected_service=${services[$service_choice]}
            echo "$selected_service service down"
            # Add your code for the selected service here

            kubectl delete service $selected_service-service
            kubectl delete deployment $selected_service-service

#            kubectl delete service $selected_service-db
#            kubectl delete statefulset $selected_service-db
#            kubectl delete pvc pvc-$selected_service
#            kubectl delete pv pv-$selected_service


            # Update the available services for the next iteration
            unset "services[$service_choice]"
            selected_services=("${!services[@]}")
            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
    esac
done