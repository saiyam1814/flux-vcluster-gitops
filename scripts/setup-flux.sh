#!/bin/bash

# Set variables
GITHUB_USER="saiyam1814"
GITHUB_REPO="flux-vcluster-gitops"
GITHUB_BRANCH="main"
NAMESPACE="flux-system"

# Install Flux
flux install --namespace $NAMESPACE

# Create GitRepository resource
kubectl apply -f - <<EOF
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-system
  namespace: $NAMESPACE
spec:
  interval: 1m
  url: https://github.com/$GITHUB_USER/$GITHUB_REPO
  branch: $GITHUB_BRANCH
EOF

# Create Kustomization for syncing host cluster resources
kubectl apply -f - <<EOF
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: clusters
  namespace: $NAMESPACE
spec:
  interval: 10m
  path: "./clusters/host"
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
EOF

