#!/bin/bash

# Git clone the other repositories

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

printUsage() {
    echo
    echo "Usage:"
    echo "  $0 <additional git options> [--repo-list=<list-of-repositories>|--target-repo=<repository>] [--add-upstream-remote]"
    echo "For example:"
    echo "  $0"
    echo "  $0 --bare"
    echo "  $0 --repo-list=droolsjbpm-knowledge,drools"
    echo "  $0 --target-repo=drools-wb"
    echo "In case you are cloning your forks, the following option will create a second remote called upstream"
    echo "pointing to kiegroup. It can be useful for keeping your forks up to date:"
    echo "  $0 --add-upstream-remote"
    echo
}

initializeWorkingDirAndScriptDir
droolsjbpmOrganizationDir="$scriptDir/../.."

startDateTime=`date +%s`

# The gitUrlPrefix differs between committers and anonymous users. Also it differs on forks.
# Committers on blessed gitUrlPrefix="git@github.com:kiegroup/"
# Anonymous users on blessed gitUrlPrefix="git://github.com/kiegroup/"
cd "${scriptDir}"
droolsjbpmGitUrlPrefix=`git remote -v | grep --regex "^origin.*(fetch)$"`
droolsjbpmGitUrlPrefix=`echo ${droolsjbpmGitUrlPrefix} | sed 's/^origin\s*//g' | sed 's/droolsjbpm\-build\-bootstrap.*//g'`

cd "$droolsjbpmOrganizationDir"

# additinal Git options can be passed simply as params to the script
# example: --depth 1 (creates a shallow clone with that depth)
additionalGitOptions=()

# default repository list is stored in the repository-list.txt file
REPOSITORY_LIST=`cat "${scriptDir}/repository-list.txt"`
# Repositories that need to use the branch 7.x instead of master
BRANCHED_7_REPOSITORY_LIST=`cat "${scriptDir}/branched-7-repository-list.txt"`
# Repositories thta ned to use branch main instead of master
MAIN_BRANCH_REPOSITORIES_LIST=`cat "${scriptDir}/main-branch-repositories-list.txt"`

for arg in "$@"
do
    case "$arg" in
        --target-repo=*)
            REPOSITORY_LIST=$($scriptDir/checks/repo-dep-tree.pl -w -t ${arg#*=})
            REPOSITORY_LIST=${REPOSITORY_LIST//,/ }
        ;;

        --repo-list=*)
            REPOSITORY_LIST=$(echo "$arg" | sed 's/[-a-zA-Z0-9]*=//')
            # replace the commas with spaces so that the for loop treats the individual repos as different values
            REPOSITORY_LIST=${REPOSITORY_LIST//,/ }
        ;;
        # add upstream remote for a repository, i.e. git@github.com:kiegroup/${repository}.git, might be useful for PRs
        --add-upstream-remote)
            UPSTREAM=true
        ;;

        --help)
            printUsage
            exit 1
        ;;

        *)
            additionalGitOptions+=("$arg")
        ;;
    esac
done


for repository in $REPOSITORY_LIST ; do
    gitUrlPrefix=${droolsjbpmGitUrlPrefix}
    echo
    if [ -d $repository ] ; then
        echo "==============================================================================="
        echo "This directory already exists: $repository"
        echo "==============================================================================="
    else
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        echo -- prefix ${gitUrlPrefix} --
        echo -- repository ${repository} --
        echo -- ${gitUrlPrefix}${repository}.git -- ${repository} --
        if [ "x${additionalGitOptions}" != "x" ]; then
            echo -- additional Git options: ${additionalGitOptions[@]} --
        fi

        repoAdditionalGitOptions=( "${additionalGitOptions[@]}" )
        if [ $(echo "$BRANCHED_7_REPOSITORY_LIST" | grep "^$repository$") ] ; then
            if [[ ${additionalGitOptions[0]} == "-b" ]] || [[ ${additionalGitOptions[0]} == "--branch" ]]; then
                if [[ ${additionalGitOptions[1]} == "master" ]]; then
                  repoAdditionalGitOptions[1]="7.x"
                  echo -- additional Git options changed in ${repository} to: ${repoAdditionalGitOptions[@]} --
                fi
            else
                repoAdditionalGitOptions=( "-b" "7.x" "${repoAdditionalGitOptions[@]}" )
            fi
        fi
        if [ $(echo "$MAIN_BRANCH_REPOSITORIES_LIST" | grep "^$repository$") ] ; then
            if [[ ${additionalGitOptions[0]} == "-b" ]] || [[ ${additionalGitOptions[0]} == "--branch" ]]; then
                if [[ ${additionalGitOptions[1]} == "master" ]]; then
                  repoAdditionalGitOptions[1]="main"
                  echo -- additional Git options changed in ${repository} to: ${repoAdditionalGitOptions[@]} --
                fi
            else
                repoAdditionalGitOptions=( "-b" "main" "${repoAdditionalGitOptions[@]}" )
            fi
        fi
        git clone "${repoAdditionalGitOptions[@]}" ${gitUrlPrefix}${repository}.git ${repository}

        returnCode=$?
        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi
    fi
    if [ "$UPSTREAM" = true ]; then
        upstreamGitUrlPrefix=`echo ${gitUrlPrefix} | sed 's|\(.*github\.com[:/]\).*|\1kiegroup/|'`
        echo -- adding upstream remote "${upstreamGitUrlPrefix}${repository}.git"
        cd ${repository}
        git remote add upstream ${upstreamGitUrlPrefix}${repository}.git
        cd ..
    fi
done

echo
echo Disk size:

for repository in `cat "${scriptDir}/repository-list.txt"` ; do
    du -sh $repository
done

endDateTime=`date +%s`
spentSeconds=`expr $endDateTime - $startDateTime`

echo
echo "Total time: ${spentSeconds}s"
