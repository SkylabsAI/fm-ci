# Pick default bash, even if it's installed with Homebrew.
SHELL := $(shell which bash)

include config.mk

.PHONY: all
all:
	@echo -e $(call color,$(CYAN),See README.md for documentation.)

.PHONY: FORCE
FORCE:

GEN_FILES =

DOCKER_BUILD_TARGETS =
DOCKER_RUN_TARGETS = $(foreach i,$(DOCKER_BUILD_TARGETS),run-$(i))
DOCKER_PUSH_TARGETS =

define tag-target
	@echo "[DOCKER] Tagging $1 as $2"
	${Q}docker image tag $(DOCKER_REPO):$1 $(DOCKER_REPO):$2
endef

monorepo_parent=../../../..
docker_build_folder=docker-opam-release
ROCQ_LOG_PREFIX=bluerock

define opam-img-target
	cd $(monorepo_parent)/$(docker_build_folder); \
	docker buildx build \
		-f Dockerfile-opam-release \
		--build-arg BASE_IMAGE=$(DOCKER_REPO):$< \
		--build-arg ROCQ_LOG_PREFIX=$(ROCQ_LOG_PREFIX) \
		--build-arg OPAM_PACKAGES='opam pin | $1' \
		-t $(DOCKER_REPO):$@ \
		.
endef

include docker-login.mk
include docker-img-llvm-basics.mk
include docker-img-stage0.mk
include docker-img-stage0-llvm.mk
include docker-img-tarball.mk
include docker-img-basics.mk

# Shared between release
include docker-img-stage-release-misc.mk
# "Old" release, single Opam layer
include docker-img-stage-release.mk
# "New" release, multiple Opam layers, not yet ready
# TODO enable
# include docker-img-stage1-vendored.mk
# include docker-img-stage2-auto.mk
# include docker-img-stage2-auto-llvm.mk
# include docker-img-stage3-cpp2v.mk
# include docker-img-stage4-skylabs.mk

.PHONY: build
build: $(DOCKER_BUILD_TARGETS)

.PHONY: push
push: build $(DOCKER_PUSH_TARGETS)

.PHONY: list-targets
list-targets:
	@echo "$(DOCKER_BUILD_TARGETS)" | tr ' ' '\n' | sort -V
	@echo "$(DOCKER_RUN_TARGETS)" | tr ' ' '\n' | sort -V
	@echo "$(DOCKER_PUSH_TARGETS)" | tr ' ' '\n' | sort -V
	@echo -e "\n*** Pass TAG_DEFAULTS=yes to overwrite default-tags when pushing. ***"

.PHONY: clean-all
clean-all: clean clean-token

.PHONY: clean
clean:
	$(Q)rm -f $(GEN_FILES)

.PHONY: system-prune
system-prune:
	@docker system prune
