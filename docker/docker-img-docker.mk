.PHONY: fm-$(BR_FMDEPS_VERSION)-docker
fm-$(BR_FMDEPS_VERSION)-docker: fm-$(BR_FMDEPS_VERSION)-os Dockerfile-docker
	@echo "[DOCKER] Building $@"
	$(Q)docker buildx build \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$@ \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$< \
		-f Dockerfile-docker .

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-docker
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-docker

.PHONY: fm-docker
fm-docker: fm-$(BR_FMDEPS_VERSION)-docker
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-docker

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-docker
endif
