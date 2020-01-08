#!/bin/bash -e

# do a full build
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean install -Dfull -Drelease -Dproductized -s $SETTINGS_XML_FILE\
 -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dmaven.test.redirectTestOutputToFile=true -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx10g" --clean-up-script="$WORKSPACE/clean-up.sh"