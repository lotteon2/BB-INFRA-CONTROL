kubectl delete ingress --all
kubectl delete service apigateway-service
kubectl delete deployment apigateway-service


sleep 5

kubectl apply -f service/apigateway/deployment.yml
kubectl apply -f service/apigateway/service.yml
sleep 5
kubectl apply -f service/apigateway/ingress.yml
