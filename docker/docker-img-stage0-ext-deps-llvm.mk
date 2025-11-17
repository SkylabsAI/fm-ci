$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call llvm-img-target,base,$(llvm))))

.PHONY: fm-default
fm-default: fm-$(BR_FMDEPS_VERSION)-base-llvm-$(LLVM_MAIN_VERSION)
	$(call tag-target,$<,$@)

DOCKER_BUILD_TARGETS += fm-default

ifeq ($(TAG_DEFAULTS),yes)
DOCKER_PUSH_TARGETS += push-fm-default
endif
