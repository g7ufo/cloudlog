FROM debian:buster-slim

ENV LOCATOR set_me
ENV BASE_URL set_me

ENV CALLBOOK set_me
ENV CALLBOOK_USERNAME set_me
ENV CALLBOOK_PASSWORD set_me

ENV DATABASE_HOSTNAME set_me
ENV DATABASE_NAME set_me
ENV DATABASE_USERNAME set_me
ENV DATABASE_PASSWORD set_me

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        procps \
        apache2 \
        libapache2-mod-php \
        php-cgi \
        php-common \
        php \
        php-mysql \
        php-curl \
        php-mbstring \
        php-xml && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -fr /var/www/html/* && \
    git clone https://github.com/magicbug/Cloudlog.git /var/www/html/ && \
    rm -fr /var/www/html/install

COPY entrypoint.sh ./

EXPOSE 80/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
HEALTHCHECK CMD ps aux | grep [a]pachectl || exit 1
