DOCKER_REGISTRY ?= ghcr.io
DOCKER_REPO ?= $(DOCKER_REGISTRY)/skylabsai/ci

# Bump the following number when pushing new images with the same version
# numbers. This is necessary to properly invalidate the NOVA cache.
BR_FMDEPS_VERSION ?= 2025-11-27
FM_RELEASE_FULL_VERSION = $(BR_FMDEPS_VERSION)

# Default RELEASE_TAG is the unversioned one
RELEASE_TAG ?= fm-release
LLVM_VERSIONS ?= 18 19 20 21 22
LLVM_MAX_VERSION ?= 22
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
