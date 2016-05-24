#!/bin/bash
set -e

# Updates the version for all droolsjbpm repositories

initializeScriptDir() {
    # Go to the script directory
    cd `dirname $0`
    # If the file itself is a symbolic link (ignoring parent directory links), then follow that link recursively
    # Note that scriptDir=`pwd -P` does not do that and cannot cope with a link directly to the file
    scriptFileBasename=`basename $0`
    while [ -L "$scriptFileBasename" ] ; do
        scriptFileBasename=`readlink $scriptFileBasename` # Follow the link
        cd `dirname $scriptFileBasename`
        scriptFileBasename=`basename $scriptFileBasename`
    done
    # Set script directory and remove other symbolic links (parent directory links)
    scriptDir=`pwd -P`
}

mvnVersionsSet() {
    mvn -B -N -e -Dfull versions:set -DnewVersion="$newVersion" -DallowSnapshots=true -DgenerateBackupPoms=false
}

mvnVersionsUpdateParent() {
    mvn -B -N -e -s $settingsXmlFile versions:update-parent -Dfull\
     -DparentVersion="[$newVersion]" -DallowSnapshots=true -DgenerateBackupPoms=false
}

mvnVersionsUpdateChildModules() {
    mvn -B -N -e -s $settingsXmlFile versions:update-child-modules -Dfull\
     -DallowSnapshots=true -DgenerateBackupPoms=false
}

# Updates parent version and child modules versions for Maven project in current working dir
mvnVersionsUpdateParentAndChildModules() {
    mvnVersionsUpdateParent
    mvnVersionsUpdateChildModules
}

initializeScriptDir
droolsjbpmOrganizationDir="$scriptDir/../../.."

if [ $# != 1 ] && [ $# != 2 ]; then
    echo
    echo "Usage:"
    echo "  $0 newVersion releaseType"
    echo "For example:"
    echo "  $0 6.3.0.Final community"
    echo "  $0 6.3.1.20151105 productized"
    echo
    exit 1
fi

newVersion=$1
echo "New version is $newVersion"

releaseType=$2
# check if the release type was set, if not default to "community"
if [ "x$releaseType" == "x" ]; then
    releaseType="community"
fi

if [ $releaseType == "community" ]; then
    settingsXmlFile="$scriptDir/update-version-all-community-settings.xml"
elif [ $releaseType == "productized" ]; then
    settingsXmlFile="$scriptDir/update-version-all-productized-settings.xml"
else
    echo "Incorrect release type specified: '$releaseType'. Supported values are 'community' or 'productized'"
    exit 1
fi
echo "Specified release type: $releaseType"
echo "Using following settings.xml: $settingsXmlFile"

startDateTime=`date +%s`

cd $droolsjbpmOrganizationDir

for repository in `cat ${scriptDir}/../repository-list.txt` ; do
    echo

    if [ ! -d $droolsjbpmOrganizationDir/$repository ]; then
        echo "==============================================================================="
        echo "Missing Repository: $repository. SKIPPING!"
        echo "==============================================================================="
    else
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        cd $repository
        if [ "$repository" == "droolsjbpm-build-bootstrap" ]; then
            # first build&install the current version (usually SNAPSHOT) as it is needed later by other repos
            mvn -B -U -Dfull clean install
            mvnVersionsSet
            sed -i "s/<version\.org\.kie>.*<\/version.org.kie>/<version.org.kie>$newVersion<\/version.org.kie>/" pom.xml
            # update latest released version property only for non-SNAPSHOT versions
            if [[ ! $newVersion == *-SNAPSHOT ]]; then
                sed -i "s/<latestReleasedVersionFromThisBranch>.*<\/latestReleasedVersionFromThisBranch>/<latestReleasedVersionFromThisBranch>$newVersion<\/latestReleasedVersionFromThisBranch>/" pom.xml
            fi
            # update version also for user BOMs, since they do not use the top level kie-parent
            cd kie-user-bom-parent
            mvnVersionsSet
            cd ..
            # workaround for http://jira.codehaus.org/browse/MVERSIONS-161
            mvn -B clean install -DskipTests
            returnCode=$?

        elif [ "$repository" = "jbpm" ]; then
            mvnVersionsUpdateParentAndChildModules
            returnCode=$?
            sed -i "s/release.version=.*$/release.version=$newVersion/" jbpm-installer/build.properties

        elif [ "$repository" = "droolsjbpm-tools" ]; then
            cd drools-eclipse
            mvn -B -Dfull tycho-versions:set-version -DnewVersion=$newVersion
            returnCode=$?
            # replace the leftovers not covered by the tycho plugin (bug?)
            # SNAPSHOT and release versions need to be handled differently
            versionToUse=$newVersion
            if [[ $newVersion == *-SNAPSHOT ]]; then
                versionToUse=`sed "s/-SNAPSHOT/.qualifier/" <<< $newVersion`
            fi
            sed -i "s/source_[^\"]*/source_$versionToUse/" org.drools.updatesite/category.xml
            sed -i "s/version=\"[^\"]*\">/version=\"$versionToUse\">/" org.drools.updatesite/category.xml
            cd ..
            if [ $returnCode == 0 ]; then
                mvn -B -N clean install
                mvnVersionsUpdateParent
                # workaround for http://jira.codehaus.org/browse/MVERSIONS-161
                mvn -B -N clean install -DskipTests
                cd drools-eclipse
                mvnVersionsUpdateParent
                cd ..
                mvnVersionsUpdateChildModules
                returnCode=$?
            fi

        else
            mvnVersionsUpdateParentAndChildModules
            returnCode=$?
        fi

        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi

        cd ..
    fi
done

endDateTime=`date +%s`
spentSeconds=`expr $endDateTime - $startDateTime`

echo
echo "Total time: ${spentSeconds}s"
