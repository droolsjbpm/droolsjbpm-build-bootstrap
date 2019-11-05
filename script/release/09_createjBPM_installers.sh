#!/bin/bash -e

# this script build the jbpm-installer and jbpm-installer full

# in case that the community build takes several days the variable kieVersion gets some how unset
# the kieVersion is taken from a created file
kieVersion=$(cut -f1 kie.properties)

URLgroup="public-jboss"

createJbpmInstaller(){
        # download and unzip the jbpm-installer-<version>.zip
        wget https://repository.jboss.org/nexus/content/groups/$URLgroup/org/jbpm/jbpm-installer/$kieVersion/jbpm-installer-$kieVersion.zip
        unzip jbpm-installer*.zip

        # modifications in build.properties
        sed -i -e '/^#/!s/jBPM.kieVersion=\${snapshot.kieVersion}/jBPM.kieVersion=\${release.kieVersion}/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/jBPM.url=http.*/jBPM.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/'$URLgroup'\/org\/drools\/droolsjbpm-bpms-distribution\/\${jBPM.kieVersion}\/droolsjbpm-bpms-distribution-\${jBPM.kieVersion}-bin.zip/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/jBPM.console.url=http.*/jBPM.console.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/'$URLgroup'\/org\/kie\/business-central\/\${jBPM.kieVersion}\/business-central-\${jBPM.kieVersion}-wildfly14.war/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/jBPM.casemgmt.url=https.*/jBPM.casemgmt.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/'$URLgroup'\/org\/jbpm\/jbpm-wb-case-mgmt-showcase\/\${jBPM.kieVersion}\/jbpm-wb-case-mgmt-showcase-\${jBPM.kieVersion}-wildfly14.war/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/kie.server.url=http.*/kie.server.url=http:\/\/repository.jboss.org\/nexus\/content\/groups\/'$URLgroup'\/org\/kie\/server\/kie-server\/${jBPM.kieVersion}\/kie-server-\${jBPM.kieVersion}-ee7.war/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/droolsjbpm.eclipse.kieVersion=\${snapshot.kieVersion}/droolsjbpm.eclipse.kieVersion=\${release.kieVersion}/g' jbpm-installer-$kieVersion/build.properties
        sed -i -e '/^#/!s/droolsjbpm.eclipse.url=http.*/droolsjbpm.eclipse.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/'$URLgroup'\/org\/drools\/org.drools.updatesite\/\${droolsjbpm.eclipse.kieVersion}\/org.drools.updatesite-\${droolsjbpm.eclipse.kieVersion}.zip/g' jbpm-installer-$kieVersion/build.properties

        # add modified build.properties to jbpm-installer-<version>.zip
        zip -ur jbpm-installer-$kieVersion.zip jbpm-installer-$kieVersion/build.properties
}

createJbpmFullInstaller(){

        # downloads installer and modifies build.properties
        createJbpmInstaller
        # moves installer.zip to installer-full-<version>
        cp jbpm-installer-$kieVersion.zip jbpm-installer-full-$kieVersion.zip

        # creates content for jbpm-installer-full-<version>.zip
        cd jbpm-installer-$kieVersion
        ant install.demo
        cd ..
        zip -ur jbpm-installer-full-$kieVersion.zip jbpm-installer-$kieVersion/db/driver/
        zip -ur jbpm-installer-full-$kieVersion.zip jbpm-installer-$kieVersion/lib/
        zip -d jbpm-installer-full-$kieVersion.zip "jbpm-installer-$kieVersion/lib/eclipse-java-neon-2*"
}

if [[ $kieVersion == *"Final"* ]] ;then
        createJbpmFullInstaller
else
        createJbpmInstaller
fi