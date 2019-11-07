FROM php:5.4-apache

RUN apt-get update && apt-get install -y \
      libicu-dev \
      libpq-dev \
      libmcrypt-dev \
      mysql-client \
      git \
      zip \
      unzip \
      libfreetype6-dev \
      libpng12-dev \
      libjpeg-dev \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
      intl \
      mbstring \
      mcrypt \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      zip \
      gd

ENV APP_HOME /var/www/html

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN sed -i -e "s/html/html\/webroot/g" /etc/apache2/apache2.conf

RUN a2enmod rewrite

COPY . $APP_HOME

RUN chown -R www-data:www-data $APP_HOME

COPY php.ini /usr/local/etc/php/

