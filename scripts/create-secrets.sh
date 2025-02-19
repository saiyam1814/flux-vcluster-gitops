#!/bin/bash

teams=("team-a" "team-b" "team-c" "team-d")

for team in "${teams[@]}"; do
    echo "Processing team: $team"
    secret_name="env-$team-access"
    namespace="env-$team"

    if kubectl get secret "$secret_name" -n "$namespace" &> /dev/null; then
        echo "Secret $secret_name already exists. Deleting..."
        kubectl delete secret "$secret_name" -n "$namespace"
    fi

    echo "Creating secret $secret_name in namespace $namespace"
    vcluster connect "env-$team" -n "$namespace" --server="env-$team.env-$team.svc.cluster.local" --insecure --update-current=false --print | \
    kubectl create secret generic "$secret_name" -n "$namespace" --from-file=config=/dev/stdin
done

echo "Secrets creation/update completed."

