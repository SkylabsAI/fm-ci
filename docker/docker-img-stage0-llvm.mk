define image-target
.PHONY: fm-$$(BR_FMDEPS_VERSION)-llvm-$1
fm-$$(BR_FMDEPS_VERSION)-llvm-$1: Dockerfile-llvm fm-$(BR_FMDEPS_VERSION)-base
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build --pull \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$$@ \
		--build-arg LLVM_MAJ_VER=$1 \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):fm-base \
		--build-arg \
		  DOCKER_IMAGE_VERSION="fmdeps.${BR_FMDEPS_VERSION},llvm.${LLVM_VER},image.${BR_IMAGE_VERSION}" \
		-f $$< .
DOCKER_BUILD_TARGETS += fm-$$(BR_FMDEPS_VERSION)-llvm-$1
endef

$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call image-target,$(llvm))))

DEFAULT_TAG := fm-$(BR_FMDEPS_VERSION)-llvm-$(LLVM_MAIN_VERSION)

.PHONY: fm-default
fm-default: $(DEFAULT_TAG)
	$(call tag-target,$<,fm-default)

DOCKER_BUILD_TARGETS += fm-default
