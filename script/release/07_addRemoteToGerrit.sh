#!/bin/bash -e

# add remote to Gerrit for prod tags
# this step is not needed for releases nor dailyBuilds

./droolsjbpm-build-bootstrap/script/git-add-remote-gerrit.sh

