#!/bin/bash

# Environments
environments=("dev" "qa" "prod")

for env in "${environments[@]}"; do
    echo "Processing environment: $env"

    secret_name="vcluster-$env-kubeconfig"
    namespace="vcluster-$env"

    # Wait for vCluster to be ready
    echo "Waiting for vcluster-$env to be ready..."
    kubectl wait --for=condition=Available deployment/vcluster-$env -n $namespace --timeout=300s

    # Generate kubeconfig
    echo "Generating kubeconfig for vcluster-$env..."
    vcluster connect vcluster-$env -n $namespace --update-current=false --insecure --print > kubeconfig-$env.yaml

    # Store kubeconfig as a secret
    kubectl create secret generic $secret_name -n $namespace --from-file=config=kubeconfig-$env.yaml --dry-run=client -o yaml | kubectl apply -f -

    # Cleanup
    rm kubeconfig-$env.yaml
done

echo "Kubeconfig secrets stored successfully."

