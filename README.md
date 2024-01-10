# turo

# Workflow 
Follow these steps:

1. **Update Code**: Make changes to application or configuration as needed.

2. **Run Script1.sh (Docker Build and Push)**: Increment the version in the VERSION file, build a new Docker image with this version, and push it to the registry.

3. **Run Script2.py (Git Operations)**:Using Python, the script checks out a new branch, commits the changes (including the updated VERSION file).

4. **Create and Merge PR**: Manually create a Pull Request if not automated, review the changes, and merge it into your main branch.

5. **Run Terraform Plan and Apply**: The Terraform code manages Kubernetes resources, including a deployment, ConfigMaps, a service, and an ingress. It dynamically pulls the application version from the VERSION file to ensure the deployment uses the latest Docker image. 


# Terraform

- **Terraform and Kubernetes Provider Configuration**: Initializes Terraform and configures it to work with a Kubernetes cluster, specifying the path to the kubeconfig file and context.

- **External Data for App Version**: Uses an external data source to fetch the application version from a `VERSION` file.

- **Namespace Variable**: Defines a variable for the Kubernetes namespace to be used.

- **Config Maps**: Two Kubernetes config maps are defined:
  - `app_env` holds an environment variable file `.env`.
  - `app_config` contains the HTML content for `config.html`.

- **Kubernetes Deployment**: Deploys the application in the specified namespace, pulling the Docker image with the version specified in `VERSION`. It also sets resource limits and mounts volumes for config maps.

- **Kubernetes Service**: Defines a ClusterIP service for the app, mapping port 443 to the container's port 80.

- **Kubernetes Ingress**: Configures an ingress resource for external access, with annotations for DNS and Nginx ingress controller. 


# Useful commands

## list all resources
kubectl get all -n candidate-b

## ssh into pod 
kubectl exec -it pod/pod-name -n candidate-b   -- /bin/bash

## describe resources
kubectl describe pod/pod-name -n candidate-b

kubectl describe pod/pod-name -n candidate-b

# get resources details in yaml format
kubectl get ingress ingress-name -n candidate-b  -o yaml
kubectl get service service-name -n candidate-b  -o yaml
kubectl get configmap config-name -n candidate-b  -o yaml
kubectl get deployment deployment-name -n candidate-b  -o yaml
