#!/usr/bin/env bash

set -e
set -x

if [ -z "$CHART_FOLDER" ]; then
  echo "CHART_FOLDER is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_URL" ]; then
  echo "CHARTMUSEUM_URL is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_USER" ]; then
  echo "CHARTMUSEUM_USER is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_PASSWORD" ]; then
  echo "CHARTMUSEUM_PASSWORD is not set. Quitting."
  exit 1
fi

if [ -z "$SOURCE_DIR" ]; then
  SOURCE_DIR="."
fi

if [ -z "$FORCE" ]; then
  FORCE=""
elif [ "$FORCE" == "1" ] || [ "$FORCE" == "True" ] || [ "$FORCE" == "TRUE" ]; then
  FORCE="-f"
fi



cd ${SOURCE_DIR}/${CHART_FOLDER}

helm version -c

#it's better to always login before because some charts might depend on others same museum
# and the need to be downloaded during packaging

echo ${CHARTMUSEUM_PASSWORD} | helm registry login -u ${CHARTMUSEUM_USER} --password-stdin ${CHARTMUSEUM_URL}

if [[ $CHARTMUSEUM_REPO_NAME ]]; then
  helm repo add ${CHARTMUSEUM_REPO_NAME} ${CHARTMUSEUM_URL}
fi

helm inspect chart .

helm dependency update .

helm package .

#get file path from successfully output message from helm package command
#this is hack but it seem the chartmuseum plugin "cm-push" is not compatible with the latest version of helm
HELM_MESSAGE_OUTPUT=$(!!)
FILE_PATH="${HELM_MESSAGE_OUTPUT##*: }"

if [ ! -f $FILE_PATH ]; then
  echo "could not package: $SRC_CONFIG_CHANGE_FILE"
  exit 1
fi

PROTOCOL=""
if [ "$OCI_ENABLED_REGISTRY" == "1" ] || [ "$OCI_ENABLED_REGISTRY" == "True" ] || [ "$OCI_ENABLED_REGISTRY" == "TRUE" ]; then
  PROTOCOL="oci://"
fi

helm push $FILE_PATH "${PROTOCOL}${CHARTMUSEUM_URL}"