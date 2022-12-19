#!/bin/bash
# Files are ordered in proper order with needed wait for the dependent custom resource definitions to get initialized.
# Usage: bash kubectl-apply.sh

usage(){
 cat << EOF

 Usage: $0 -f
 Description: To apply k8s manifests using the default \`kubectl apply -f\` command
[OR]
 Usage: $0 -k
 Description: To apply k8s manifests using the kustomize \`kubectl apply -k\` command
[OR]
 Usage: $0 -s
 Description: To apply k8s manifests using the skaffold binary \`skaffold run\` command

EOF
exit 0
}

logSummary() {
    echo ""
}

default() {
    suffix=k8s
    microk8s.kubectl apply -f namespace.yml
    microk8s.kubectl apply -f registry-${suffix}/
    microk8s.kubectl apply -f cblog-${suffix}/
    microk8s.kubectl apply -f cgateway-${suffix}/
    microk8s.kubectl apply -f cstore-${suffix}/
}

delete_apps() {
    suffix=k8s
    microk8s.kubectl delete -f registry-${suffix}/
    microk8s.kubectl delete -f cblog-${suffix}/
    microk8s.kubectl delete -f cgateway-${suffix}/
    microk8s.kubectl delete -f cstore-${suffix}/
    microk8s.kubectl delete -f namespace.yml
}

kustomize() {
    kubectl apply -k ./
}

scaffold() {
    // this will build the source and apply the manifests the K8s target. To turn the working directory
    // into a CI/CD space, initilaize it with `skaffold dev`
    skaffold run
}

[[ "$@" =~ ^-[fdks]{1}$ ]]  || usage;

while getopts ":fksd" opt; do
    case ${opt} in
    f ) echo "Applying default \`kubectl apply -f\`"; default ;;
    d ) echo "Applying delete_apps \`kubectl apply -f\`"; delete_apps ;;
    k ) echo "Applying kustomize \`kubectl apply -k\`"; kustomize ;;
    s ) echo "Applying using skaffold \`skaffold run\`"; scaffold ;;
    \? | * ) usage ;;
    esac
done

logSummary
