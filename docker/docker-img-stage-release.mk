monorepo_parent=../../../..
docker_build_folder=docker-opam-release

# XXX missing dependencies!
# Move this step into a control script instead!
GEN_FILES += $(monorepo_parent)/$(docker_build_folder)/files/workspace.tar
$(monorepo_parent)/$(docker_build_folder)/files/workspace.tar:
	cd $(monorepo_parent); mkdir -p $(docker_build_folder)/files; \
	  time ./workspace/fmdeps/fm-ci/docker/stable-tar.sh workspace $(docker_build_folder)/files/

CP = $(shell which gcp || which cp)
.PHONY: prepare-fm-release
prepare-fm-release: $(monorepo_parent)/$(docker_build_folder)/files/workspace.tar
	$(CP) -t $(monorepo_parent)/$(docker_build_folder)/files files/dune-config files/LICENSE files/opam-clean
	$(CP) -t $(monorepo_parent)/$(docker_build_folder) Dockerfile-opam-release

.PHONY: fm-$(BR_FMDEPS_VERSION)-release
fm-$(BR_FMDEPS_VERSION)-release: prepare-fm-release
	cd $(monorepo_parent)/$(docker_build_folder); \
	docker buildx build \
		-f Dockerfile-opam-release \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$(DEFAULT_TAG) \
		--build-arg ROCQ_LOG_PREFIX=bluerock \
		--build-arg \
		OPAM_PACKAGES='opam pin | grep -E "/fmdeps/(auto|BRiCk|vendored/(vscoq|coq-lsp))" | grep -E -v "rocq-bluerock-cpp-(demo|stdlib)"' \
		-t $(DOCKER_REPO):$@ \
		.
DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-release

.PHONY: fm-release
fm-release: fm-$(BR_FMDEPS_VERSION)-release
	$(call tag-target,$<,fm-release)
DOCKER_BUILD_TARGETS += fm-release

