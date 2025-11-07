$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call image-target,$(llvm))))

.PHONY: fm-default
fm-default: fm-$(BR_FMDEPS_VERSION)-llvm-$(LLVM_MAIN_VERSION)
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-default

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-default
endif
