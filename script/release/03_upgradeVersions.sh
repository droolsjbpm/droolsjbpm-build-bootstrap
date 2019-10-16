#!/bin/bash -e

# upgrades the version to the release/tag version
# parameters: $kieVersion == $1
./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $1 custom


#droolsjbpm-build-bootstrap
cd droolsjbpm-build-bootstrap/
sed -i "s/<latestReleasedVersionFromThisBranch>.*.<\/latestReleasedVersionFromThisBranch>/<latestReleasedVersionFromThisBranch>$1<\/latestReleasedVersionFromThisBranch>/" pom.xml


