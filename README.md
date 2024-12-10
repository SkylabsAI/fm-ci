Centralized FM CI Setup
=======================

This repository documents and implements our centralized FM CI setup, based on
a standard `bhv` checkout.

## Common CI Configuration

The CI configuration for every FM repositories, including `fm-ci` (the current
repository), is almost always exactly the following.
```yaml
trigger:
  rules:
    - if: $CI_PIPELINE_SOURCE =~ /^(merge_request_event|schedule|wep|api)$/
      variables:
        FM_CI_TRIGGER_KIND: mr
    - if: $CI_PIPELINE_SOURCE == 'push' && $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:
        FM_CI_TRIGGER_KIND: default
  variables:
    ORIGIN_CI_COMMIT_SHA: $CI_COMMIT_SHA
    ORIGIN_CI_COMMIT_BRANCH: $CI_COMMIT_BRANCH
    ORIGIN_CI_MERGE_REQUEST_IID: $CI_MERGE_REQUEST_IID
    ORIGIN_CI_MERGE_REQUEST_LABELS: $CI_MERGE_REQUEST_LABELS
    ORIGIN_CI_MERGE_REQUEST_PROJECT_ID: $CI_MERGE_REQUEST_PROJECT_ID
    ORIGIN_CI_MERGE_REQUEST_SOURCE_BRANCH_NAME: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME
    ORIGIN_CI_MERGE_REQUEST_TARGET_BRANCH_NAME: $CI_MERGE_REQUEST_TARGET_BRANCH_NAME
    ORIGIN_CI_PIPELINE_SOURCE: $CI_PIPELINE_SOURCE
    ORIGIN_CI_PIPELINE_URL: $CI_PIPELINE_URL
    ORIGIN_CI_PROJECT_PATH: $CI_PROJECT_PATH
    ORIGIN_CI_PROJECT_TITLE: $CI_PROJECT_TITLE
    FM_CI_TRIGGER_KIND: $FM_CI_TRIGGER_KIND
  trigger:
    project: bedrocksystems/formal-methods/fm-ci
    branch: trigger-$FM_CI_TRIGGER_KIND
    strategy: depend
```

**Note:** due to the impossibility to trigger a pipeline on a different branch
of the same repository, the configuration for `fm-ci` (the current repository)
has an extra level of trigger. It first triggers a job on the `main` branch of
[ci-backfire](https://gitlab.com/bedrocksystems/formal-methods/ci-backfire),
which then "backfires" and performs the appropriate trigger on `fm-ci`.

### Trigger Branches

With the above configuration, CI in FM repository simply amounts to triggering
a job on `fm-ci` (the current repository). Note that such triggers only target
special "trigger branches", whose name is always prefixed by `trigger-`.

**Important notes:**
- Trigger branches should all be kept in sync, and point to the same commit.
- The CI configuration in trigger branches should be as simple as possible.
- Changes to trigger branches are harder to test, and should be avoided.

There are currently two trigger branches:
- `trigger-mr` which is target branch of merge request pipelines,
- `trigger-default` which is the target branch of main branch push pipelines.

The separation of target branches is needed because pushing to the main branch
of any FM repository eventually produces "golden artifacts". Such artifact are
thus retrievable with an API request for the latest successful pipeline on the
`trigger-default` branch. Currently, only NOVA relies on this mechanism, using
[the job artifact API](https://docs.gitlab.com/ee/api/job_artifacts.html).

### Variables

Triggers set environment variables identifying the originating repository, and
associated parameters like merge request labels. All variables **should follow
the following naming convention:**
- Any variable forwarded from the triggering job should have its standard name
  prefixed with `ORIGIN_`.
- All other variables should have a name prefixed with `FM_CI_`.

### CI Configuration Generation

The CI configuration in trigger branches is mostly responsible for dynamically
producing a CI configuration, based on the environment variables it receives.

The CI configuration is generated by checking out the relevant `fm-ci` commit,
and then running the following command.
```sh
dune exec -- ./gen/gen.exe ${CI_JOB_TOKEN} config.toml gen-config.yml
```
This program takes as input a GitLab token, configuration file `config.toml`,
and it outputs a YAML file `gen-config.yml` that is used in a child pipeline.

The `config.toml` file configures what FM repositories are available, as well
as their relative path in a `bhv` checkout, the name of their main branch, the
list of their immediate dependencies, and more. Available configurations are
documented in comments withing `config.toml`.

The generation process is documented in the various OCaml files, the main file
being `gen/gen.ml`.

## Support for `CI::same-branch`

The `CI::same-branch` label can be set in MRs of any FM repository, and it has
the effect of selecting branches of the same name as the MR branch for all the
FM repositories in the `bhv` checkout, if such a branch exists.

Note that when `fm-ci` (the current repository) has a branch of the same name,
the CI configuration in the trigger branches checks out that branch before the
generation script is run.

## Support for `FM-CI-Compare`

The `FM-CI-Compare` label can be set in MRs of any FM repository, so as to run
a performance comparison. The label only affects the main building job, called
`full-build-compare` when the label is set, and `full-build` otherwise.

When the label is set, the CI configuration generation script must determine a
reference branch for all involved repositories (either just the one triggering
the pipeline in the originating MR, or potentially several repositories if the
`CI::same-branch` label is also set). For other repositories, the reference is
simply their main branch (as specified in the configuration file). For all the
involved repositories, the reference commit is defined as the `git merge-base`
of the main branch and the MR branch.

The `full-build-compare` job proceeds as follows:
1. Clone `bhv` and checkout the branch for the main build.
2. Run `make init` and checkout the main build commits for all sub-repos.
3. Run the build, and copy the resulting `_build` folder.
4. Run `make gitclean` and checkout the reference build commits for all repos.
5. Run the build, and copy the resulting `_build` folder as well.
6. Run `make gitclean` again, and checkout the main build commits again.
7. Generate the performance data based on the two copied `_build` folders.

Note that step 3 is allowed to fail, but we remember its status so that we can
make the full job fail accordingly when the end of the job is reached. This is
useful to get partial performance data even if not all files build. Unlike the
main build, the reference build is not allowed to fail.

### Support for "Non-Main" MR Targets

When an MR targets a branch that is different from the configured repository's
main branch, the reference commit used for performance comparison is chosen to
be that of the target branch (or a merge base of that and the MR branch). When
`CI::same-branch` is set, the reference commit for repos that did not initiate
the MR is taken from a branch with the same name, if it exists. Otherwise, the
reference is taken to be the main branch.

## Adding new Repositories

Steps for adding new FM repositories:
1. Create a clone of the repository on Gitlab (probably under the 
   `formal-methods` group).
2. Create a protected `br-main` branch.
3. Add the repository to `bhv/boards/common/fm.mk`.
4. Add the repository's path to `bhv/.gitignore`.
5. Run `make clone` to check that everything works.
6. Add the repository to `fm-ci/config.toml` (do not forget to update the
   dependencies).
7. Add the repository to `fm-workspace`'s in `setup-fmdeps.sh` `FM_REPOS` (for external users).

In case of permission errors, go to `Settings` -> `CI/CD` -> `Job token 
permissions` and enable `All groups and projects`.

## Scheduled Pipelines

### Dune cache trimming

The `dune` cache is trimmed by a weekly pipeline.

It simply sets `FM_CI_TRIM_DUNE_CACHE=true`.

### SWI-Prolog versions

We test various versions of SWI-Prolog in weekly pipelins. These pipelines are
set to only run the `full-build` job (which covers both bhv and NOVA).

The following environment variables are set:
- `FM_CI_ONLY_FULL_BUILD=true` to only enable the `full-build` job,
- `FM_CI_DEFAULT_SWIPL=<version>` to select a specific SWI-prolog version.

### Release

A daily pipeline is used to release the public release docker image. This is
done by setting `DOCKER_RELEASE_MODE=true`, which disables standard CI jobs
and instead runs a special job building and publishing the CI image (see the
`.gitlab-ci.yml` file for details).

Infrastructure for building the release image is found in the `docker` folder.

## Possible improvements

### Support `CI::same-branch` When the Config Changes

This is only relevant when there is an `fm-ci` branch. In that case, we should
inspect the repos configuration of both `main`, and the branch, since they may
not have the same set of repositories.

The logic then needs to be changed in the `full-build-compare` job, so that we
run `make init` for `bhv` also for the reference build.
