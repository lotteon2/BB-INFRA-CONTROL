#!/bin/bash

# Array of services
services=('admin' 'apigateway' 'auth' 'delivery' 'notification' 'order' 'payment' 'product' 'store' 'user' 'wishlist' 'orderquery' 'giftcard')
port=(8200 8000 9000 8300 8400 8900 8100 8800 8700 8600 8500 9900 9100)
# Iterate over each service
for ((i=0; i<${#services[@]}; i++)); do
  service=${services[i]}
  service_port=${port[i]}

  # Create local-service.yml for each service
  cat <<EOL > "service/$service/blue-deployment.yml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service-service-blue
  namespace: prod
  labels:
    app: $service-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $service-service
      color: blue
  template:
    metadata:
      labels:
        app: $service-service
        color: blue
    spec:
      containers:
        - name: $service-service
          image: nowgnas/bb-$service:latest
          imagePullPolicy: Always
          ports:
            - containerPort: $service_port
          resources:
            requests:
              memory: "350Mi"
              cpu: "400m"
          env:
            - name: USE_PROFILE
              value: "prod"
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: $service_port
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 2
          # 애플리케이션이 정상 상태를 유지하고 있는지 지속해서 검사
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: $service_port
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 2
      restartPolicy: Always

EOL


  echo "Created $service/prod/service.yml"
done
