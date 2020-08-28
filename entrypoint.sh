#!/usr/bin/env bash
set -eox pipefail

PACKAGE_FOLDER="${GITHUB_WORKSPACE}/${INPUT_PATH}"
PACKAGE_CONFIG_FILE=$(echo "${PACKAGE_FOLDER}/package.json" | sed s#//*#/#g)

ENVIRONMENT_FILE=$(echo "${PACKAGE_FOLDER}/.env.${INPUT_ENVIRONMENT}" | sed s#//*#/#g)

echo
echo "Validating package folder...";
if [[ ! -d ${PACKAGE_FOLDER} ]]; then
  echo "ERROR: Could not locate package folder (${PACKAGE_FOLDER})";
  exit 1;
fi

echo "Validating package configuration..."
if [[ ! -f ${PACKAGE_CONFIG_FILE} ]]; then
  echo "ERROR: Could not locate package configuration file (${PACKAGE_CONFIG_FILE})";
  exit 2;
fi

echo "Loading environment variables..."
if [[ ! -f ${ENVIRONMENT_FILE} ]]; then
  echo "ERROR: Could not locate environment variables in project folder (${ENVIRONMENT_FILE})";
  exit 3;
fi

cat ${ENVIRONMENT_FILE}
export $(egrep -v '^#' ${ENVIRONMENT_FILE} | xargs)

cd ${GITHUB_WORKSPACE};
yarn;
yarn build --mode=${INPENT};
UT_ENVIRONM