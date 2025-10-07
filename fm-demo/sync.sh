#!/bin/sh -vxe

# "Configuration"
skeleton_path=$PWD/skeleton
BHV=$(realpath $PWD/../../../)
docker_path=$(realpath $PWD/../docker)

usage() {
  echo ""
}
if [ $# -lt 1 ]; then
  usage
  exit 1
fi

cd $(dirname "$0")
target_parent="$1"
shift

release_ver=$(make -C ${docker_path} ver-release)
docker_name=bluerock-fm-release-${release_ver}.tar.gz
docker_target_name=bluerock-fm-release.tar.gz
target_dir_name=bluerock-fm-demo-${release_ver}
target=${target_parent}/${target_dir_name}
target_tarball=${target}.tar.gz
# Path inside container -- chosen to match VsCode one
demo_mount_point=/workspaces/${target_dir_name}
# Tag for docker image
img_name=registry.gitlab.com/bedrocksystems/formal-methods/fm-ci:fm-opam-release-latest

echo ">>> Assembling release ${release_ver} in path ${target} and tarball ${target_tarball}"

# Prepare target
mkdir -p ${target}
cd ${target}

# Sync our skeleton, and preserve demos
# Getting ${exclusions} correct is optional but reduces noise/extra work when rerunning the script
exclusions="--exclude rocq-bluerock-cpp-demo --exclude rocq-bluerock-cpp-stdlib --exclude flags --exclude docker --exclude ${docker_target_name} --exclude _build"
rsync -avc --copy-unsafe-links --delete ${exclusions} ${skeleton_path}/ ${target}/ "$@"

# Package our demos
rsync -avc --delete --delete-excluded ${BHV}/fmdeps/cpp2v/rocq-bluerock-cpp-demo . "$@"
#rsync -avc --delete --delete-excluded --exclude theories ${BHV}/fmdeps/cpp2v/rocq-bluerock-cpp-stdlib . "$@"
rsync -avc --delete --delete-excluded ${BHV}/fmdeps/cpp2v/rocq-bluerock-cpp-stdlib . "$@"
rsync -avc --delete --delete-excluded ${BHV}/fmdeps/cpp2v/flags/ flags/ "$@"
ln -sf ../../cpp2v-dune-gen.sh rocq-bluerock-cpp-demo/proof/
ln -sf ../../cpp2v-dune-gen.sh rocq-bluerock-cpp-stdlib/theories/
ln -sf ../../cpp2v-dune-gen.sh rocq-bluerock-cpp-stdlib/tests/

# Generate CoqProject
cat ${BHV}/fmdeps/fm-ci/fm-demo/_CoqProject.flags > _CoqProject
echo >> _CoqProject
${BHV}/support/gather-coq-paths.py `find . -name dune` >> _CoqProject

docker run -v ${target}:${demo_mount_point} --rm -it ${img_name} bash -l -c \
       "cd ${demo_mount_point}; dune build"

# Alternatively, do the build directly because we are inside the container?
# cd ${demo_mount_point}; dune build

# Copy docker image inside container (if we're not building a shrunk tarball)

if [ -f ${docker_path}/${docker_name} ]; then
  rsync -av ${docker_path}/${docker_name} ${docker_target_name} "$@"
else
  echo "Docker image missing! Building source-only tarball."
  echo "If you want to change this, run the following then re-run this script:"
  echo "  make -C ../docker pack-release"
fi

cd ${target_parent}
time tar czf ${target_tarball} ${target_dir_name}
