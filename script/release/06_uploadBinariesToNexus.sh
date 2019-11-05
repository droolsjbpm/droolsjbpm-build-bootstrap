#!/bin/bash -e

# the created binaries are uploaded from the locally deploy dir [$WORKSPACE/community-deploy-dir ] to Nexus
# the binaries are only uploaded when the build was for a community release
# BACKUP for prod:
#    stagingRep=15c3321d12936e
#    deployDir=$WORKSPACE/prod-deploy-dir
#    kieVersion = $2


# staging repository on Nexus
stagingRep=15c58a1abc895b
# local directoy where artifacts are stored
deployDir=$WORKSPACE/community-deploy-dir


cd $deployDir
# upload the content to remote staging repo on Nexus
mvn -B -e org.sonatype.plugins:nexus-staging-maven-plugin:1.6.5:deploy-staged-repository -DnexusUrl=https://repository.jboss.org/nexus -DserverId=jboss-releases-repository \
 -DrepositoryDirectory=$deployDir -DstagingProfileId=$stagingRep -DstagingDescription="kie-$2" -DstagingProgressTimeoutMinutes=30