kubectl port-forward svc/kube-prometheus-stack-prometheus 9090 -n monitoring

kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

##
kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode

kubectl get secrets -n monitoring | grep grafana

admin
SPLVk0EOPkYCuOZkRoS3vhP3S6qospG774qchxjg

#
minikube service kube-prometheus-stack-grafana -n monitoring