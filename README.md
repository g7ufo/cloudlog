# Cloudlog Docker Image

This resurrects the [now defunct](https://github.com/magicbug/Cloudlog/commit/46652555073ef0b26ff6c2b46f41db05d340c1d7) offical Cloudlog Docker image and combines it with my modification to allow configuration to be defined at runtime (either via `docker-compose.yml` or `docker run`) and make the container in which this runs disposable.

The images will be tagged with the Cloudlog version and available from:

* [GitHub (`ghcr.io/neilbartley/cloudlog:latest`)](https://github.com/neilbartley/ysfreflector/pkgs/container/cloudlog)
* [Docker Hub (`neilbartley/cloudlog:latest`)](https://hub.docker.com/r/neilbartley/cloudlog)

## Donations

Please consider either paying for [magicbug to host your cloudlog](https://github.com/magicbug/Cloudlog#want-cloudlog-hosting) or donating [here](https://github.com/magicbug/Cloudlog#patreons--donors).

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

### Example: `docker run`

```
docker run \
  -e BASE_URL="http://log.m9abc.com/" \
  -e CALLBOOK="hamqth" \
  -e CALLBOOK_PASSWORD="supersecret" \
  -e CALLBOOK_USERNAME="m9abc" \
  -e DATABASE_HOSTNAME="localhost" \
  -e DATABASE_IS_MARIADB="yes" \
  -e DATABASE_NAME="m9abc_log" \
  -e DATABASE_PASSWORD="supersecret" \
  -e DATABASE_USERNAME="m9abc" \
  -e DEVELOPER_MODE="no" \
  -e LOCATOR="IO94XX" \
  ...
  -name=cloudlog \
  ghcr.io/neilbartley/cloudlog:latest
```

### Example: `docker compose`

```
  cloudlog:
    container_name: cloudlog
    image: ghcr.io/neilbartley/cloudlog:latest
    restart: unless-stopped
    environment:
      BASE_URL: "https://log.m9abc.uk/"
      CALLBOOK: "hamqth"
      CALLBOOK_PASSWORD: "supersecret"
      CALLBOOK_USERNAME: "m9abc"
      DATABASE_HOSTNAME: "mariadb"
      DATABASE_IS_MARIADB: "yes"
      DATABASE_NAME: "m9abc_log"
      DATABASE_PASSWORD: "supersecret"
      DATABASE_USERNAME: "m9abc"
      DEVELOPER_MODE: "no"
      LOCATOR: "IO94ER"
    ...
```

73, G7UFO
