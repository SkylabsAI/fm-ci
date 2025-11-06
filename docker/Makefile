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

include docker-login.mk
include docker-img-stage0.mk
include docker-img-stage0-llvm.mk
include docker-img-stage-release.mk
include docker-img-stage-release-misc.mk
include docker-img-basics.mk

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
