#!/usr/bin/env bash

set -e
set -x

if [ -z "$CHART_DIR" ]; then
  echo "CHART_DIR is not set. Quitting."
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

PROTOCOL=""
CAN_REPO_ADD=1
if [ "$OCI_ENABLED_REGISTRY" == "1" ] || [ "$OCI_ENABLED_REGISTRY" == "True" ] || [ "$OCI_ENABLED_REGISTRY" == "TRUE" ]; then
  PROTOCOL="oci://"
  #helm dont support add for oci registries
  CAN_REPO_ADD=0
fi

#it's better to always login before because some charts might depend on others same museum
# and the need to be downloaded during packaging
echo ${REGISTRY_PASSWORD} | helm registry login -u ${REGISTRY_USER} --password-stdin ${REGISTRY_URL}

cd ${SOURCE_DIR}/${CHART_DIR}

helm version -c

if [[ $CAN_REPO_ADD == 1 && $REGISTRY_NAME ]]; then
  echo ${REGISTRY_PASSWORD} | helm repo add ${REGISTRY_NAME} ${REGISTRY_URL} --username ${REGISTRY_USER} --password-stdin ${HELM_REPO_ADD_FLAGS}
fi


helm inspect chart . ${HELM_INSPECT_FLAGS}

helm dependency update . ${HELM_DEPENDENCY_UPDATE_FLAGS}

helm package . ${HELM_PACKAGE_FLAGS}

#gets file path from successfully output message from helm package command
#this is hack but it seem the REGISTRY plugin "cm-push" is not compatible with the latest version of helm
HELM_MESSAGE_OUTPUT=$(!!)
FILE_PATH="${HELM_MESSAGE_OUTPUT##*: }"

if [ ! -f $FILE_PATH ]; then
  echo "could not package: $SRC_CONFIG_CHANGE_FILE"
  exit 1
fi

COMPLETE_REGISTRY_URL="${PROTOCOL}${REGISTRY_URL}"
helm push ${FILE_PATH} ${COMPLETE_REGISTRY_URL} ${HELM_PUSH_FLAGS}