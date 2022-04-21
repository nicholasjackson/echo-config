DOCKER_REGISTRY ?= docker.io/nicholasjackson/echo-config
VERSION := 0.0.1

# Build and push the Arm64 and x64 images to the Docker registry
build_docker:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multi || true
	docker buildx use multi
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/arm64,linux/amd64 \
		-t ${DOCKER_REGISTRY}:${VERSION} \
    -f ./Dockerfile \
    .  \
		--push
	docker buildx rm multi

# Build a x64 images and import into the local registry
build_docker_dev:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multi || true
	docker buildx use multi
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64 \
		-t ${DOCKER_REGISTRY}:${VERSION}.dev \
    -f ./Dockerfile \
    . \
		--load
	docker buildx rm multi