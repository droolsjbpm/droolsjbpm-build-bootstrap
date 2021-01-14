#!/bin/bash -e

# parameters: FILEMGMT_KEY = $1
# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

droolsDocs=drools@filemgmt.jboss.org:/docs_htdocs/drools/release
droolsHtdocs=drools@filemgmt.jboss.org:/downloads_htdocs/drools/release
uploadDir=${kieVersion}_uploadBinaries

# create directory on filemgmt.jboss.org for new release
touch upload_version
echo "mkdir" $kieVersion > upload_version
chmod +x upload_version
sftp -i $1 -b upload_version $droolsDocs
sftp -i $1 -b upload_version $droolsHtdocs

#creates directories for updatesite for drools and jbpm on filemgmt.jboss.org
touch upload_drools
echo "mkdir org.drools.updatesite" > upload_drools
chmod +x upload_drools
sftp -i $1 -b upload_drools $droolsHtdocs/$kieVersion

#creates directoy kie-api-javadoc for drools on filemgmt.jboss.org
touch upload_kie_api_javadoc
echo "mkdir kie-api-javadoc" > upload_kie_api_javadoc
chmod +x upload_kie_api_javadoc
sftp -i $1 -b upload_kie_api_javadoc $droolsDocs/$kieVersion

#creates directory drools-docs on filemgmt.jboss.org
touch upload_drools_docs
echo "mkdir drools-docs" > upload_drools_docs
chmod +x upload_drools_docs
sftp -i $1 -b upload_drools_docs $droolsDocs/$kieVersion/



# *** copies drools binaries and docs to filemgmt.jboss.org ********************************

# bins
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/drools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/droolsjbpm-integration-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/droolsjbpm-tools-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/business-central-$kieVersion-*.war $droolsHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/kie-server-distribution-$kieVersion.zip $droolsHtdocs/$kieVersion

# updatesite
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $1 $uploadDir/updatesite/* $droolsHtdocs/$kieVersion/org.drools.updatesite

# docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $1 $uploadDir/drools-docs/* $droolsDocs/$kieVersion/drools-docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $1 $uploadDir/kie-api-javadoc/* $droolsDocs/$kieVersion/kie-api-javadoc

# make filemgmt symbolic links for drools
mkdir filemgmt_links
cd filemgmt_links

###############################################################################
# latest drools links
###############################################################################
touch ${kieVersion}
ln -s ${kieVersion} latest

echo "Uploading normal links..."
rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $droolsDocs
rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $droolsHtdocs

###############################################################################
# latestFinal drools links
###############################################################################
if [[ "${kieVersion}" == *Final* ]]; then
    ln -s ${kieVersion} latestFinal
    echo "Uploading Final links..."
    rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $droolsDocs
    rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $droolsHtdocs
fi

# remove files and directories for uploading drools
rm -rf upload_*
rm -rf filemgmt_links
