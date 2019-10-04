#!/bin/bash -e
echo "----- Removing npm lock files -----"
find . -name "yarn.lock" -not -path "*/node_modules/*" -type f
find . -name "package-lock.json" -not -path "*/node_modules/*" -type f

find . -name "yarn.lock" -not -path "*/node_modules/*" -type f -delete
find . -name "package-lock.json" -not -path "*/node_modules/*" -type f -delete
