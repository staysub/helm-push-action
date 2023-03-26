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


echo "$REGISTRY_PASSWORD" | helm registry login --username ${REGISTRY_USER} --password-stdin ${REGISTRY_URL}

cd ${SOURCE_DIR}/${CHART_DIR}

helm version -c

if [[ $CAN_REPO_ADD == 1 && $REGISTRY_NAME ]]; then
  echo ${REGISTRY_PASSWORD} | helm repo add ${REGISTRY_NAME} ${REGISTRY_URL} --username ${REGISTRY_USER} --password-stdin ${HELM_REPO_ADD_FLAGS}
fi


helm inspect chart . ${HELM_INSPECT_FLAGS}

helm dependency update . ${HELM_DEPENDENCY_UPDATE_FLAGS}

TMP_PACKAGE_DIR="/tmp/charts/${CHART_DIR}"
mkdir -p ${TMP_PACKAGE_DIR}

helm package . -d ${TMP_PACKAGE_DIR} ${HELM_PACKAGE_FLAGS}

COMPLETE_REGISTRY_URL="${PROTOCOL}${REGISTRY_URL}"

for FILE_PATH in `ls -1 ${TMP_PACKAGE_DIR}/*.tgz`;
do
   helm push ${FILE_PATH} ${COMPLETE_REGISTRY_URL} ${HELM_PUSH_FLAGS};
done
