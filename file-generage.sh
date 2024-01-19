#!/bin/bash

# Array of services
services=('admin' 'apigateway' 'auth' 'delivery' 'notification' 'order' 'payment' 'product' 'store' 'user' 'wishlist' 'orderquery' 'giftcard')
port=(8200 8000 9000 8300 8400 8900 8100 8800 8700 8600 8500 9900 9100)
# Iterate over each service
for ((i=0; i<${#services[@]}; i++)); do
  service=${services[i]}
  service_port=${port[i]}

  # Create local-service.yml for each service
  cat <<EOL > "service/$service/blue-service.yml"
apiVersion: v1
kind: Service
metadata:
  name: $service-service
  namespace: prod
spec:
  type: ClusterIP
  ports:
    - name: app
      targetPort: $service_port
      port: $service_port
  selector:
    app: $service-service
    color: blue


EOL


  echo "Created $service/prod/service.yml"
done
