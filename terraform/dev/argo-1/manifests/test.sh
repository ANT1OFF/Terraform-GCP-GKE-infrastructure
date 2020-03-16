#!/bin/bash
terraform import kubernetes_config_map.argocd-config argocd/argocd-cm -lock=false