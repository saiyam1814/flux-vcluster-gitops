#!/bin/bash

environments=("dev" "qa" "prod")

for env in "${environments[@]}"; do
  namespace="vcluster-$env"
  secret_name="vc-$env-kubeconfig"

  # Generate KubeConfig
  vcluster connect "vcluster-$env" -n "$namespace" --update-current=false --print > kubeconfig-$env.yaml

  # Create or update the secret in the host cluster
  kubectl create secret generic "$secret_name" \
    -n "$namespace" \
    --from-file=config=kubeconfig-$env.yaml \
    --dry-run=client -o yaml | kubectl apply -f -
done

