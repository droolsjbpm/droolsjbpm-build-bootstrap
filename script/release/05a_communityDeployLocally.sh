#!/bin/bash -e

deployDir=$WORKSPACE/community-deploy-dir
# does a full build, but deploys only into local dir
# we will deploy into remote staging repo only once the whole build passed (to save time and bandwith)
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -s $SETTINGS_XML_FILE -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dfull -Drelease -DaltDeploymentRepository=local::default::file://$deployDir -Dmaven.test.failure.ignore=true -Dgwt.memory.settings="-Xmx10g"

