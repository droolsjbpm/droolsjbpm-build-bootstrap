#!/bin/bash -e

# checkout of cloned repositories to release branches
# parameters: $releaseBranch $baseBranch

./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $releaseBranch $baseBranch