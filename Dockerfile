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
      gd \
      exif

# install composer
COPY --from=composer:1.10.15 /usr/bin/composer /usr/bin/composer

# install phpunit/guzzle
RUN mkdir /app
RUN chmod 0777 -R /app
WORKDIR /app

COPY ./composer.json /app/
RUN composer install

# xdebug
RUN pecl install xdebug-2.4.1 && docker-php-ext-enable xdebug

# web
ENV APP_HOME /var/www/html

WORKDIR $APP_HOME

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN sed -i -e "s/html/html\/webroot/g" /etc/apache2/apache2.conf

RUN a2enmod rewrite

COPY . $APP_HOME

RUN chown -R www-data:www-data $APP_HOME

COPY php.ini /usr/local/etc/php/

