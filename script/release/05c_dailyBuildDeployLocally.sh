#!/bin/bash -e

# build the repos & deploy into local dir
deployDir=$WORKSPACE/deploy-dir

# do a full build, but deploy only into local dir
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -Dfull -Drelease -DaltDeploymentRepository=local::default::file://$deployDir -s $SETTINGS_XML_FILE\
 -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dmaven.test.redirectTestOutputToFile=true -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx10g" --clean-up-script="$WORKSPACE/clean-up.sh"