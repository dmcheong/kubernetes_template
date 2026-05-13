

# Streams only warnings and failures from all namespaces in real time
kubectl get events -A -w | grep -v "Normal"

# Shows the exact changes kubernetes will apply before deployment
# kubectl diff -f deployment.yml

# Sorts pods by restart count to quickly find unstable worloads
kubectl get pods -A --sorts-by='status.containerStatuses[0].restartCount'

# Shows the exact changes kubernetes will apply before deployment
kubectl top pods -A --sort-by=memory --containers

