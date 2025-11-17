.PHONY: fm-$(BR_FMDEPS_VERSION)-stage1
fm-$(BR_FMDEPS_VERSION)-stage1: fm-$(BR_FMDEPS_VERSION)-base prepare-fm-release
	$(call opam-img-target,grep -E /fmdeps/vendored | grep -v rocq-test-suite)

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-stage1
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-stage1
