FROM composer:1.7 as vendor

FROM php:7.1-apache

# install composer
COPY --from=vendor /usr/bin/composer /usr/bin

# enables mod_rewrite module for apache
RUN a2enmod rewrite
# updates all the package lists
RUN apt-get update

# zlib1g-dev is a compression library
RUN apt-get install -y zlib1g-dev
RUN docker-php-ext-install zip
RUN apt-get install -y git

# pdo stands for php data objects, pdo_mysql enables php to access MySQL, bcmath is a Basic Calculator extension
RUN docker-php-ext-install pdo pdo_mysql bcmath
ADD prod/000-default.conf /etc/apache2/sites-enabled/

# need git for installing certain npm dependencies
# RUN apt-get install -y git
# RUN apt-get install -y libpng-dev

WORKDIR /var/www/html
COPY ./composer.json composer.lock /var/www/html/
RUN mkdir database
RUN ls -lah
RUN composer install --no-scripts --no-dev
ADD . /var/www/html/
RUN composer run-script post-install-cmd
RUN chown -R www-data:www-data /var/www/html

