# Litecoin Spelunking

A basic/opinionated docker image for litecoin.


## Dockerfile

The [Dockerfile](Dockerfile) has been created with some specific ideas/criteria in mind. Specifically to not run as a priveleged user, to not make use of a script for the entrypoint, and to not modify any permissions or similar at runtime.

There are various helper targets in the [Makefile](Makefile) to help with building the Docker image. Specifically these are:

 - `docker`: responsible for actually building the docker image, which is tagged as `litecoin:latest`
 - `hadolint`: respondible for linting the [Dockerfile](Dockerfile) to help with best practices
 - `trivy`: for preforming a security/vulnerability scan of the resulting Docker image
 - `dive`: to help analyse the image for space efficiency


## Kubernetes manifest

The [deploy.yml](deploy.yml) manifest is supplied as an example for illustrative purposes only. It shows how to deploy the Docker image using a Kubernetes StatefulSet.

Again there are various helper targets in the [Makefile](Makefile) to help with linting the Kubernetes manifest, setting up a local Kubernetes cluster with KinD, and deploying the Docker image to the resulting cluster. Specifically these targets are:

 - `kube-score`: respondible for linting the [deploy.yml](deploy.yml) manifest to help with best practices
 - `kind-create`: responsible for creating a local Kubernets cluster with KinD
 - `kind-delete`: responsible for destroying the local KinD cluster
 - `kind-load-image`: for loading the Docker image into the local KinD cluster
 - `patch-deployment`: for updating the [deploy.yml](deploy.yml) manifest with the Docker image tag
 - `kind-deploy`: to help with deploying the [deploy.yml](deploy.yml) manifest to the KinD cluster
