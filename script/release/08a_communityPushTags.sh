#!/bin/bash -e

# pushes the tag to github for community releases

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

# create a tag
commitMsg="Tagging $kieVersion"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $kieVersion -m "$commitMsg"

# pushes tag to github kiegroup
./droolsjbpm-build-bootstrap/script/git-all.sh push origin $kieVersion