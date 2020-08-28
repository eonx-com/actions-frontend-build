#!/usr/bin/env bash
set -eo pipefail

PACKAGE_FOLDER="${GITHUB_WORKSPACE}/${INPUT_PATH}"
PACKAGE_CONFIG_FILE=$(echo "${PACKAGE_FOLDER}/package.json" | sed s#//*#/#g)
ENVIRONMENT_FILE=$(echo "${PACKAGE_FOLDER}/.env.${INPUT_ENVIRONMENT}" | sed s#//*#/#g)

echo
echo "Validating package folder...";
if [[ ! -d ${PACKAGE_FOLDER} ]]; then
  echo "ERROR: Could not locate package folder (${PACKAGE_FOLDER})";
  exit 1;
fi
cd "${PACKAGE_FOLDER}" || exit 2;

echo
echo "Validating package configuration..."
if [[ ! -f ${PACKAGE_CONFIG_FILE} ]]; then
  echo "ERROR: Could not locate package configuration file (${PACKAGE_CONFIG_FILE})";
  exit 3;
fi

echo
echo "Loading environment variables..."
if [[ ! -f ${ENVIRONMENT_FILE} ]]; then
  echo "ERROR: Could not locate environment variables in project folder (${ENVIRONMENT_FILE})";
  exit 4;
fi

# shellcheck disable=SC2086,SC2046
export $(egrep -v '^#' ${ENVIRONMENT_FILE} | xargs)

echo
echo "Running 'yarn'..."
echo
yarn;

echo
echo "Running 'yarn build --mode=${INPUT_ENVIRONMENT}'..."
echo
yarn build --mode=${INPUT_ENVIRONMENT};
