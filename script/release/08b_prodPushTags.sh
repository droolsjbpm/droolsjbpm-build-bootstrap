#!/bin/bash -e

# pushes the tag to github for community releases

# create a tag
commitMsg="Tagging $tagName"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $tagName -m "$commitMsg"

# pushes tag to github ¡/kiegroup
./droolsjbpm-build-bootstrap/script/git-all.sh push -n gerrit $tagName