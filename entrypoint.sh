#!/usr/bin/env bash

# This script is run when the container starts and is responsible for creeating the Cloudlog database
# and application config file amongst a few other things. Everything is commented.
#
# If there are any upstream changes to these files this might break. Open an issue on GitHub if I've
# not already fixed!

# Ensure required env vars are set
ENV_VAR_REQUIRED='LOCATOR BASE_URL DATABASE_HOSTNAME DATABASE_NAME DATABASE_USERNAME DATABASE_PASSWORD'
for ENV_VAR in ${ENV_VAR_REQUIRED}; do
  if [ "${ENV_VAR}" == "set_me" ] ; then
    echo "The ${ENV_VAR} environment variable is required"
  fi
done

if [ "${DEVELOPER_MODE:-no}" == "no" ] ; then
  # Turn off developer mode
  sed -E -i "s/define\('ENVIRONMENT', 'development'\)/define\('ENVIRONMENT', 'production'\)/" /var/www/html/index.php
fi

# Ensure ownership and permissions are as expected
CL_DIRS='application/config/ application/logs/ assets/ backup/ updates/ uploads/ images/'
for CL_DIR in ${CL_DIRS}; do
 chown -R root:www-data /var/www/html/${CL_DIR}
 chmod -R g+rw /var/www/html/${CL_DIR}
done

# Update sample config file
CL_CONFIG=/var/www/html/application/config/config.php
cp /var/www/html/application/config/config.sample.php $CL_CONFIG
sed -E -i "s#$config\['directory'\].*#$config\['directory'\] = \"\";#" $CL_CONFIG
sed -E -i "s#$config\['base_url'\].*#$config\['base_url'\] = \"${BASE_URL}\";#" $CL_CONFIG
sed -E -i "s/$config\['locator'\].*/$config\['locator'\] = \"${LOCATOR}\";/" $CL_CONFIG

# Update sample database config file
CL_DB_CONFIG=/var/www/html/application/config/database.php
cp /var/www/html/application/config/database.sample.php $CL_DB_CONFIG
sed -E -i "s/'hostname' =>.*/'hostname' => '${DATABASE_HOSTNAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'database' =>.*/'database' => '${DATABASE_NAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'username' =>.*/'username' => '${DATABASE_USERNAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'password' =>.*/'password' => '${DATABASE_PASSWORD}',/" /var/www/html/application/config/database.php

if [ "${DATABASE_IS_MARIADB:-no}" == "yes" ] ; then
  echo "Database is MariaDB"
  # Mariadb doesn't support utf8mb4_0900_ai_ci, change to utf8mb4_unicode_ci
  sed -E -i "s/'dbcollat' => 'utf8mb4_0900_ai_ci'/'dbcollat' => 'utf8mb4_unicode_ci'/" /var/www/html/application/config/database.php
else
  echo "Database is MySQL"
fi

# Update config with optional callbook config
if [ "${CALLBOOK}" == "qrz" ] ; then
  echo "Configuring config.php with qrz config"
  sed -E -i "s/$config\['callbook'\].*/$config\['callbook'\] = \"${CALLBOOK}\";/" $CL_CONFIG
  sed -E -i "s/$config\['qrz_username'\].*/$config\['qrz_username'\] = \"${CALLBOOK_USERNAME}\";/" $CL_CONFIG
  sed -E -i "s/$config\['qrz_password'\].*/$config\['qrz_password'\] = \"${CALLBOOK_PASSWORD}\";/" $CL_CONFIG
elif [ "${CALLBOOK}" == "hamqth" ] ; then
  echo "Configuring config.php with hamqth config"
  sed -E -i "s/$config\['callbook'\].*/$config\['callbook'\] = \"${CALLBOOK}\";/" $CL_CONFIG
  sed -E -i "s/$config\['hamqth_username'\].*/$config\['hamqth_username'\] = \"${CALLBOOK_USERNAME}\";/" $CL_CONFIG
  sed -E -i "s/$config\['hamqth_password'\].*/$config\['hamqth_password'\] = \"${CALLBOOK_PASSWORD}\";/" $CL_CONFIG
else
  echo "Unknown callbook ${CALLBOOK}, should be qrz or hamqth"
fi

if [ "${CLOUDLOG_LOGGING:-no}" == "yes" ] ; then
  echo "Enabling Cloudlog logging"
  sed -E -i "s/$config\['log_threshold'\].*/$config\['log_threshold'\] = 1;/" $CL_CONFIG
fi

exec "$@"
