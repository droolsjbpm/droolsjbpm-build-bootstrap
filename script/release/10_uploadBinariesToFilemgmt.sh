#!/bin/bash

set -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

droolsDocs=drools@filemgmt.jboss.org:/docs_htdocs/drools/release
droolsHtdocs=drools@filemgmt.jboss.org:/downloads_htdocs/drools/release
jbpmDocs=jbpm@filemgmt.jboss.org:/docs_htdocs/jbpm/release
jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release
optaplannerDocs=optaplanner@filemgmt.jboss.org:/docs_htdocs/optaplanner/release
optaplannerHtdocs=optaplanner@filemgmt.jboss.org:/downloads_htdocs/optaplanner/release
deployDir=community-deploy-dir

# create directory on filemgmt.jboss.org for new release
touch upload_version
echo "mkdir" $kieVersion > upload_version
chmod +x upload_version


sftp -b upload_version $droolsDocs
sftp -b upload_version $droolsHtdocs
sftp -b upload_version $jbpmDocs
sftp -b upload_version $jbpmHtdocs
sftp -b upload_version $optaplannerDocs
sftp -b upload_version $optaplannerHtdocs

#creates directories for updatesite for drools and jbpm on filemgmt.jboss.org
touch upload_drools
echo "mkdir org.drools.updatesite" > upload_drools
chmod +x upload_drools
sftp -b upload_drools $droolsHtdocs/$kieVersion

touch upload_jbpm
echo "mkdir updatesite" > upload_jbpm
chmod +x upload_jbpm
sftp -b upload_jbpm $jbpmHtdocs/$kieVersion

# creates a directory service-repository in jbpm on filemgmt.jboss.org
touch upload_service_repository
echo "mkdir service-repository" > upload_service_repository
chmod +x upload_service_repository
sftp -b upload_service_repository $jbpmHtdocs/$kieVersion

#creates directories for docs for drools and jbpm and optaplanner on filemgmt.jboss.org
touch upload_drools_docs
echo "mkdir drools-docs" > upload_drools_docs
chmod +x upload_drools_docs
sftp -b upload_drools_docs $droolsDocs/$kieVersion/

touch upload_kie_api_javadoc
echo "mkdir kie-api-javadoc" > upload_kie_api_javadoc
chmod +x upload_kie_api_javadoc
sftp -b upload_kie_api_javadoc $droolsDocs/$kieVersion

touch upload_jbpm_docs
echo "mkdir jbpm-docs" > upload_jbpm_docs
chmod +x upload_jbpm_docs
sftp -b upload_jbpm_docs $jbpmDocs/$kieVersion

touch upload_optaplanner_docs
echo "mkdir optaplanner-docs" > upload_optaplanner_docs
chmod +x upload_optaplanner_docs
sftp -b upload_optaplanner_docs $optaplannerDocs/$kieVersion

touch upload_optaweb_employee_rostering_docs
echo "mkdir optaweb-employee-rostering-docs" > upload_optaweb_employee_rostering_docs
chmod +x upload_optaweb_employee_rostering_docs
sftp -b upload_optaweb_employee_rostering_docs $optaplannerDocs/$kieVersion

touch upload_optaweb-vehicle-routing-docs
echo "mkdir optaweb-vehicle-routing-docs" > upload_optaweb-vehicle-routing-docs
chmod +x upload_optaweb-vehicle-routing-docs
sftp -b upload_optaweb-vehicle-routing-docs $optaplannerDocs/$kieVersion

touch upload_optaplanner_javadoc
echo "mkdir optaplanner-javadoc" > upload_optaplanner_javadoc
chmod +x upload_optaplanner_javadoc
sftp -b upload_optaplanner_javadoc $optaplannerDocs/$kieVersion

touch upload_optaplanner_wb_es_docs
echo "mkdir optaplanner-wb-es-docs" > upload_optaplanner_wb_es_docs
chmod +x upload_optaplanner_wb_es_docs
sftp -b upload_optaplanner_wb_es_docs $optaplannerDocs/$kieVersion



# copies drools binaries to filemgmt.jboss.org
# cp and unzip updatesite
mkdir updatesite
cp  $deployDir/org/drools/org.drools.updatesite/$kieVersion/org.drools.updatesite-$kieVersion.zip updatesite/
unzip updatesite/org.drools.updatesite-$kieVersion.zip -d updatesite/
rm updatesite/org.drools.updatesite-$kieVersion.zip
scp -r updatesite/* $droolsHtdocs/$kieVersion/org.drools.updatesite

scp $deployDir/org/drools/drools-distribution/$kieVersion/drools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp $deployDir/org/drools/droolsjbpm-integration-distribution/$kieVersion/droolsjbpm-integration-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp $deployDir/org/drools/droolsjbpm-tools-distribution/$kieVersion/droolsjbpm-tools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp $deployDir/org/kie/business-central/$kieVersion/business-central-$kieVersion-*.war $droolsHtdocs/$kieVersion
scp $deployDir/org/kie/server/kie-server-distribution/$kieVersion/kie-server-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion

#unzips and copies drools-docs and kie-api-javadoc to filemgmt.jboss.or
mkdir droolsDocs
cp  $deployDir/org/drools/drools-docs/$kieVersion/drools-docs-$kieVersion.zip droolsDocs/
unzip droolsDocs/drools-docs-$kieVersion.zip -d droolsDocs/
rm droolsDocs/drools-docs-$kieVersion.zip
scp -r droolsDocs/* $droolsDocs/$kieVersion/drools-docs

mkdir kieJavadoc
scp  $deployDir/org/kie/kie-api/$kieVersion/kie-api-$kieVersion-javadoc.jar kieJavadoc/
unzip kieJavadoc/kie-api-$kieVersion-javadoc.jar -d kieJavadoc/
rm kieJavadoc/kie-api-$kieVersion-javadoc.jar
scp -r kieJavadoc/* $droolsDocs/$kieVersion/kie-api-javadoc

#copies jbpm binaries to filemgmt.jboss.org
scp -r updatesite/* $jbpmHtdocs/$kieVersion/updatesite
scp $deployDir/org/jbpm/jbpm-distribution/jbpm-$kieVersion-bin.zip $jbpmHtdocs/$kieVersion
scp $deployDir/org/jbpm/jbpm-distribution/jbpm-$kieVersion-examples.zip $jbpmHtdocs/$kieVersion
scp $deployDir/org/kie/jbpm-server-distribution/$kieVersion/jbpm-server-$kieVersion-dist.zip $jbpmHtdocs/$kieVersion

# uploads jbpm -installers them to filemgt.jboss.org

uploadInstaller(){
        # upload installers to filemgmt.jboss.org
        scp jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

uploadAllInstaller(){
        # upload installers to filemgmt.jboss.org
        scp jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
        # upload installers to filemgmt.jboss.org
        scp jbpm-installer-full-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

if [[ $kieVersion == *"Final"* ]] ;then
        uploadAllInstaller
else
        uploadInstaller
fi

#unzips and copies jbpm-docs to filemgmt.jboss.org
mkdir jbpmDocs
cp  $deployDir/org/jbpm/jbpm-docs/$kieVersion/jbpm-docs-$kieVersion.zip jbpmDocs/
unzip jbpmDocs/jbpm-docs-$kieVersion.zip -d jbpmDocs/
rm jbpmDocs/jbpm-docs-$kieVersion.zip
scp -r jbpmDocs/* $jbpmDocs/$kieVersion/jbpm-docs

#copies optaplanner-distribution.zip to filemgmt.jboss.org
scp $deployDir/org/optaplanner/optaplanner-distribution/$kieVersion/optaplanner-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion
#copies employee-rostering-distribution.zip
scp $deployDir/org/optaweb/employeerostering/employee-rostering-distribution/$kieVersion/employee-rostering-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion

#unzips and copies optaplanner-docs to filemgmt.jboss.org
mkdir optaplannerDocs
cp  $deployDir/org/optaplanner/optaplanner-docs/$kieVersion/optaplanner-docs-$kieVersion.zip optaplannerDocs/
unzip optaplannerDocs/optaplanner-docs-$kieVersion.zip -d optaplannerDocs/
rm optaplannerDocs/optaplanner-docs-$kieVersion.zip
scp -r optaplannerDocs/* $optaplannerDocs/$kieVersion/optaplanner-docs

#unzips and copies employee-rostering-docs to filemgmt.jboss.org
mkdir employeeRosteringDocs
cp  $deployDir/org/optaweb/employeerostering/employee-rostering-docs/employee-rostering-docs-$kieVersion.zip employeeRosteringDocs/
unzip employeeRosteringDocs/employee-rostering-docs-$kieVersion.zip -d employeeRosteringDocs/
rm employeeRosteringDocs/employee-rostering-docs-$kieVersion.zip
scp -r employeeRosteringDocs/* $optaplannerDocs/$kieVersion/optaweb-employee-rostering-docs


#unzips and copies vehicle-routing-docs to filemgmt.jboss.org
mkdir vehicleRoutingDocs
cp  $deployDir/org/optaweb/vehiclerouting/optaweb-vehicle-routing-docs/optaweb-vehicle-routing-docs-$kieVersion.zip vehicleRoutingDocs/
unzip vehicleRoutingDocs/optaweb-vehicle-routing-docs-$kieVersion.zip -d vehicleRoutingDocs/
rm vehicleRoutingDocs/optaweb-vehicle-routing-docs-$kieVersion.zip
scp -r vehicleRoutingDocs/* $optaplannerDocs/$kieVersion/optaweb-vehicle-routing-docs


# copies binaries + docs that are only available in /target directories - they are not deployed
scp -r jbpm-work-items/repository/target/repository-$kieVersion/* $jbpmHtdocs/$kieVersion/service-repository
scp -r optaplanner/optaplanner-distribution/target/optaplanner-distribution-$kieVersion/optaplanner-distribution-$kieVersion/javadocs/* $optaplannerDocs/$kieVersion/optaplanner-javadoc
scp -r kie-docs/doc-content/optaplanner-wb-es-docs/target/generated-docs/* $optaplannerDocs/$kieVersion/optaplanner-wb-es-docs

# clean upload files
rm upload_*

# runs create_filemgmt_links.sh
sh droolsjbpm-build-bootstrap/script/release/create_filemgmt_links.sh $kieVersion
