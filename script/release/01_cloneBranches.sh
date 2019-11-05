#!/bin/bash -e

# clones all reps depending on $baseBranch
# parameter: baseBranch = $1

# clone all repos except droolsjbpm-build-bootstrap as this is supposed to be cloned before this script and has to be available
./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $1 --depth 70