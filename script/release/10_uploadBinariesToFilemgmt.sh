#!/bin/bash

set -e

# in case that the community build takes several days the variable kieVersion gets some how unset
# the kieVersion is taken from a created file
kieVersion=$(cut -f1 kie.properties)

droolsDocs=drools@filemgmt.jboss.org:/docs_htdocs/drools/release
droolsHtdocs=drools@filemgmt.jboss.org:/downloads_htdocs/drools/release
jbpmDocs=jbpm@filemgmt.jboss.org:/docs_htdocs/jbpm/release
jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release
jbpmServiceRepo=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release
optaplannerDocs=optaplanner@filemgmt.jboss.org:/docs_htdocs/optaplanner/release
optaplannerHtdocs=optaplanner@filemgmt.jboss.org:/downloads_htdocs/optaplanner/release


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

touch upload_optaplanner_javadoc
echo "mkdir optaplanner-javadoc" > upload_optaplanner_javadoc
chmod +x upload_optaplanner_javadoc
sftp -b upload_optaplanner_javadoc $optaplannerDocs/$kieVersion

touch upload_optaplanner_wb_es_docs
echo "mkdir optaplanner-wb-es-docs" > upload_optaplanner_wb_es_docs
chmod +x upload_optaplanner_wb_es_docs
sftp -b upload_optaplanner_wb_es_docs $optaplannerDocs/$kieVersion

touch upload_service_repository
echo "mkdir service-repository" > upload_service_repository
chmod +x upload_service_repository
sftp -b upload_service_repository $jbpmServiceRepo/$kieVersion

# copies drools binaries to filemgmt.jboss.org
scp -r droolsjbpm-tools/droolsjbpm-tools-distribution/target/droolsjbpm-tools-distribution-$kieVersion/droolsjbpm-tools-distribution-$kieVersion/binaries/org.drools.updatesite/* $droolsHtdocs/$kieVersion/org.drools.updatesite
scp drools/drools-distribution/target/drools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp droolsjbpm-integration/droolsjbpm-integration-distribution/target/droolsjbpm-integration-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp droolsjbpm-tools/droolsjbpm-tools-distribution/target/droolsjbpm-tools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp kie-wb-distributions/business-central-parent/business-central-distribution-wars/business-central/target/business-central-$kieVersion-*.war $droolsHtdocs/$kieVersion
scp droolsjbpm-integration/kie-server-parent/kie-server-wars/kie-server-distribution/target/kie-server-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion

#copies drools-docs and kie-api-javadoc to filemgmt.jboss.or
scp -r kie-docs/doc-content/drools-docs/target/generated-docs/* $droolsDocs/$kieVersion/drools-docs
scp -r droolsjbpm-knowledge/kie-api/target/apidocs/* $droolsDocs/$kieVersion/kie-api-javadoc

#copies jbpm binaries to filemgmt.jboss.org
scp -r droolsjbpm-tools/droolsjbpm-tools-distribution/target/droolsjbpm-tools-distribution-$kieVersion/droolsjbpm-tools-distribution-$kieVersion/binaries/org.drools.updatesite/* $jbpmHtdocs/$kieVersion/updatesite
scp jbpm/jbpm-distribution/target/jbpm-$kieVersion-bin.zip $jbpmHtdocs/$kieVersion
scp jbpm/jbpm-distribution/target/jbpm-$kieVersion-examples.zip $jbpmHtdocs/$kieVersion
scp kie-wb-distributions/business-central-parent/jbpm-server-distribution/target/jbpm-server-$kieVersion-dist.zip $jbpmHtdocs/$kieVersion

#copies the jbpm-installers to filemgmt.jboss.org
jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release

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

# copies jbpm work items into service repository
scp -r jbpm-work-items/repository/target/repository-$kieVersion/* $jbpmServiceRepo/$kieVersion/service-repository

#copies jbpm-docs to filemgmt.jboss.org
scp -r kie-docs/doc-content/jbpm-docs/target/generated-docs/* $jbpmDocs/$kieVersion/jbpm-docs

#copies optaplanner binaries to filemgmt.jboss.org
scp optaplanner/optaplanner-distribution/target/optaplanner-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion

#copies optaplanner-docs and optaplanner-javadoc to filemgmt.jboss.org
scp -r optaplanner/optaplanner-docs/target/generated-docs/* $optaplannerDocs/$kieVersion/optaplanner-docs
scp -r optaplanner/optaplanner-distribution/target/optaplanner-distribution-$kieVersion/optaplanner-distribution-$kieVersion/javadocs/* $optaplannerDocs/$kieVersion/optaplanner-javadoc
scp -r kie-docs/doc-content/optaplanner-wb-es-docs/target/generated-docs/* $optaplannerDocs/$kieVersion/optaplanner-wb-es-docs

# clean upload files
rm upload_*

# runs create_filemgmt_links.sh
sh droolsjbpm-build-bootstrap/script/release/create_filemgmt_links.sh $kieVersion
