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
	  cewood/litecoin:latest

.PHONY: dive
dive:
	docker \
	  run \
	  --rm \
	  -i \
	  -v /var/run/docker.sock:/var/run/docker.sock:ro \
	  -e CI=true \
	  wagoodman/dive:v0.10.0 \
	  cewood/litecoin:latest

.PHONY: docker
docker: .dockerimage

.dockerimage: Dockerfile
	docker \
	  build \
	  -t cewood/litecoin:latest \
	  .
	touch .dockerimage
