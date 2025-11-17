define llvm-img-target
.PHONY: fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2: fm-$(BR_FMDEPS_VERSION)-$1 Dockerfile-llvm
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$$@ \
		--build-arg LLVM_MAJ_VER=$2 \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$$< \
		--build-arg \
		  DOCKER_IMAGE_VERSION="fmdeps.${BR_FMDEPS_VERSION},llvm.${LLVM_VER},image.${BR_IMAGE_VERSION}" \
		-f Dockerfile-llvm .

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-$1-llvm-$2
endef
