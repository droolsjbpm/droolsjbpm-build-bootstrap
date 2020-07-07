#!/bin/bash -e

# checkout of cloned repositories to release branches
# parameters: releaseBranch = $1


./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $1