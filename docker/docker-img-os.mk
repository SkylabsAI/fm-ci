.PHONY: fm-$(BR_FMDEPS_VERSION)-os
fm-$(BR_FMDEPS_VERSION)-os: Dockerfile-os
	@echo "[DOCKER] Building $@"
	$(Q)docker buildx build --pull \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$@ \
		-f $< .
DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-os
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-os

.PHONY: fm-os
fm-os: fm-$(BR_FMDEPS_VERSION)-os
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-os

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-os
endif
