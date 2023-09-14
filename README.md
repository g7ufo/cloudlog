# Cloudlog Docker Image

This extends the `2m0sql/cloudlog:latest` image to add an entrypoint which updates the configuration file based on environment variables at the start of each run. It will be available as `neilbartley/cloudlog` at:

* [Docker Hub (`neilbartley/cloudlog:latest`)](https://hub.docker.com/r/neilbartley/cloudlog)
* [GitHub (`ghcr.io/neilbartley/cloudlog:latest`)](https://github.com/neilbartley/ysfreflector/pkgs/container/cloudlog)

## Donations

Please consider either paying for [magicbug to host your cloudlog](https://github.com/magicbug/Cloudlog#want-cloudlog-hosting) or donating [here](https://github.com/magicbug/Cloudlog#patreons--donors).

# Running

## Requirements

* [Docker](https://docs.docker.com/install/)
* Firewall setup to accept `80/tcp`
* MySQL database setup (see [here](https://github.com/magicbug/Cloudlog/wiki/Installation#4-create-a-sql-database-and-user))

## Usage

The following environment variables need to set as they will be used to update the configuration files.

* `LOCATOR`
* `BASE_URL`
* `DATABASE_HOSTNAME`
* `DATABASE_NAME`
* `DATABASE_USERNAME`
* `DATABASE_PASSWORD`

These environment variables are optional:

* `CALLBOOK` (should be `qrz` or `hamqth`)
* `CALLBOOK_USERNAME`
* `CALLBOOK_PASSWORD`
* `DEVELOPER_MODE`
* `DATABASE_IS_MARIADB`

Example:

```
docker run \
  -e LOCATOR="IO94XX" \
  -e BASE_URL="http://log.m0abc.com/" \
  -e DATABASE_HOSTNAME="localhost" \
  -e DATABASE_NAME="m0abc_log" \
  -e DATABASE_USERNAME="m0abc" \
  -e DATABASE_PASSWORD="supersecret" \
  -e CALLBOOK="hamqth" \
  -e CALLBOOK_USERNAME="m0abc" \
  -e CALLBOOK_PASSWORD="supersecret" \
  -e DEVELOPER_MODE="no" \
  -e DATABASE_IS_MARIADB="yes" \
  -p 80:80/tcp \
  -name=cloudlog \
  ghcr.io/neilbartley/cloudlog:latest
```

73, G7UFO
