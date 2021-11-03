#!/bin/bash -e

sed 's/optaweb-vehicle-routing//g' droolsjbpm-build-bootstrap/script/repository-list.txt
sed 's/optaweb-employee-rostering//g' droolsjbpm-build-bootstrap/script/repository-list.txt