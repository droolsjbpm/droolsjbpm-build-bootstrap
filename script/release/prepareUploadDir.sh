#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)
echo "kieVersion = "$kieVersion
deployDir=../community-deploy-dir

mkdir ${kieVersion}_uploadBinaries
cd ${kieVersion}_uploadBinaries

# docs
mkdir drools-docs
cp  $deployDir/org/drools/drools-docs/$kieVersion/drools-docs-$kieVersion.zip drools-docs/
unzip drools-docs/drools-docs-$kieVersion.zip -d drools-docs/
rm drools-docs/drools-docs-$kieVersion.zip

mkdir kie-api-javadoc
scp  $deployDir/org/kie/kie-api/$kieVersion/kie-api-$kieVersion-javadoc.jar kie-api-javadoc/
unzip kie-api-javadoc/kie-api-$kieVersion-javadoc.jar -d kie-api-javadoc/
rm kie-api-javadoc/kie-api-$kieVersion-javadoc.jar

mkdir jbpm-docs
cp  $deployDir/org/jbpm/jbpm-docs/$kieVersion/jbpm-docs-$kieVersion.zip jbpm-docs/
unzip jbpm-docs/jbpm-docs-$kieVersion.zip -d jbpm-docs/
rm jbpm-docs/jbpm-docs-$kieVersion.zip

mkdir optaplanner-docs
cp  $deployDir/org/optaplanner/optaplanner-docs/$kieVersion/optaplanner-docs-$kieVersion.zip optaplanner-docs/
unzip optaplanner-docs/optaplanner-docs-$kieVersion.zip -d optaplanner-docs/
rm optaplanner-docs/optaplanner-docs-$kieVersion.zip

mkdir optaweb-employee-rostering-docs
cp  $deployDir/org/optaweb/employeerostering/optaweb-employee-rostering-docs/$kieVersion/optaweb-employee-rostering-docs-$kieVersion.zip optaweb-employee-rostering-docs/
unzip optaweb-employee-rostering-docs/optaweb-employee-rostering-docs-$kieVersion.zip -d optaweb-employee-rostering-docs/
rm optaweb-employee-rostering-docs/optaweb-employee-rostering-docs-$kieVersion.zip

mkdir optaweb-vehicle-routing-docs
cp  $deployDir/org/optaweb/vehiclerouting/optaweb-vehicle-routing-docs/$kieVersion/optaweb-vehicle-routing-docs-$kieVersion.zip optaweb-vehicle-routing-docs/
unzip optaweb-vehicle-routing-docs/optaweb-vehicle-routing-docs-$kieVersion.zip -d optaweb-vehicle-routing-docs/
rm optaweb-vehicle-routing-docs/optaweb-vehicle-routing-docs-$kieVersion.zip

# drools
cp $deployDir/org/drools/drools-distribution/$kieVersion/drools-distribution-$kieVersion.zip .
cp $deployDir/org/drools/droolsjbpm-integration-distribution/$kieVersion/droolsjbpm-integration-distribution-$kieVersion.zip .
cp $deployDir/org/kie/business-central/$kieVersion/business-central-$kieVersion-*.war .
cp $deployDir/org/kie/server/kie-server-distribution/$kieVersion/kie-server-distribution-$kieVersion.zip .

# jbpm
cp $deployDir/org/jbpm/jbpm-distribution/$kieVersion/jbpm-distribution-$kieVersion-bin.zip jbpm-$kieVersion-bin.zip
cp $deployDir/org/jbpm/jbpm-distribution/$kieVersion/jbpm-distribution-$kieVersion-examples.zip jbpm-$kieVersion-examples.zip
cp $deployDir/org/kie/jbpm-server-distribution/$kieVersion/jbpm-server-distribution-$kieVersion-dist.zip jbpm-server-$kieVersion-dist.zip

# optaplanner
cp $deployDir/org/optaplanner/optaplanner-distribution/$kieVersion/optaplanner-distribution-$kieVersion.zip .
cp $deployDir/org/optaweb/employeerostering/optaweb-employee-rostering-distribution/$kieVersion/optaweb-employee-rostering-distribution-$kieVersion.zip .
cp $deployDir/org/optaweb/vehiclerouting/optaweb-vehicle-routing-distribution/$kieVersion/optaweb-vehicle-routing-distribution-$kieVersion.zip .

# copies binaries + docs that are only available in /target directories - they are not deployed
mkdir service-repository
cp -r ../jbpm-work-items/repository/target/repository-$kieVersion/* service-repository
mkdir optaplanner-javadoc
cp -r ../optaplanner/optaplanner-distribution/target/optaplanner-distribution-$kieVersion/optaplanner-distribution-$kieVersion/javadocs/* optaplanner-javadoc
mkdir optaplanner-wb-es-docs
cp -r ../kie-docs/doc-content/optaplanner-wb-es-docs/target/generated-docs/* optaplanner-wb-es-docs