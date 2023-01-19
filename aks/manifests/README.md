# Some basic commands

### Get login information for kubectl
az aks get-credentials --resource-group project-dev --name project-aks-dev

### Inspect history of deployment
kubectl rollout history deployment.v1.apps/project-deployment

### Undo latest unsuccessful deployment
kubectl rollout undo deployment.v1.apps/project-deployment

### Or get back to specific revision
kubectl rollout undo deployment.v1.apps/project-deployment --to-revision=2

### See all logs from deployment
kubectl -n default logs -f deployment/project-deployment --all-containers=true --since=10m
