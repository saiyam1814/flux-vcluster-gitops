#!/bin/bash

KUBECONFIG_PATH=~/.kube/vcluster-kubeconfig

echo "Generating vCluster kubeconfig..."
vcluster connect vcluster --namespace vcluster --detach

kubectl get secret vcluster -n vcluster -o jsonpath="{.data.config}" | base64 -d > ${KUBECONFIG_PATH}

kubectl create secret generic vcluster-kubeconfig \
  --from-file=kubeconfig=${KUBECONFIG_PATH} \
  -n flux-system --dry-run=client -o yaml | kubectl apply -f -

echo "vCluster kubeconfig secret created!"

