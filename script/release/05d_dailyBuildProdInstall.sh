#!/bin/bash -e

# removing KIE artifacts from local maven repo (basically all possible SNAPSHOTs)
echo $MAVEN_REPO_LOCAL "="

if [ -d $MAVEN_REPO_LOCAL ]; then
    rm -rf $MAVEN_REPO_LOCAL/org/jboss/dashboard-builder/
    rm -rf $MAVEN_REPO_LOCAL/org/kie/
    rm -rf $MAVEN_REPO_LOCAL/org/drools/
    rm -rf $MAVEN_REPO_LOCAL/org/jbpm/
    rm -rf $MAVEN_REPO_LOCAL/org/optaplanner/
    rm -rf $MAVEN_REPO_LOCAL/org/optaweb
    rm -rf $MAVEN_REPO_LOCAL/org/uberfire/
fi

# removes kie.properties if it exists
file="kie.properties"
if [ -f "$file" ]; then
  echo "$file found."
  rm $file
fi

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

# creates a properties file to pass variables and moves it to the root directory
echo kieVersion=$kieVersion > kie.properties

# do a full build
./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean install -Dfull -Drelease -Dproductized -s $SETTINGS_XML_FILE\
 -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dmaven.test.redirectTestOutputToFile=true -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx10g" --clean-up-script="$WORKSPACE/clean-up.sh"