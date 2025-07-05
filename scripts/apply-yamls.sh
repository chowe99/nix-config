#!/bin/sh
kubectl apply -f ~/nix-config/configs/glusterfs-cluster.yaml
kubectl apply -f ~/nix-config/configs/nextcloud-pv.yaml
kubectl apply -f ~/nix-config/configs/nextcloud-pvc.yaml
kubectl apply -f ~/nix-config/configs/nextcloud-deployment.yaml
kubectl apply -f ~/nix-config/configs/nextcloud-service.yaml
