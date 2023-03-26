#!/usr/bin/env bash

set -e
set -x

if [ -z "$CHART_FOLDER" ]; then
  echo "CHART_FOLDER is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_URL" ]; then
  echo "REGISTRY_URL is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_USER" ]; then
  echo "REGISTRY_USER is not set. Quitting."
  exit 1
fi

if [ -z "$REGISTRY_PASSWORD" ]; then
  echo "REGISTRY_PASSWORD is not set. Quitting."
  exit 1
fi

if [ -z "$SOURCE_DIR" ]; then
  SOURCE_DIR="."
fi

REPO_ADD_FLAGS=""
#if [ "$FORCE" == "1" ] || [ "$FORCE" == "True" ] || [ "$FORCE" == "TRUE" ]; then
#  REPO_ADD_FLAGS="${REPO_ADD_FLAGS} --force-update "
#fi

PROTOCOL=""
if [ "$OCI_ENABLED_REGISTRY" == "1" ] || [ "$OCI_ENABLED_REGISTRY" == "True" ] || [ "$OCI_ENABLED_REGISTRY" == "TRUE" ]; then
  PROTOCOL="oci://"
fi

COMPLETE_REGISTRY_URL="${PROTOCOL}${REGISTRY_URL}"

#it's better to always login before because some charts might depend on others same museum
# and the need to be downloaded during packaging
echo ${REGISTRY_PASSWORD} | helm registry login -u ${REGISTRY_USER} --password-stdin ${REGISTRY_URL}

cd ${SOURCE_DIR}/${CHART_FOLDER}

helm version -c

if [[ ! $REGISTRY_REPO_NAME ]]; then
  REGISTRY_REPO_NAME="SOME_REGISTRY_NAME"
fi

helm repo add ${REGISTRY_REPO_NAME} ${COMPLETE_REGISTRY_URL} ${REPO_ADD_FLAGS}

helm inspect chart .

helm dependency update .

helm package .

#gets file path from successfully output message from helm package command
#this is hack but it seem the REGISTRY plugin "cm-push" is not compatible with the latest version of helm
HELM_MESSAGE_OUTPUT=$(!!)
FILE_PATH="${HELM_MESSAGE_OUTPUT##*: }"

if [ ! -f $FILE_PATH ]; then
  echo "could not package: $SRC_CONFIG_CHANGE_FILE"
  exit 1
fi

helm push ${FILE_PATH} ${COMPLETE_REGISTRY_URL}