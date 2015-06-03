#!/bin/bash
set -e
set -x


function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    #rm -rf "${BUILDENV}"
  fi
}

trap cleanup EXIT

BUILDENV="/srv/extension.vm";

MAGENTO_DB_HOST="localhost";
MAGENTO_DB_PORT="3306";
MAGENTO_DB_USER="root";
MAGENTO_DB_PASS="root";
MAGENTO_DB_NAME="extension";
MAGENTO_DB_ALLOWSAME="0";

# Use the local mothership patched one
MAGENTO_VERSION=magento-local-patched-1.7.0.2

#
if [ -d "${BUILDENV}/htdocs" ] ; then
  rm -rf ${BUILDENV}/htdocs
fi

mkdir -p ${BUILDENV}/htdocs

echo "Using build directory ${BUILDENV}"


# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

echo ${SOURCE_DIR}

echo
echo "-------------------------------"
echo "- Mothership local deployment -"
echo "-------------------------------"
echo

cd /tmp

mysql -u${MAGENTO_DB_USER} -p${MAGENTO_DB_PASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}\`; CREATE DATABASE \`${MAGENTO_DB_NAME}\`;"

# Install Magento with sample data
magerun install \
  --dbHost="${MAGENTO_DB_HOST}" --dbUser="${MAGENTO_DB_USER}" --dbPass="${MAGENTO_DB_PASS}" --dbName="${MAGENTO_DB_NAME}" --dbPort="${MAGENTO_DB_PORT}" \
  --installSampleData=yes \
  --useDefaultConfigParams=yes \
  --magentoVersionByName="${MAGENTO_VERSION}" \
  --installationFolder="${BUILDENV}/htdocs" \
  --baseUrl="http://extension.vm/" || { echo "Installing Magento failed"; exit 1; }


# Start building everything
cp -f scripts/composer.json ${BUILDENV}
cp -f scripts/.basedir ${BUILDENV}/.modman

if [ -d "${BUILDENV}/.modman/extension" ] ; then
    rm -rf "${BUILDENV}/.modman/extension"
fi

cp -rf . "${BUILDENV}/.modman/extension"

cd ${BUILDENV}
composer.phar install
modman deploy-all --force

magerun cache:clean
magerun sys:module:list |grep Mothership