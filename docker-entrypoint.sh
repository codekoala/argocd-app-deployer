#!/bin/sh

KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
ARGOCD_NAMESPACE=${ARGOCD_NAMESPACE:-argocd}
ARGOCD_APP_ENV=${ARGOCD_APP_ENV:-test}
ARGOCD_APP_NAME=""
# ARGOCD_IMAGE_TAG=""

if [ -z "${ARGOCD_APP_NAME}" ] && [ -z "${ARGOCD_APP}" ]; then
    echo "Required environment variable ARGOCD_APP_NAME not set"
    exit 1
fi

if [ -z "${ARGOCD_IMAGE_TAG}" ]; then
    echo "Required environment variable ARGOCD_IMAGE_TAG not set"
    exit 1
fi

if [ ! -e "${KUBECONFIG}" ]; then
    if [ -z "${KUBECONFIG_BODY}" ]; then
        echo "Please set the KUBECONFIG_BODY environment variable to a base64-encoded YAML file"
        exit 1
    fi

    mkdir -p $(dirname "${KUBECONFIG}")
    echo "${KUBECONFIG_BODY}" | base64 -d > "${KUBECONFIG}"
fi

app="${ARGOCD_APP:-"${ARGOCD_APP_ENV}-${ARGOCD_APP_NAME}"}"
patch=$(cat <<EOT
[{
    "op": "replace",
    "path": "/spec/source/componentParameterOverrides/0/value",
    "value": "${ARGOCD_IMAGE_TAG}"
}, {
    "op": "replace",
    "path": "/spec/source/kustomize/imageTags/0/value",
    "value": "${ARGOCD_IMAGE_TAG}"
}]
EOT
)

kubectl --namespace "${ARGOCD_NAMESPACE}" patch app "${app}" --type=json --patch="${patch}"
