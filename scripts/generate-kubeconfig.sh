#!/bin/bash

VCLUSTER_LIST=("vcluster1" "vcluster2")  # Add all vClusters you want

for VCLUSTER in "${VCLUSTER_LIST[@]}"; do
  KUBECONFIG_PATH=~/.kube/${VCLUSTER}-kubeconfig

  echo "🔄 Generating kubeconfig for ${VCLUSTER}..."
  vcluster connect ${VCLUSTER} --namespace host-cluster --server --loginshell=false > ${KUBECONFIG_PATH}

  if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
    echo "❌ Failed to generate kubeconfig for ${VCLUSTER}"
    continue
  fi

  kubectl create secret generic ${VCLUSTER}-kubeconfig \
    --from-file=kubeconfig=${KUBECONFIG_PATH} \
    -n flux-system --dry-run=client -o yaml | kubectl apply -f -

  echo "✅ Kubeconfig for ${VCLUSTER} stored in Kubernetes!"
done

