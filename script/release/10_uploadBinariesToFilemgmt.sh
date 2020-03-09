#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

drools_ssh=/home/jenkins/.ssh/drools/id_rsa
jbpm_ssh=/home/jenkins/.ssh/jbpm/id_rsa
optaplanner_ssh=/home/jenkins/.ssh/optaplanner/id_rsa
kogito_ssh=/home/jenkins/.ssh/kogito/id_rsa

droolsDocs=drools@filemgmt.jboss.org:/docs_htdocs/drools/release
droolsHtdocs=drools@filemgmt.jboss.org:/downloads_htdocs/drools/release
jbpmDocs=jbpm@filemgmt.jboss.org:/docs_htdocs/jbpm/release
jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release
optaplannerDocs=optaplanner@filemgmt.jboss.org:/docs_htdocs/optaplanner/release
optaplannerHtdocs=optaplanner@filemgmt.jboss.org:/downloads_htdocs/optaplanner/release
uploadDir=${kieVersion}_uploadBinaries

# create directory on filemgmt.jboss.org for new release
touch upload_version
echo "mkdir" $kieVersion > upload_version
chmod +x upload_version


sftp -i $drools_ssh -b upload_version $droolsDocs
sftp -i $drools_ssh -b upload_version $droolsHtdocs
sftp -i $jbpm_ssh -b upload_version $jbpmDocs
sftp -i $jbpm_ssh -b upload_version $jbpmHtdocs
sftp -i $optaplanner_ssh -b upload_version $optaplannerDocs
sftp -i $optaplanner_ssh -b upload_version $optaplannerHtdocs

#creates directories for updatesite for drools and jbpm on filemgmt.jboss.org
touch upload_drools
echo "mkdir org.drools.updatesite" > upload_drools
chmod +x upload_drools
sftp -i $drools_ssh -b upload_drools $droolsHtdocs/$kieVersion

touch upload_jbpm
echo "mkdir updatesite" > upload_jbpm
chmod +x upload_jbpm
sftp -i $jbpm_ssh -b upload_jbpm $jbpmHtdocs/$kieVersion

# creates a directory service-repository in jbpm on filemgmt.jboss.org
touch upload_service_repository
echo "mkdir service-repository" > upload_service_repository
chmod +x upload_service_repository
sftp -i $jbpm_ssh -b upload_service_repository $jbpmHtdocs/$kieVersion

#creates directories for docs for drools and jbpm and optaplanner on filemgmt.jboss.org
touch upload_drools_docs
echo "mkdir drools-docs" > upload_drools_docs
chmod +x upload_drools_docs
sftp -i $drools_ssh -b upload_drools_docs $droolsDocs/$kieVersion/

touch upload_kie_api_javadoc
echo "mkdir kie-api-javadoc" > upload_kie_api_javadoc
chmod +x upload_kie_api_javadoc
sftp -i $drools_ssh -b upload_kie_api_javadoc $droolsDocs/$kieVersion

touch upload_jbpm_docs
echo "mkdir jbpm-docs" > upload_jbpm_docs
chmod +x upload_jbpm_docs
sftp -i $jbpm_ssh -b upload_jbpm_docs $jbpmDocs/$kieVersion

touch upload_optaplanner_docs
echo "mkdir optaplanner-docs" > upload_optaplanner_docs
chmod +x upload_optaplanner_docs
sftp -i $optaplanner_ssh -b upload_optaplanner_docs $optaplannerDocs/$kieVersion

touch upload_optaweb_employee_rostering_docs
echo "mkdir optaweb-employee-rostering-docs" > upload_optaweb_employee_rostering_docs
chmod +x upload_optaweb_employee_rostering_docs
sftp -i $optaplanner_ssh -b upload_optaweb_employee_rostering_docs $optaplannerDocs/$kieVersion

touch upload_optaweb-vehicle-routing-docs
echo "mkdir optaweb-vehicle-routing-docs" > upload_optaweb-vehicle-routing-docs
chmod +x upload_optaweb-vehicle-routing-docs
sftp -i $optaplanner_ssh -b upload_optaweb-vehicle-routing-docs $optaplannerDocs/$kieVersion

touch upload_optaplanner_javadoc
echo "mkdir optaplanner-javadoc" > upload_optaplanner_javadoc
chmod +x upload_optaplanner_javadoc
sftp -i $optaplanner_ssh -b upload_optaplanner_javadoc $optaplannerDocs/$kieVersion

touch upload_optaplanner_wb_es_docs
echo "mkdir optaplanner-wb-es-docs" > upload_optaplanner_wb_es_docs
chmod +x upload_optaplanner_wb_es_docs
sftp -i $optaplanner_ssh -b upload_optaplanner_wb_es_docs $optaplannerDocs/$kieVersion



# *** copies drools binaries and docs to filemgmt.jboss.org ********************************

# bins
scp -i $drools_ssh $uploadDir/drools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $drools_ssh $uploadDir/droolsjbpm-integration-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $drools_ssh $uploadDir/droolsjbpm-tools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $drools_ssh $uploadDir/business-central-$kieVersion-*.war $droolsHtdocs/$kieVersion
scp -i $drools_ssh $uploadDir/kie-server-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
# updatesite
scp -r -i $drools_ssh $uploadDir/updatesite/* $droolsHtdocs/$kieVersion/org.drools.updatesite
# docs
scp -r -i $drools_ssh $uploadDir/drools-docs/* $droolsDocs/$kieVersion/drools-docs
scp -r -i $drools_ssh $uploadDir/kie-api-javadoc/* $droolsDocs/$kieVersion/kie-api-javadoc


# *** copies jbpm binaries and docs to filemgmt.jboss.org **********************************

# bins
scp -i $jbpm_ssh $uploadDir/jbpm-$kieVersion-bin.zip $jbpmHtdocs/$kieVersion
scp -i $jbpm_ssh $uploadDir/jbpm-$kieVersion-examples.zip $jbpmHtdocs/$kieVersion
scp -i $jbpm_ssh $uploadDir/jbpm-server-$kieVersion-dist.zip $jbpmHtdocs/$kieVersion
# uploads jbpm -installers them to filemgt.jboss.org
uploadInstaller(){
        # upload installers to filemgmt.jboss.org
        scp -i $jbpm_ssh jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

uploadAllInstaller(){
        # upload installers to filemgmt.jboss.org
        scp -i $jbpm_ssh jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
        # upload installers to filemgmt.jboss.org
        scp -i $jbpm_ssh jbpm-installer-full-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

if [[ $kieVersion == *"Final"* ]] ;then
        uploadAllInstaller
else
        uploadInstaller
fi
# updatesite
scp -r -i $jbpm_ssh $uploadDir/updatesite/* $jbpmHtdocs/$kieVersion/updatesite
# docs
scp -r -i $jbpm_ssh $uploadDir/jbpm-docs/* $jbpmDocs/$kieVersion/jbpm-docs
scp -r -i $jbpm_ssh $uploadDir/service-repository/* $jbpmHtdocs/$kieVersion/service-repository


# *** copies optaplanner binaries and docs to filemgmt.jboss.org ***************************

# bins
scp -i $optaplanner_ssh $uploadDir/optaplanner-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion
scp -i $optaplanner_ssh $uploadDir/optaweb-employee-rostering-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion
scp -i $optaplanner_ssh $uploadDir/optaweb-vehicle-routing-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion
# docs
scp -r -i $optaplanner_ssh $uploadDir/optaplanner-docs/* $optaplannerDocs/$kieVersion/optaplanner-docs
scp -r -i $optaplanner_ssh $uploadDir/optaweb-employee-rostering-docs/* $optaplannerDocs/$kieVersion/optaweb-employee-rostering-docs
scp -r -i $optaplanner_ssh $uploadDir/optaweb-vehicle-routing-docs/* $optaplannerDocs/$kieVersion/optaweb-vehicle-routing-docs
scp -r -i $optaplanner_ssh $uploadDir/optaplanner-javadoc/* $optaplannerDocs/$kieVersion/optaplanner-javadoc
scp -r -i $optaplanner_ssh $uploadDir/optaplanner-wb-es-docs/* $optaplannerDocs/$kieVersion/optaplanner-wb-es-docs


# clean upload files
rm upload_*

# runs create_filemgmt_links.sh
sh droolsjbpm-build-bootstrap/script/release/create_filemgmt_links.sh $kieVersion