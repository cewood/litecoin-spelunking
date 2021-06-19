GIT_REVISION = $(or $(shell printenv GIT_REVISION), $(shell git describe --match= --always --abbrev=7 --dirty))
IMAGE        = $(or $(shell printenv IMAGE),docker.io/cewood/litecoin)
IMAGE_TAG    = $(or $(shell printenv IMAGE_TAG),${TAG_REVISION})
TAG_REVISION = $(or $(shell printenv TAG_REVISION),${GIT_REVISION})



.PHONY: hadolint
hadolint:
	docker \
	  run \
	  --rm \
	  -i \
	  hadolint/hadolint:v2.5.0 \
	  < Dockerfile

.PHONY: trivy
trivy:
	docker \
	  run \
	  --rm \
	  -i \
	  -v /var/run/docker.sock:/var/run/docker.sock:ro \
          -v ${PWD}/.cache:/root/.cache/ \
	  aquasec/trivy:0.18.3 \
	  --severity HIGH,CRITICAL \
	  ${IMAGE}:${IMAGE_TAG}

.PHONY: dive
dive:
	docker \
	  run \
	  --rm \
	  -i \
	  -v /var/run/docker.sock:/var/run/docker.sock:ro \
	  -e CI=true \
	  wagoodman/dive:v0.10.0 \
	  ${IMAGE}:${IMAGE_TAG}

.PHONY: docker
docker: .dockerimage

.dockerimage: Dockerfile Makefile
	docker \
	  build \
	  -t ${IMAGE}:${IMAGE_TAG} \
	  .
	touch .dockerimage

.PHONY: kind-create
kind-create:
	kind \
	  create \
	  cluster \
	  --name litecoin \
	  --config kind.conf

.PHONY: kind-delete
kind-delete:
	kind \
	  delete \
	  cluster \
	  --name litecoin

.PHONY: kind-load-image
kind-load-image:
	kind \
	  load \
	  docker-image \
	  ${IMAGE}:${IMAGE_TAG} \
	  --name litecoin

.PHONY: patch-deployment
patch-deployment:
	sed \
	  -i \
	  -E 's/($(subst /,\/,${IMAGE}):).*/\1${GIT_REVISION}/g' \
	  deploy.yml

.PHONY: kind-deploy
kind-deploy: docker kind-load-image patch-deployment
	kubectl \
	  apply \
	  --validate=true \
	  --wait=true \
	  -f deploy.yml

.PHONY: kube-score
kube-score:
	docker \
	  run \
	  --rm \
	  -v ${PWD}:/project zegl/kube-score:v1.10.0 \
	  score \
	  deploy.yml

.PHONY: kubeval
kubeval:
	docker \
	  run \
	  --rm \
	  -it \
	  -v ${PWD}:/workdir garethr/kubeval:0.15.0 \
	  /workdir/deploy.yml
