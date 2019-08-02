#!/bin/sh
# How to clean ignores in revapi-config.json files:
#
# export REVAPI_REPOSITORIES=droolsjbpm-build-bootstrap,droolsjbpm-knowledge,drools,jbpm,droolsjbpm-integration,optaplanner
#
# ./git-clone-others.sh --repo-list=$REVAPI_REPOSITORIES --add-upstream-remote
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES checkout master
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES pull --rebase upstream master
# ./git-all.sh --repo-list=$REVAPI_REPOSITORIES checkout -b revapi-7.23.0.Final
# Copy this script to root of all repositories and run it there, ./revapi-clean.sh 7.23.0.Final
# Update <revapi.oldKieVersion> in kie-parent
# ./mvn-all.sh --repo-list=$REVAPI_REPOSITORIES clean install -DskipTests
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
fi
