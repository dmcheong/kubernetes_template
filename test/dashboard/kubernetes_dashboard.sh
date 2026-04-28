

kubectl apply -f "./test/dashboard/kubernetes-dashboard-admin.yml" -n kubernetes-dashboard
kubectl apply -f "./test/dashboard/kubernetes-dashboard-traefik.yml"  -n kubernetes-dashboard
kubectl apply -f "./test/dashboard/kubernetes-dashboard-networkpolicy.yml"  -n kubernetes-dashboard

echo -e "\n\n# Minikube cluster IP\n$(minikube ip) minikube.local" | sudo tee -a /etc/hosts > /dev/null

sudo sed -i '/# Minikube cluster IP/,+1d' /etc/hosts && \
echo -e "\n\n# Minikube cluster IP\n$(minikube ip) whoami.local api.local grafana.local prometheus.local dashboard.local" | sudo tee -a /etc/hosts > /dev/null

# echo -e "\n\n# Minikube cluster IP\n$(minikube ip) whoami.local api.local grafana.local prometheus.local dashboard.local" | sudo tee -a /etc/hosts > /dev/null

# minikube ip
# minikube dashboard
# sudo nano /etc/hosts > 192.168.49.2
# 192.168.49.2 dashboard.local
# http://dashboard.local

# bearer token
# kubectl -n kubernetes-dashboard create token dashboard-admin-user
# kubectl -n dashboard create token dashboard-readonly-user

# optionnelle
# minikube dashboard --url
kubectl get pods -n kubernetes-dashboard
kubectl get svc -n kubernetes-dashboard
kubectl get ingressroute -n kubernetes-dashboard