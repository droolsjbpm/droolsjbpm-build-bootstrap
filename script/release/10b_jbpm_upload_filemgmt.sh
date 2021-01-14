#!/bin/bash -e

# parameters: FILEMGMT_KEY = $1
# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

jbpmDocs=jbpm@filemgmt.jboss.org:/docs_htdocs/jbpm/release
jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release
uploadDir=${kieVersion}_uploadBinaries

# create directories on filemgmt.jboss.org for new release
touch upload_version
echo "mkdir" $kieVersion > upload_version
chmod +x upload_version
sftp -i $1 -b upload_version $jbpmDocs
sftp -i $1 -b upload_version $jbpmHtdocs

#creates directory updatesite for jbpm on filemgmt.jboss.org
touch upload_jbpm
echo "mkdir updatesite" > upload_jbpm
chmod +x upload_jbpm
sftp -i $1 -b upload_jbpm $jbpmHtdocs/$kieVersion

# creates a directory service-repository for jbpm on filemgmt.jboss.org
touch upload_service_repository
echo "mkdir service-repository" > upload_service_repository
chmod +x upload_service_repository
sftp -i $1 -b upload_service_repository $jbpmHtdocs/$kieVersion

#creates directories docs for jbpm on filemgmt.jboss.org
touch upload_jbpm_docs
echo "mkdir jbpm-docs" > upload_jbpm_docs
chmod +x upload_jbpm_docs
sftp -i $1 -b upload_jbpm_docs $jbpmDocs/$kieVersion

# *** copies jbpm binaries and docs to filemgmt.jboss.org **********************************

# bins
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/jbpm-$kieVersion-bin.zip $jbpmHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/jbpm-$kieVersion-examples.zip $jbpmHtdocs/$kieVersion
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/jbpm-server-$kieVersion-dist.zip $jbpmHtdocs/$kieVersion

# uploads jbpm -installers them to filemgt.jboss.org
uploadInstaller(){
        # upload installers to filemgmt.jboss.org
        scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

uploadAllInstaller(){
        # upload installers to filemgmt.jboss.org
        scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null jbpm-installer-$kieVersion.zip $jbpmHtdocs/$kieVersion
        # upload installers to filemgmt.jboss.org
        scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null jbpm-installer-full-$kieVersion.zip $jbpmHtdocs/$kieVersion
}

if [[ $kieVersion == *"Final"* ]] ;then
        uploadAllInstaller
else
        uploadInstaller
fi

# updatesite
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/updatesite/* $jbpmHtdocs/$kieVersion/updatesite

# docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/jbpm-docs/* $jbpmDocs/$kieVersion/jbpm-docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/service-repository/* $jbpmHtdocs/$kieVersion/service-repository

# make filemgmt symbolic links for jbpm
mkdir filemgmt_links
cd filemgmt_links

###############################################################################
# latest jbpm links
###############################################################################
touch ${kieVersion}
ln -s ${kieVersion} latest

echo "Uploading normal links..."
rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $jbpmDocs
rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $jbpmHtdocs

###############################################################################
# latestFinal jbpm links
###############################################################################
if [[ "${kieVersion}" == *Final* ]]; then
    ln -s ${kieVersion} latestFinal
    echo "Uploading Final links..."
    rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $jbpmDocs
    rsync -e "ssh -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $jbpmHtdocs
fi

# remove files and directories for uploading drools
rm -rf upload_*
rm -rf filemgmt_links