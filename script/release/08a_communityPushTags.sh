#!/bin/bash -e

# pushes the tag to github for community releases

# in case that the community build takes several days the variable kieVersion gets some how unset
# the kieVersion is taken from a created file
kieVersion=$(cut -f1 kie.properties)

# create a tag
commitMsg="Tagging $1"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $kieVersion -m "$commitMsg"

# pushes tag to github kiegroup
./droolsjbpm-build-bootstrap/script/git-all.sh push origin $kieVersion