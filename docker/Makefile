# Pick default bash, even if it's installed with Homebrew.
SHELL := $(shell which bash)

include config.mk

.PHONY: all
all:
	@echo -e $(call color,$(CYAN),See README.md for documentation.)

.PHONY: FORCE
FORCE:

DOCKER_BUILD_TARGETS =
DOCKER_RUN_TARGETS = $(foreach i,$(DOCKER_BUILD_TARGETS),run-$(i))
DOCKER_PUSH_TARGETS = $(foreach i,$(DOCKER_BUILD_TARGETS),push-$(i))

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

.PHONY: clean
clean:
	@rm -f files/_br-fm-deps.opam files/_dune-project files/fm-artifact.zip

.PHONY: clean-token
clean-all: clean
	@rm -f gitlab-token gitlab-login

.PHONY: system-prune
system-prune:
	@docker system prune
