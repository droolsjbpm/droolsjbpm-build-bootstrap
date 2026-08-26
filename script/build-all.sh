#!/bin/bash

# For each locally present repository (in repository-list.txt order):
#   1. Fetch latest updates from origin
#   2. Checkout branch 7.81.x-blue-jakarta
#   3. Build with tests skipped

BRANCH="7.81.x-blue-jakarta"

initializeWorkingDirAndScriptDir() {
    # Set working directory and remove all symbolic links
    workingDir=`pwd -P`

    # Go the script directory
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
initializeWorkingDirAndScriptDir
droolsjbpmOrganizationDir="$scriptDir/../.."

mvnBin="mvn"
if [ -a $M3_HOME/bin/mvn ] ; then
    mvnBin="$M3_HOME/bin/mvn"
fi
echo "Using Maven binary '$mvnBin'"
"$mvnBin" -v
echo

startDateTime=`date +%s`

cd "$droolsjbpmOrganizationDir"

for repository in `cat "${scriptDir}/repository-list.txt"` ; do
    echo
    if [ ! -d "$droolsjbpmOrganizationDir/$repository" ]; then
        echo "==============================================================================="
        echo "Missing Repository: $repository. SKIPPING!"
        echo "==============================================================================="
    else
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        cd "$repository"

        echo "--- Fetching origin ---"
        git fetch origin
        returnCode=$?
        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi

        echo "--- Checking out $BRANCH ---"
        git checkout "$BRANCH"
        returnCode=$?
        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi

        echo "--- Pulling $BRANCH ---"
        git pull origin "$BRANCH"
        returnCode=$?
        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi

        echo "--- Building (tests skipped) ---"
        "$mvnBin" clean install -DskipTests -Dcheckstyle.skip -Drevapi.skip -Denforcer.skip -Dskip=true
        returnCode=$?
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
