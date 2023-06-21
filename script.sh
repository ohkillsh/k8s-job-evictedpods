#!/bin/bash

set -euo pipefail

# gracefully handle the TERM signal sent when deleting the daemonset
trap 'exit' TERM

# Get the list of evicted pods
evicted_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Failed -o json | jq -r '.items[] | select(.status.reason == "Evicted") | .metadata.name + "," + .metadata.namespace')

# Delete the evicted pods
IFS=$'\n'
for pod in $evicted_pods; do
    IFS=',' read -ra pod_data <<< "$pod"
    pod_name=${pod_data[0]}
    namespace=${pod_data[1]}

    # Check if the pod exists before attempting deletion
    if kubectl get pod $pod_name --namespace=$namespace >/dev/null 2>&1; then
        echo "Deleting pod: $pod_name --namespace=$namespace"
        kubectl delete pod $pod_name --namespace=$namespace
    else
        echo "Pod not found: $pod_name --namespace=$namespace"
    fi
done

# let the monitoring script know we're done'
echo "done"

# this is a workaround to prevent the container from exiting 
# and k8s restarting the daemonset pod
while true; do sleep 1; done