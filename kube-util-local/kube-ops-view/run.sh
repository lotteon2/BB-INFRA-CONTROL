curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

helm version --short

helm repo add stable https://charts.helm.sh/stable

helm repo add k8s-at-home https://k8s-at-home.com/charts/

helm repo update

helm install kube-ops-view k8s-at-home/kube-ops-view

helm list

