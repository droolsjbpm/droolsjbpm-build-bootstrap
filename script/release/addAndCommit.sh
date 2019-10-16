#!/bin/bash -e

# upgrades the version to the release/tag version
# parameters: $commitMsg == $1, $kieVersion == $2
# git add and commit the version update changes
./droolsjbpm-build-bootstrap/script/git-all.sh add --all --ignore-errors
commitMsg="$1 $2"
./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "$commitMsg"