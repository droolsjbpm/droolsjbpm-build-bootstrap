#!/bin/bash
set -e

# IMPORTANT: if you want the script to use a custom settings.xml instead of a predefined (community or productized)
# set the variable SETTINGS_XML_FILE with the full path to your settings.xml like
#
# export SETTINGS_XML_FILE="<full path>/settings.xml"
#
# and run the script > sh update-version-all.sh new_kieVersion custom.

GROUP_ID=kiegroup
echo "GROUP_ID: "$GROUP_ID

# Updates the version for all kiegroup repositories

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
    mvn -B -N -e -s $settingsXmlFile versions:set -Dfull\
      -DnewVersion="$newVersion" -DallowSnapshots=true -DgenerateBackupPoms=false
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
    echo "  $0 7.5.0.Final community"
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
elif [ $releaseType == "custom" ]; then
    settingsXmlFile="$SETTINGS_XML_FILE"
else
    echo "Incorrect release type specified: '$releaseType'. Supported values are 'community' or 'productized' or 'custom'"
    exit 1
fi
echo "Specified release type: $releaseType"
echo "Using following settings.xml: $settingsXmlFile"


startDateTime=`date +%s`

# remove optawebs* from branched-7-repository-list.txt since they are not released any-more
# change '-' by '_' in repository lists
cd $scriptDir

sed -i "s/-/_/g" ../repository-list.txt
sed -i "s/-/_/g" ../branched-7-repository-list.txt

cd $droolsjbpmOrganizationDir

# --- --- ---
# Checks if repos in branched-7-repository-list.txt are on the right 7.x branch if all other repos are checked out to main.
# For example, optaplanner 7.x branch has the same version as main on other kiegroup/reps.
for branch7xRepo in $(cat "${scriptDir}/../branched-7-repository-list.txt"); do
  cd ${GROUP_ID}_$branch7xRepo
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  if [ $currentBranch == "main" ]; then
      echo ""
      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo " Can't update versions for main branches because $branch7xRepo is still on main and should be checked out to 7.x"
    echo ""
      while true; do
          echo "a abort"
          echo "c continue and check out $branch7xRepo to 7.x"
          echo ""
          echo -n "Do you want to continue c or abort a "
          echo ""
          read choice

          case $choice in
              c)
              git checkout 7.x
              break
              ;;
              a)
              echo "-------------------------- ABORTED --------------------------"
              echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
              exit 0;
              ;;
              *)
              echo "That is not a valid choice, try a c to continue or a to abort"
              ;;
          esac
      done
  fi
  cd ..
done
# --- --- ---

for repository in `cat ${scriptDir}/../repository-list.txt` ; do
    echo

    if [ ! -d $droolsjbpmOrganizationDir/${GROUP_ID}_$repository ]; then
        echo "==============================================================================="
        echo "Missing Repository: $repository. SKIPPING!"
        echo "==============================================================================="
    else
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        cd ${GROUP_ID}_$repository

        if [ "$repository" == "lienzo_core" ]; then
            mvnVersionsSet
            returnCode=$?

        elif [ "$repository" == "lienzo_tests" ]; then
            mvnVersionsSet
            returnCode=$?

        elif [ "$repository" == "droolsjbpm_build_bootstrap" ]; then
            # first build&install the current version (usually SNAPSHOT) as it is needed later by other repos
            mvn -B -U -Dfull -s $settingsXmlFile clean install
            # extract old kie version
            kieOldVersion=$(grep -oP -m 2 '(?<=<version>).*(?=</version)' pom.xml| awk 'FNR==2')
            mvnVersionsSet
            # update latest released version property only for non-SNAPSHOT versions
            if [[ ! $newVersion == *-SNAPSHOT ]]; then
                sed -i "s/<latestReleasedVersionFromThisBranch>.*<\/latestReleasedVersionFromThisBranch>/<latestReleasedVersionFromThisBranch>$newVersion<\/latestReleasedVersionFromThisBranch>/" pom.xml
            fi
            # update version also for user BOMs, since they do not use the top level kie-parent
            cd kie-user-bom-parent
            mvnVersionsSet
            cd ..
            # the child poms (all boms/pom.xml) have to be updated
            mvnVersionsUpdateChildModules
            # update version that are not automatically updated
            sed -i "s/<version.org.kie>$kieOldVersion<\/version.org.kie>/<version.org.kie>$newVersion<\/version.org.kie>/" pom.xml
            # workaround for http://jira.codehaus.org/browse/MVERSIONS-161
            mvn -B -s $settingsXmlFile clean install -DskipTests
            returnCode=$?

        elif [ "$repository" == "kie_soup" ]; then
            mvnVersionsUpdateParentAndChildModules
            returnCode=$?

        elif [ "$repository" == "appformer" ]; then
            # extract old kie version
            kieOldVersion=$(grep -oP -m 1 '(?<=<version>).*(?=</version)' pom.xml)
            mvnVersionsSet
            # update version that are not automatically updated
            sed -i "s/<version>$kieOldVersion<\/version>/<version>$newVersion<\/version>/" pom.xml
            returnCode=$?

        elif [ "$repository" == "optaplanner" ]; then
            mvnVersionsUpdateParentAndChildModules
            returnCode=$?
            if [ $returnCode != 0 ] ; then
                exit $returnCode
            fi
            optaplanner-quickstarts/update-version.sh $newVersion $releaseType
            returnCode=$?

        elif [ "$repository" == "jbpm" ]; then
            mvnVersionsUpdateParentAndChildModules
            returnCode=$?
            sed -i "s/release.version=.*$/release.version=$newVersion/" jbpm-installer/src/main/resources/build.properties

        elif [ "$repository" == "process_migration_service" ]; then
            # extract old kie version
            kieOldVersion=$(grep -oP -m 2 '(?<=<version>).*(?=</version)' pom.xml | sed -n 2p)
          # update version since no mvn command works
            sed -i "s/<version>$kieOldVersion<\/version>/<version>$newVersion<\/version>/" pom.xml
            returnCode=$?

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
