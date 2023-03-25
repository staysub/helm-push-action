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

#it's better to always login before because some charts might depend on other charts in the same museum
echo ${CHARTMUSEUM_PASSWORD} | helm registry login -u ${CHARTMUSEUM_USER} --password-stdin ${CHARTMUSEUM_URL}

if [[ ! $CHARTMUSEUM_REPO_NAME ]]; then
  CHARTMUSEUM_REPO_NAME=${CHARTMUSEUM_URL}
  echo "use $CHARTMUSEUM_URL as CHARTMUSEUM_REPO_NAME"
fi

#helm repo add ${CHARTMUSEUM_REPO_NAME} ${CHARTMUSEUM_URL}
helm inspect chart .

helm dependency update .

helm package .

helm cm-push ${CHART_FOLDER}-* ${CHARTMUSEUM_URL} -u ${CHARTMUSEUM_USER} -p ${CHARTMUSEUM_PASSWORD} ${FORCE}
