# Argo CD App Deployer

This repository contains some helpers to integrate Argo CD Application updates
with your CI system.

* ``mkkubeconfig`` is a tool to help generate a KUBECONFIG file from a
  ServiceAccount's credentials.
* ``deploy`` is a script that will attempt to update the tag for an
  Application's image.

## ``mkkubeconfig``

* Create a ServiceAccount:

  ```yaml
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: argocd-app-deployer
    namespace: argocd
  ```

* Create a Role with minimal privileges:

  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: argocd-app-deployer
    namespace: argocd
  rules:
  - apiGroups:
    - argoproj.io
    resources:
    - applications
    verbs:
    - get
    - update
    - patch
  ```

* Create a RoleBinding:

  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: argocd-app-deployer
    namespace: argocd
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: argocd-app-deployer
  subjects:
  - kind: ServiceAccount
    name: argocd-app-deployer
    namespace: argocd
  ```

* Generate a KUBECONFIG for the new ServiceAccount:

  ```shell
  $ KUBECONFIG_BODY=$(docker run --rm -v ~/.kube:/root/.kube:ro codekoala/argocd-app-deployer:v0.0.4 mkkubeconfig argocd argocd-app-deployer | base64 -w 0)
  ```

* Copy the encoded output and put it into your CI system. It could be as a
  variable that gets injected into your build environment, which you can then
  write out and use. For example:

  ```shell
  $ mkdir -p ~/.kube/
  $ echo "${KUBECONFIG_BODY}" | base64 -d > ~/.kube/config
  ```

## ``deploy``

* Attempt to deploy an update:

  ```shell
  $ docker run --rm -e KUBECONFIG_BODY="${KUBECONFIG_BODY}" codekoala/argocd-app-deployer:v0.0.4 deploy my-app v1.2.3
  ```
