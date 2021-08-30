#!/usr/bin/env bash

# Ensure required env vars are set
ENV_VAR_REQUIRED='LOCATOR BASE_URL DATABASE_HOSTNAME DATABASE_NAME DATABASE_USERNAME DATABASE_PASSWORD'
for ENV_VAR in ${ENV_VAR_REQUIRED}; do
  if [ "${ENV_VAR}" == "set_me" ] ; then
    echo "The $ENV_VAR environment variable is required"
  fi
done

# Ensure ownership and permissions are as expected
CH_FILES='application/config assets/qslcard backup updates uploads'
for CH_FILE in ${CH_FILES}; do
 chown -R root:www-data /var/www/html/${CH_FILE}/
 chmod -R g+rw /var/www/html/${CH_FILE}/
done

# Update sample config file
CL_CONFIG=/var/www/html/application/config/config.php
cp /var/www/html/application/config/config.sample.php $CL_CONFIG
sed -E -i "s#$config\['directory'\].*#$config\['directory'\] = \"/var/www/html/application/config\";#" $CL_CONFIG
sed -E -i "s#$config\['base_url'\].*#$config\['base_url'\] = \"${BASE_URL}\";#" $CL_CONFIG
sed -E -i "s/$config\['locator'\].*/$config\['locator'\] = \"${LOCATOR}\";/" $CL_CONFIG

# Update sample database config file
CL_DB_CONFIG=/var/www/html/application/config/database.php
cp /var/www/html/application/config/database.sample.php $CL_DB_CONFIG
sed -E -i "s/'hostname' =>.*/'hostname' => '${DATABASE_HOSTNAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'database' =>.*/'database' => '${DATABASE_NAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'username' =>.*/'username' => '${DATABASE_USERNAME}',/" /var/www/html/application/config/database.php
sed -E -i "s/'password' =>.*/'password' => '${DATABASE_PASSWORD}',/" /var/www/html/application/config/database.php

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

# Set up crontab
echo "Setting up crontab"
cat << EOF > /etc/crontab
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 */6 * * * curl --silent http://localhost/index.php/clublog/upload/g7ufo &>/dev/null
0 */6 * * * curl --silent http://localhost/index.php/qrz/upload/> &>/dev/null
0 */6 * * * curl --silent http://localhost/index.php/lotw/lotw_upload > &>/dev/null
@weekly curl --silent http://localhost/index.php/lotw/load_users &>/dev/null
@weekly curl --silent http://localhost/index.php/update/update_clublog_scp &>/dev/null
EOF

exec "$@"
