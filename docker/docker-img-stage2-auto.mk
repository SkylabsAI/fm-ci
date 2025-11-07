.PHONY: fm-$(BR_FMDEPS_VERSION)-stage2
fm-$(BR_FMDEPS_VERSION)-stage2: fm-$(BR_FMDEPS_VERSION)-stage1 prepare-fm-release
	$(call opam-img-target,\
	grep -E "/fmdeps" | \
	grep -E -v "(/fmdeps/(skylabs-fm|vendored)|rocq-bluerock-cpp2v|rocq-bluerock-cpp-stdlib|rocq-brick-libstdcpp|rocq-bluerock-scaffold)")

DOCKER_BUILD_TARGETS += fm-$(BR_FMDEPS_VERSION)-stage2
DOCKER_PUSH_TARGETS += push-fm-$(BR_FMDEPS_VERSION)-stage2
