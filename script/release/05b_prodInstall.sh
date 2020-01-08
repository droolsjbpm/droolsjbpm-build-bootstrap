#!/bin/bash -e

# does a clean install
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean install -s $SETTINGS_XML_FILE -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dfull -Dproductized -Drelease -Dmaven.test.failure.ignore=true -Dgwt.memory.settings="-Xmx10g"