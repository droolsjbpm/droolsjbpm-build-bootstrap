#!/bin/bash -e

# checkout of cloned repositories to release branches
# parameters: releaseBranch = $1; baseBranch = $2


./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $1 $2