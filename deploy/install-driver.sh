#!/bin/bash

# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# using example: ./install-driver.sh [local|master|any remote branch] [snapshot,hostprocess]

set -euo pipefail

ver="master"
if [[ "$#" -gt 0 ]]; then
  ver="$1"
fi

repo="https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/$ver/deploy"
if [[ "$#" -gt 1 ]]; then
  if [[ "$2" == *"local"* ]]; then
    echo "use local deploy"
    repo="./deploy"
  fi
fi

if [ $ver != "master" ]; then
  repo="$repo/$ver"
fi

echo "Installing Azure File CSI driver, version: $ver ..."
kubectl apply -f $repo/rbac-csi-azurefile-controller.yaml
kubectl apply -f $repo/rbac-csi-azurefile-node.yaml
kubectl apply -f $repo/csi-azurefile-controller.yaml
kubectl apply -f $repo/csi-azurefile-driver.yaml
kubectl apply -f $repo/csi-azurefile-node.yaml

windowsMode="csi-proxy"

if [[ "$#" -gt 1 ]]; then
  if [[ "$2" == *"snapshot"* ]]; then
    echo "install snapshot driver ..."
    kubectl apply -f $repo/crd-csi-snapshot.yaml
    kubectl apply -f $repo/rbac-csi-snapshot-controller.yaml
    kubectl apply -f $repo/csi-snapshot-controller.yaml
  fi

  if [[ "$2" == *"hostprocess"* ]]; then
    echo "deploy windows driver with hostprocess ..."
    windowsMode="hostProcess"
    kubectl apply -f $repo/csi-azurefile-node-windows-hostprocess.yaml
  fi
fi

if [[ "$windowsMode" == *"csi-proxy"* ]]; then
  echo "deploy windows pods with csi-proxy ..."
  kubectl apply -f $repo/csi-azurefile-node-windows.yaml
fi

echo 'Azure File CSI driver installed successfully.'
