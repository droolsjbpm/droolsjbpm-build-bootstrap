#!/bin/bash

set -euxo pipefail

# ***************************************************************************
#                                                                           *
# This script branches and upgrades to the next SNAPSHOT version            *
# the repositories                                                          *
#   kie-docker-ci-images (https://github.com/kiegroup/kie-docker-ci-images) *
#   kie-benchmarks (https://github.com/kiegroup/kie-benchmarks)             *
#   kie-cloud-test (https://github.com/kiegroup/kie-cloud-tests)            *
# These repositories are not in the repository-list.txt, but an upgrade and *
# a branching is needed.                                                    *
#                                                                           *
# ***************************************************************************

countSNAPHOTS (){
   # count pom.xml files with SNAPSHOT version
   pomsWithSnapshotVersionCount=$(grep snapshot -rli --include=pom.xml --exclude-dir=src | wc -l)
}

countChanges (){
      # count number of files changed in git
   changedFilesCount=$(git status -s | wc -l)
}

checkDiff (){
   if [ "$changedFilesCount" -gt "$pomsWithSnapshotVersionCount" ]; then
      echo "Version upgrade of $repo failed."
      echo "Expected number of changed poms ($changedFilesCount) to be <= number of poms containing SNAPSHOT version ($pomsWithSnapshotVersionCount)"
      exit 1
   fi
}

cloneBranch (){
   git clone git@github.com:kiegroup/"$repo".git
   cd "$repo"
}

checkoutNewBranch (){
   git checkout -b "$newBranch" master
}

commitBranch () {
   git add .
   git commit -m "upgraded to next SNAPSHOT"
}

pushBranch () {
   git push origin master
}

pushBranches () {
   git push origin master
   git push origin "$newBranch"
}

updateVersion-kie-docker-ci-images () {
  ./scripts/update-versions.sh "$newSNAPSHOT" -U
}

updateVersion-kie-benchmarks () {
  # upgrade the versions to next SNAPSHOT
  mvn -B -N -e versions:update-parent -Dfull -DparentVersion="[$newSNAPSHOT]" -DallowSnapshots=true -DgenerateBackupPoms=false
  mvn -B -N -e versions:update-child-modules -Dfull -DallowSnapshots=true -DgenerateBackupPoms=false
  # do manual changes to pom files that were not changed in version upgrade
  sed -i "s/<version>$oldSNAPSHOT<\/version>/<version>$newSNAPSHOT<\/version>/;P;D" jbpm-benchmarks/kieserver-assets/pom.xml
  sed -i "s/$oldSNAPSHOT/$newSNAPSHOT/g" jbpm-benchmarks/kieserver-performance-tests/src/main/java/org/jbpm/test/performance/kieserver/KieServerClient.java
}

updateVersion-kie-cloud-tests () {
  # upgrade the versions to the next SNAPSHOT
  mvn -B -N -e versions:update-parent -Dfull -DparentVersion="[$newSNAPSHOT]" -DallowSnapshots=true -DgenerateBackupPoms=false
  mvn -B -N -e versions:update-child-modules -Dfull -DallowSnapshots=true -DgenerateBackupPoms=false
}

# ******************** kie-docker-ci-images ************************************
repo="kie-docker-ci-images"

if [ "$proc" == "oneBranch" ] ;then
  cloneBranch
  countSNAPHOTS
  updateVersion-kie-docker-ci-images
  countChanges
  checkDiff
  commitBranch
  pushBranch
else
  cloneBranch
  countSNAPHOTS
  updateVersion-kie-docker-ci-images
  countChanges
  checkDiff
  commitBranch
  checkoutNewBranch
  newSNAPSHOT=$newBranchSNAPSHOT
  updateVersion-kie-docker-ci-images
  countChanges
  checkDiff
  commitBranch
  pushBranches
fi


# ******************** kie-benchmarks ************************************

repo="kie-benchmarks"

if [ "$proc" == "oneBranch" ] ;then
  cloneBranch
  updateVersion-kie-benchmarks
  commitBranch
  pushBranch
else
  cloneBranch
  updateVersion-kie-benchmarks
  commitBranch
  checkoutNewBranch
  oldSNAPSHOT=$newSNAPSHOT
  newSNAPSHOT=$newBranchSNAPSHOT
  updateVersion-kie-benchmarks
  commitBranch
  pushBranches
fi

# ********************* kie-cloud-tests ***********************************

repo="kie-cloud-tests"

if [ "$proc" == "oneBranch" ] ;then
  cloneBranch
  countSNAPHOTS
  updateVersion-kie-cloud-tests
  countChanges
  checkDiff
  commitBranch
  pushBranch
else
  cloneBranch
  countSNAPHOTS
  updateVersion-kie-cloud-tests
  countChanges
  checkDiff
  commitBranch
  checkoutNewBranch
  newSNAPSHOT=$newBranchSNAPSHOT
  updateVersion-kie-cloud-tests
  countChanges
  checkDiff
  commitBranch
  pushBranches
fi