.PHONY: fm-$(BR_FMDEPS_VERSION)-release
fm-$(BR_FMDEPS_VERSION)-release: fm-$(BR_FMDEPS_VERSION)-base-llvm-$(LLVM_MAIN_VERSION) prepare-fm-release
	$(call opam-img-target,grep -E "/fmdeps/(auto|BRiCk|vendored/(vscoq|coq-lsp))" | grep -E -v "rocq-bluerock-cpp-(demo|stdlib)")

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-release
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-release

.PHONY: fm-release
fm-release: fm-$(BR_FMDEPS_VERSION)-release
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-release

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-release
endif
