#!/bin/bash -e

# pushes the community release branches to github [remote = origin]
# the push of release branches to Gerrit [only for product tags] is not any more needed
# parameters: releaseBranch= $1

./droolsjbpm-build-bootstrap/script/git-all.sh push origin $1