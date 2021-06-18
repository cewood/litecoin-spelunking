# Litecoin Spelunking

A basic/opinionated docker image for litecoin.


## Dockerfile

The [Dockerfile](Dockerfile) has been created with some specific ideas/criteria in mind. Specifically to not run as a priveleged user, to not make use of a script for the entrypoint, and to not modify any permissions or similar at runtime.

There are various helper targets in the [Makefile](Makefile) to help with building the Docker image. Specifically these are:

 - `docker`: responsible for actually building the docker image, which is tagged as `litecoin:latest`
 - `hadolint`: respondible for linting the [Dockerfile](Dockerfile) to help with best practices
 - `trivy`: for preforming a security/vulnerability scan of the resulting Docker image
 - `dive`: to help analyse the image for space efficiency
