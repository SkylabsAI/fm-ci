.PHONY: fm-$(BR_FMDEPS_VERSION)-stage4-sl-release
fm-$(BR_FMDEPS_VERSION)-stage4-sl-release: fm-$(BR_FMDEPS_VERSION)-stage3-release-$(LLVM_MAIN_VERSION) prepare-fm-release
	$(call opam-img-target,\
	grep -E "(rocq-bluerock-cpp2v|rocq-bluerock-cpp-stdlib|rocq-brick-libstdcpp|rocq-bluerock-scaffold)")

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-stage4-sl-release
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-stage4-sl-release

.PHONY: fm-sl-release
fm-sl-release: fm-$(BR_FMDEPS_VERSION)-stage4-sl-release
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-sl-release

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-sl-release
endif
