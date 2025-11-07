.PHONY: pull-release
pull-release:
	$(Q)docker pull $(DOCKER_REPO):$(RELEASE_TAG)

PV = $(if $(shell which pv),pv,cat)

ver-release:
	@echo $(FM_RELEASE_FULL_VERSION)
name-release:
	@echo $(FM_RELEASE_TARBALL_NAME)

$(FM_RELEASE_TARBALL_NAME).tar.gz:
	docker save $(DOCKER_REPO):$(RELEASE_TAG) | $(PV) | gzip > "$@"

.PHONY: pack-release
pack-release: $(FM_RELEASE_TARBALL_NAME).tar.gz

.PHONY: unpack-release
unpack-release:
	$(PV) $(FM_RELEASE_TARBALL_NAME).tar.gz | docker load
