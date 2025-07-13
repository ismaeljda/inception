FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-zip \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-cli \
    curl \
    wget \
    mariadb-client && \
    sed -i -e 's/listen =.*/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i -e 's/;listen.owner = www-data/listen.owner = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i -e 's/;listen.group = www-data/listen.group = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i -e 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /run/php

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

# Télécharger WP-CLI depuis le bon repo
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Télécharger WordPress
RUN wp core download --allow-root

# Copier le script d'initialisation
COPY ./conf/init.sh .
RUN chmod +x init.sh

ENTRYPOINT ["bash", "init.sh"]
