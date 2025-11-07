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
