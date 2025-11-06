define image-target
.PHONY: fm-$(BR_FMDEPS_VERSION)-llvm-$1
fm-$(BR_FMDEPS_VERSION)-llvm-$1: fm-$(BR_FMDEPS_VERSION)-base Dockerfile-llvm
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$$@ \
		--build-arg LLVM_MAJ_VER=$1 \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$$< \
		--build-arg \
		  DOCKER_IMAGE_VERSION="fmdeps.${BR_FMDEPS_VERSION},llvm.${LLVM_VER},image.${BR_IMAGE_VERSION}" \
		-f Dockerfile-llvm .

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-llvm-$1
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-llvm-$1
endef

$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call image-target,$(llvm))))

.PHONY: fm-default
fm-default: fm-$(BR_FMDEPS_VERSION)-llvm-$(LLVM_MAIN_VERSION)
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-default

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-default
endif
