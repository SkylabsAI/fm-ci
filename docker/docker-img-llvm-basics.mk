define llvm-img-target
.PHONY: fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2: fm-$(BR_FMDEPS_VERSION)-$1 Dockerfile-llvm
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$$@ \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$$< \
		--build-arg LLVM_MAJ_VER=$2 \
		-f Dockerfile-llvm .

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
endef
