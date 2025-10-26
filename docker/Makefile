# Pick default bash, even if it's installed with Homebrew.
SHELL := $(shell which bash)

DOCKER_REGISTRY ?= ghcr.io
DOCKER_REPO ?= $(DOCKER_REGISTRY)/skylabsai/workspace

BR_FMDEPS_VERSION ?= 2025-10-24
FM_RELEASE_FULL_VERSION = 2025-10-24
# FM_RELEASE_FULL_VERSION = $(BR_FMDEPS_VERSION)
# We keep $(BR_IMAGE_VERSION) purely internal.
# FM_RELEASE_FULL_VERSION = $(BR_FMDEPS_VERSION)-$(BR_IMAGE_VERSION)
RELEASE_TAG ?= fm-release-latest
# Bump the following number when pushing new images with the same version
# numbers. This is necessary to properly invalidate the NOVA cache.
BR_IMAGE_VERSION ?= 1
LLVM_VERSIONS ?= 18 19 20 21
LLVM_MAIN_VERSION ?= 19
I_KNOW_WHAT_I_AM_DOING ?= no
QUIET ?= true
FM_RELEASE_TARBALL_NAME = skylabs-fm-release-$(FM_RELEASE_FULL_VERSION)


# Checking the value of I_KNOW_WHAT_I_AM_DOING.
ifneq ($(I_KNOW_WHAT_I_AM_DOING),yes)
ifneq ($(I_KNOW_WHAT_I_AM_DOING),no)
$(error I_KNOW_WHAT_I_AM_DOING should be either "yes" or "no")
endif
endif

# Support for quiet build.
ifeq ($(QUIET),true)
Q := @
else
ifeq ($(QUIET),false)
Q :=
else
$(error QUIET should be either "true" or "false")
endif
endif

# Support for colors.
CYAN = 36
define color
	"\033[0;$1m$2\033[0m"
endef

all:
	@echo -e $(call color,$(CYAN),See README.md for documentation.)
.PHONY: all

files/_dune-project: ../fm-deps/dune-project
	$(Q)cp ../fm-deps/dune-project $@

files/_br-fm-deps.opam: ../fm-deps/dune-project
	$(Q)dune b --no-print-directory --display=quiet ../fm-deps/br-fm-deps.opam
	$(Q)cp ../fm-deps/br-fm-deps.opam $@

DOCKER_BUILD_TARGETS =
DOCKER_RUN_TARGETS =
DOCKER_PUSH_TARGETS =

.PHONY: FORCE
FORCE:

run-fm-%: fm-% FORCE
	@echo "[DOCKER] Running $<"
	$(Q)docker run -i -t $(DOCKER_REPO):$<

push-fm-%: fm-% FORCE
	@echo "[DOCKER] Pushing $<"
ifeq ($(I_KNOW_WHAT_I_AM_DOING),yes)
	@echo "(Let's hope you did not mess anything up...)"
	$(Q)docker push $(DOCKER_REPO):$<
else
	@echo "The command that would run would be:"
	@echo "  docker push $(DOCKER_REPO):$<"
	@echo -e $(call color,$(CYAN),Use I_KNOW_WHAT_I_AM_DOING=yes to actually run it)
endif

.PHONY: fm-$(BR_FMDEPS_VERSION)-base
fm-$(BR_FMDEPS_VERSION)-base: Dockerfile-fm-ci files/_br-fm-deps.opam files/_dune-project
	@echo "[DOCKER] Building $$@"
	$(Q)docker buildx build --pull \
		--platform linux/amd64 \
		-t $(DOCKER_REPO):$@ \
		--build-arg \
		  DOCKER_IMAGE_VERSION="fmdeps.${BR_FMDEPS_VERSION},image.${BR_IMAGE_VERSION}" \
		-f $< .
DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-base
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-base

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
DOCKER_RUN_TARGETS += run-fm-$$(BR_FMDEPS_VERSION)-llvm-$1
DOCKER_PUSH_TARGETS += push-fm-$$(BR_FMDEPS_VERSION)-llvm-$1
endef

$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call image-target,$(llvm))))

build: $(DOCKER_BUILD_TARGETS)
.PHONY: build

push: build $(DOCKER_PUSH_TARGETS)
.PHONY: push

list-targets:
	@echo "$(DOCKER_BUILD_TARGETS)" | tr ' ' '\n' | sort -V
	@echo "$(DOCKER_RUN_TARGETS)" | tr ' ' '\n' | sort -V
	@echo "$(DOCKER_PUSH_TARGETS)" | tr ' ' '\n' | sort -V
.PHONY: list-targets

DEFAULT_TAG := fm-$(BR_FMDEPS_VERSION)-llvm-$(LLVM_MAIN_VERSION)

define tag-target
	@echo "[DOCKER] Tagging $1 as $2"
	${Q}docker image tag $(DOCKER_REPO):$1 $(DOCKER_REPO):$2
endef

.PHONY: fm-default
fm-default: $(DEFAULT_TAG)
	$(call tag-target,$<,fm-default)

DOCKER_BUILD_TARGETS += fm-default
DOCKER_RUN_TARGETS += run-fm-default
DOCKER_PUSH_TARGETS += push-fm-default

github-login:
	@echo -n "Enter your GitHub login: "
	@read -r LOGIN; echo $$LOGIN > $@

github-token:
	@echo -e $(call color,$(CYAN),You need a GitHub personal access token (classic).)
	@echo "See https://github.com/settings/tokens."
	@echo "Select write:packages permission/scope when creating the token"
	@echo -n "Enter your personal access token: "
	@read -r TOKEN; echo $$TOKEN > $@

login: github-login github-token
	${Q}docker login -u $$(cat $<) --password-stdin $(DOCKER_REGISTRY) < github-token
.PHONY: login

logout:
	$(Q)docker logout $(DOCKER_REGISTRY)
.PHONY: logout

monorepo_parent=../../../..
docker_build_folder=docker-opam-release

# XXX missing dependencies!
# Move this step into a control script instead!
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
DOCKER_RUN_TARGETS += run-fm-$(BR_FMDEPS_VERSION)-release
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-release

.PHONY: fm-release
fm-release: fm-$(BR_FMDEPS_VERSION)-release
	$(call tag-target,$<,fm-release)
DOCKER_BUILD_TARGETS += fm-release
DOCKER_RUN_TARGETS += run-fm-release
DOCKER_PUSH_TARGETS += push-fm-release

pull-release:
	$(Q)docker pull $(DOCKER_REPO):$(RELEASE_TAG)

.PHONY: pull-release

PV = $(if $(shell which pv),pv,cat)

ver-release:
	@echo $(FM_RELEASE_FULL_VERSION)
name-release:
	@echo $(FM_RELEASE_TARBALL_NAME)

$(FM_RELEASE_TARBALL_NAME).tar.gz:
	docker save $(DOCKER_REPO):$(RELEASE_TAG) | $(PV) | gzip > "$@"

pack-release: $(FM_RELEASE_TARBALL_NAME).tar.gz
.PHONY: pack-release

unpack-release:
	$(PV) $(FM_RELEASE_TARBALL_NAME).tar.gz | docker load
.PHONY: unpack-release

clean:
	@rm -f files/_br-fm-deps.opam files/_dune-project files/fm-artifact.zip
.PHONY: clean

clean-all: clean
	@rm -f gitlab-token gitlab-login
.PHONY: clean-token

system-prune:
	@docker system prune
.PHONY: system-prune
