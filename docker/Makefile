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

define push-msg
	@echo "[DOCKER] Pushing $(1)"
endef

ifeq ($(I_KNOW_WHAT_I_AM_DOING),yes)
define push-target
	$(call ${push-msg}, $1)
	@echo "(Let's hope you did not mess anything up...)"
	$(Q)docker push $(DOCKER_REPO):$(1)
endef
else
define push-target
	$(call ${push-msg}, $1)
	@echo "The command that would run would be:"
	@echo "  docker push $(DOCKER_REPO):$(1)"
	@echo -e $(call color,$(CYAN),Use I_KNOW_WHAT_I_AM_DOING=yes to actually run it)
endef
endif

define image-target
fm-$$(BR_FMDEPS_VERSION)-llvm-$1: Dockerfile-fm-ci files/_br-fm-deps.opam files/_dune-project
	@echo "[DOCKER] Building $$@"
	$$(Q)docker buildx build --pull \
		--platform linux/amd64 \
		-t $$(DOCKER_REPO):$$@ \
		--build-arg BR_FMDEPS_VERSION=$$(BR_FMDEPS_VERSION) \
		--build-arg BR_IMAGE_VERSION=$$(BR_IMAGE_VERSION) \
		--build-arg BR_LLVM_MAJ_VER=$1 \
		-f $$< .
.PHONY: fm-$$(BR_FMDEPS_VERSION)-llvm-$1
DOCKER_BUILD_TARGETS += fm-$$(BR_FMDEPS_VERSION)-llvm-$1

run-fm-$$(BR_FMDEPS_VERSION)-llvm-$1: fm-$$(BR_FMDEPS_VERSION)-llvm-$1
	@echo "[DOCKER] Running $$<"
	$$(Q)docker run -i -t $$(DOCKER_REPO):$$<
.PHONY: run-fm-$$(BR_FMDEPS_VERSION)-llvm-$1
DOCKER_RUN_TARGETS += run-fm-$$(BR_FMDEPS_VERSION)-llvm-$1

push-fm-$$(BR_FMDEPS_VERSION)-llvm-$1: fm-$$(BR_FMDEPS_VERSION)-llvm-$1
	$(call push-target,$$<)
.PHONY: push-fm-$$(BR_FMDEPS_VERSION)-llvm-$1
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

tag-default: $(DEFAULT_TAG)
	@echo "[DOCKER] Tagging $< as fm-default"
	@docker image tag $(DOCKER_REPO):$< $(DOCKER_REPO):fm-default
.PHONY: tag-default

run-default: tag-default
	@echo "[DOCKER] Running fm-default"
	$(Q)docker run -i -t $(DOCKER_REPO):fm-default
.PHONY: run-default

push-default: tag-default
	$(call push-target,fm-default)

.PHONY: push-default

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

TAR = $(shell which gtar || which tar)
$(monorepo_parent)/$(docker_build_folder)/files/skylabs-fm.tar:
	cd $(monorepo_parent); mkdir -p $(docker_build_folder)/files; time $(TAR) cf $(docker_build_folder)/files/skylabs-fm.tar skylabs-fm/

CP = $(shell which gcp || which cp)
.PHONY: prepare-release
prepare-release: $(monorepo_parent)/$(docker_build_folder)/files/skylabs-fm.tar
	$(CP) -t $(monorepo_parent)/$(docker_build_folder)/files files/dune-config files/LICENSE files/opam-clean
	$(CP) -t $(monorepo_parent)/$(docker_build_folder) Dockerfile-opam-release

.PHONY: build-release
build-release: prepare-release
	cd $(monorepo_parent)/$(docker_build_folder); \
	docker buildx build \
		-f Dockerfile-opam-release \
		--build-arg BASE_REPO="$(DOCKER_REPO)" \
		--build-arg BASE_TAG=fm-default \
		-t $(DOCKER_REPO):$(RELEASE_TAG) \
		.

.PHONY: run-release
run-release: build-release
	@echo "[DOCKER] Running fm-release"
	$(Q)docker run -i -t $(DOCKER_REPO):$(RELEASE_TAG)

push-release: build-release
	$(call push-target,$(RELEASE_TAG))
.PHONY: push-release

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
