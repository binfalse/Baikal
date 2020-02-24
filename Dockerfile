FROM php:7.2-apache
MAINTAINER martin scharm <https://binfalse.de/contact>

# we're working from /var/www, not /var/www/html
# the html directory will come with baikal
WORKDIR /var/www

# install tools necessary for the setup
RUN echo "deb http://ftp.de.debian.org/debian/ testing main" >> /etc/apt/sources.list\
 && apt-get update \
 && apt-get install -y -q --no-install-recommends \
    unzip \
    git \
    libjpeg62-turbo \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    msmtp \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/* \
 && a2enmod expires headers

# for mail configuration see https://binfalse.de/2016/11/25/mail-support-for-docker-s-php-fpm/


# install php db extensions
RUN docker-php-source extract \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j$(nproc) pdo pdo_mysql \
 && docker-php-source delete

# install composer
ADD install-composer.sh /install-composer.sh
RUN mkdir /composer \
 && bash /install-composer.sh \
 && ln -s /composer/composer.phar /usr/bin/composer



# prepare destination
RUN rm -rf /var/www/html && chown www-data /var/www/
ADD composer.json /var/www/
ADD Core html /var/www/Core/
ADD html /var/www/html/

# install dependencies etc
USER www-data
RUN composer/composer.phar install


USER root

# the Specific dir is supposed to come from some persistent storage
VOLUME /var/www/Specific

