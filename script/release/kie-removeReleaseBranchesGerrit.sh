#!/bin/bash -e

# removes release branches on Gerrit since the tag is already on Gerrit
if [ "$target" == "productized" ]; then
  ./droolsjbpm-build-bootstrap/script/git-all.sh push origin :$releaseBranch
fi