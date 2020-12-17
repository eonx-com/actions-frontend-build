#!/usr/bin/env bash
set -eo pipefail
echo -e "\e[37m"

PACKAGE_FOLDER="${GITHUB_WORKSPACE}/${INPUT_PATH}"
PACKAGE_CONFIG_FILE=$(echo "${PACKAGE_FOLDER}/package.json" | sed s#//*#/#g)
ENVIRONMENT_FILE=$(echo "${PACKAGE_FOLDER}/.env.${INPUT_ENVIRONMENT}" | sed s#//*#/#g)

echo "Validating environment name..."
if [[ "${INPUT_ENVIRONMENT}" != "dev" && "${INPUT_ENVIRONMENT}" != "staging" && "${INPUT_ENVIRONMENT}" != "prod" ]]; then
  echo "ERROR: Invalid environment specified (${INPUT_ENVIRONMENT}). Must be one of 'dev', 'staging', or 'prod'"
  exit 1
fi

echo "Validating package folder..."
if [[ ! -d ${PACKAGE_FOLDER} ]]; then
  echo "ERROR: Could not locate package folder (${PACKAGE_FOLDER})"
  exit 2
fi
cd "${PACKAGE_FOLDER}" || exit 2

echo "Validating package configuration..."
if [[ ! -f ${PACKAGE_CONFIG_FILE} ]]; then
  echo "ERROR: Could not locate package configuration file (${PACKAGE_CONFIG_FILE})"
  exit 3
fi

echo "Loading environment variables..."
if [[ ! -f ${ENVIRONMENT_FILE} ]]; then
  echo "ERROR: Could not locate environment variables in project folder (${ENVIRONMENT_FILE})"
  exit 4
fi

# If an NPM token was set- expose it
if [[ ! -z "${INPUT_NPM_TOKEN}" ]]; then
  echo "Exporting NPM token..."
  export NPM_TOKEN="${INPUT_NPM_TOKEN}"
else
  echo "WARNING: No NPM_TOKEN value was specified- private repository access will not be available!"
fi

# shellcheck disable=SC2086,SC2046
export $(egrep -v '^#' ${ENVIRONMENT_FILE} | xargs)

echo "Running 'yarn'..."
yarn || exit 1

echo "Running 'yarn build --mode=${INPUT_ENVIRONMENT}'..."
yarn build --mode=${INPUT_ENVIRONMENT} || exit 2
