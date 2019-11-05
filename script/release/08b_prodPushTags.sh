#!/bin/bash -e

# pushes the tag to github for community releases
# tagName = $1

# create a tag
commitMsg="Tagging $1"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $1 -m "$commitMsg"

# pushes tag to github ¡/kiegroup
./droolsjbpm-build-bootstrap/script/git-all.sh push -n gerrit $1