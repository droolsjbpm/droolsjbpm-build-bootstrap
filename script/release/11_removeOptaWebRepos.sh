#!/bin/bash -e

sed -i '/optaweb-employee-rostering/d' droolsjbpm-build-bootstrap/script/repository-list.txt
sed -i '/optaweb-vehicle-routing/d' droolsjbpm-build-bootstrap/script/repository-list.txt
sed -i '/optaweb-employee-rostering/d' droolsjbpm-build-bootstrap/script/branched-7-repository-list.txt
sed -i '/optaweb-vehicle-routing/d' droolsjbpm-build-bootstrap/script/branched-7-repository-list.txt


