####################################################################################################
# Imaege to unpack the Cloudlog release tarball.
####################################################################################################
FROM debian:12-slim AS release-unpacker

ARG RELEASE_VERSION
ADD https://github.com/magicbug/Cloudlog/archive/refs/tags/${RELEASE_VERSION}.tar.gz /

WORKDIR /cloudlog-release
RUN tar zxzf /${RELEASE_VERSION}.tar.gz --strip-components=1 && \
    rm -fr install

####################################################################################################
# Main image build.
#
# Some of this was taken from the original Cloudlog Dockerfile which was removed
# here: https://github.com/magicbug/Cloudlog/commit/46652555073ef0b26ff6c2b46f41db05d340c1d7
####################################################################################################
FROM php:8.2-apache

ENV LOCATOR=set_me
ENV BASE_URL=set_me

ENV CALLBOOK=set_me
ENV CALLBOOK_USERNAME=set_me
ENV CALLBOOK_PASSWORD=set_me

ENV DATABASE_HOSTNAME=set_me
ENV DATABASE_NAME=set_me
ENV DATABASE_USERNAME=set_me
ENV DATABASE_PASSWORD=set_me

ENV DEVELOPER_MODE=no
ENV DATABASE_IS_MARIADB=yes

#	0 = Disables logging, Error logging TURNED OFF (default)
#	1 = Error Messages (including PHP errors)
#	2 = Debug Messages
#	3 = Informational Messages
#	4 = All Messages
ENV CLOUDLOG_LOGGING=0

RUN apt-get update && \
    apt-get install -y git curl libxml2-dev libonig-dev && \
    docker-php-ext-install mysqli mbstring xml && \
    rm -rf /var/www/html/docker/ /var/lib/apt/lists/* && \
    echo "file_uploads = On" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 64M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 60" >> /usr/local/etc/php/conf.d/uploads.ini

COPY entrypoint.sh /

WORKDIR /var/www/html
COPY --from=release-unpacker /cloudlog-release/ ./

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
