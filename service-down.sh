#!/bin/bash

# Array of services
services=('auth' 'delivery' 'notification' 'order' 'payment' 'product' 'store' 'user' 'wishlist' 'giftcard')

# Iterate over each service
for ((i=0; i<${#services[@]}; i++)); do
  service=${services[i]}

  kubectl delete service $service-service
  kubectl delete deployment $service-service
#  kubectl delete service $service-db
#  kubectl delete statefulset $service-db
#  kubectl delete pvc pvc-$service
#  kubectl delete pv pv-$service
  echo "Created $service/prod/service.yml"
done

#kubectl delete pvc --all -n prod
#kubectl delete pv --all -n prod
