kubectl delete deployment kafka
kubectl delete svc kafka
kubectl delete pvc pvc-kafka
kubectl delete pv pv-kafka

kubectl delete deployment zookeeper
kubectl delete svc zookeeper

sleep 5

kubectl apply -f kube-util/zookeeper/deployment.yml
kubectl apply -f kube-util/zookeeper/service.yml

kubectl apply -f kube-util/kafka/pv-pvc.yml
kubectl apply -f kube-util/kafka/deployment.yml
kubectl apply -f kube-util/kafka/service.yml