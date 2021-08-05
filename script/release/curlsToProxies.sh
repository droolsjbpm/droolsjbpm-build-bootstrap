#!/bin/bash
# version of the KIE artefacts
kieVersion=$1
# repositories can be kie-group (internal staging reps on Nexus) or public-jboss (released repositories on Nexus)
repositories=$2

SUFFIX_LIST='business-central business-central-webapp business-monitoring-webapp jbpm-server-distribution'
for suffix in $SUFFIX_LIST ; do
  BINARY_LIST=$(curl https://origin-repository.jboss.org/nexus/content/groups/$repositories/org/kie/$suffix/$kieVersion/ | grep href=.*$suffix | sed "s/.*\".*"$suffix".*\/\(.*\)\".*/\1/p" | uniq)
  for artefact in $BINARY_LIST ; do
    curl --head https://proxy01-repository.jboss.org/nexus/content/groups/$repositories/org/kie/$suffix/$kieVersion/$artefact
    curl --head https://proxy02-repository.jboss.org/nexus/content/groups/$repositories/org/kie/$suffix/$kieVersion/$artefact
  done
done