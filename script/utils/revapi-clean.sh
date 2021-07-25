#!/bin/sh
# How to clean ignores in revapi-config.json files:
#
# export MAIN_REVAPI_REPOSITORIES=droolsjbpm-build-bootstrap,appformer,droolsjbpm-knowledge,drools,jbpm,droolsjbpm-integration
# export BRANCHED_7_REVAPI_REPOSITORIES=optaplanner
# export REVAPI_REPOSITORIES=$MAIN_REVAPI_REPOSITORIES,$BRANCHED_7_REVAPI_REPOSITORIES
#
# ./git-clone-others.sh --repo-list=$REVAPI_REPOSITORIES --add-upstream-remote
# ./git-all.sh --repo-list=$MAIN_REVAPI_REPOSITORIES checkout main
# ./git-all.sh --repo-list=$MAIN_REVAPI_REPOSITORIES pull --rebase upstream main
# ./git-all.sh --repo-list=$BRANCHED_7_REVAPI_REPOSITORIES checkout 7.x
# ./git-all.sh --repo-list=$BRANCHED_7_REVAPI_REPOSITORIES pull --rebase upstream 7.x
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES checkout -b revapi-7.23.0.Final
# Copy this script to root of all repositories and run it there, ./revapi-clean.sh 7.23.0.Final
# ./mvn-all.sh --repo-list=$REVAPI_REPOSITORIES clean install -DskipTests -Dskip.npm -Dskip.yarn -Dgwt.compiler.skip
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES add -u
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES commit -m "BAQE-1039 - Change revapi to check against 7.23.0.Final"
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES push origin revapi-7.23.0.Final
# Create PRs
# Utility script for removing ignores in revapi-config.json files.

usage ()
{
  echo "################################## Revapi clean ##################################"
  echo "Usage : `basename $0` <finalCommunityVersionToCheckAgainst>"
  echo "        for example: ./`basename $0` 7.0.0.Final"
  echo "        OR"
  echo "        `basename $0` -h for help"
  echo "##################################################################################"
  exit
}

getopts :h opt

if [ "$opt" == "h" ]; then
    usage
elif [ "$#" -ne 1 ]; then
    usage
else
    # First, delete ignores
    find . -iname "revapi-config.json" -exec perl -i -0pe 's/("ignore":.*?)\[.*\]/\1\[\]/s' {} \;
    # Secondly, change versions in the comment
    find . -iname "revapi-config.json" -exec perl -i -0pe "s/(\"Changes between).*(and the current branch.)/\1 $1 \2/s" {} \;
    # Lastly, update "revapi.oldKieVersion" property in kie-parent pom.xml file only
    perl -i -0pe "s/<revapi.oldKieVersion>.*<\/revapi.oldKieVersion>/<revapi.oldKieVersion>$1<\/revapi.oldKieVersion>/s" droolsjbpm-build-bootstrap/pom.xml
fi
