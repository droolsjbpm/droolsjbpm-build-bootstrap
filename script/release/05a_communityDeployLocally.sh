#!/bin/bash -e

deployDir=$WORKSPACE/community-deploy-dir
# does a full build, but deploys only into local dir
# we will deploy into remote staging repo only once the whole build passed (to save time and bandwith)
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -s $SETTINGS_XML_FILE -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dfull -Drelease -DaltDeploymentRepository=local::default::file://$deployDir -Dmaven.test.redirectTestOutputToFile=true -Dmaven.test.failure.ignore=true -Dgwt.memory.settings="-Xmx10g" -Prun-code-coverage -Dcontainer.profile=wildfly -Dcontainer=wildfly -Dintegration-tests=true -Dmaven.wagon.httpconnectionManager.ttlSeconds=25 -Dmaven.wagon.http.retryHandler.count=3 --clean-up-script="$WORKSPACE/clean-up.sh"

