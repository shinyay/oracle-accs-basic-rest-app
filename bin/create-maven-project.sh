#!/bin/bash

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	echo "USAGE: $0 <ARCHETYPE_GROUP_ID> <ARCHETYPE_ARTIFACT_ID> <ARCHETYPE_VERSION>"
	exit 1
fi

ARCHETYPE_GROUP_ID=$1
ARCHETYPE_ARTIFACT_ID=$2
ARCHETYPE_VERSION=$3

echo "ARCHETYPE_GROUP_ID   : ${ARCHETYPE_GROUP_ID}"
echo "ARCHETYPE_ARTIFACT_ID: ${ARCHETYPE_ARTIFACT_ID}"
echo "ARCHETYPE_VERSION    : ${ARCHETYPE_VERSION}"
echo -n "continue?[y/n]: "
read INPUT
if [ $INPUT = n ]; then
	exit 1
fi

echo -n "GROUP_ID: "
read GROUP_ID
echo -n "ARTIFACT_ID: "
read ARTIFACT_ID
echo -n "PACKAGE: "
read PACKAGE

echo -n "continue?[y/n]: "
read INPUT
if [ $INPUT = n ]; then
	exit 1
fi

echo ""
echo "mvn archetype:generate -DarchetypeGroupId=${ARCHETYPE_GROUP_ID} -DarchetypeArtifactId=${ARCHETYPE_ARTIFACT_ID} -DarchetypeVersion=${ARCHETYPE_VERSION} -DinteractiveMode=false -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dpackage=${PACKAGE} -DarchetypeVersion=${ARCHETYPE_VERSION}"

mvn archetype:generate -DarchetypeGroupId=${ARCHETYPE_GROUP_ID} -DarchetypeArtifactId=${ARCHETYPE_ARTIFACT_ID} -DarchetypeVersion=${ARCHETYPE_VERSION} -DinteractiveMode=false -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dpackage=${PACKAGE} -DarchetypeVersion=${ARCHETYPE_VERSION}
