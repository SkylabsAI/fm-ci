.PHONY: fm-$(BR_FMDEPS_VERSION)-base
fm-$(BR_FMDEPS_VERSION)-base: Dockerfile-fm-ci files/_br-fm-deps.opam
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build --pull \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$@ \
		--build-arg \
		  DOCKER_IMAGE_VERSION="fmdeps.${BR_FMDEPS_VERSION},image.${BR_IMAGE_VERSION}" \
		-f $< .
DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-base

GEN_FILES += files/_br-fm-deps.opam
files/_br-fm-deps.opam: ../fm-deps/br-fm-deps.opam
	$(Q)cp $< $@
