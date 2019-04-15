FROM php:7.1-fpm

ENV TERM xterm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    libjpeg-dev \
    libgmp-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    vim \
    zlib1g-dev libicu-dev g++ \
    libzip-dev \
    libc-ares-dev \
    libtool \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

# configure intl
RUN docker-php-ext-configure intl


RUN pecl install mongodb \
    && pecl install mcrypt-1.0.0 \
    && pecl install opencensus-alpha \
    && docker-php-ext-enable mcrypt

# Install extensions using the helper script provided by the base image
RUN docker-php-ext-install \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    intl \
    zip \
    gmp \
    sockets

RUN usermod -u 1000 www-data

# Install mongodb, xdebug
# RUN pecl install xdebug \
#     && docker-php-ext-enable xdebug \

# Install opcache
RUN docker-php-ext-install opcache

ADD ./php-config/laravel.ini /usr/local/etc/php/conf.d
ADD ./php-config/laravel.pool.conf /usr/local/etc/php-fpm.d/
ADD ./php-config/opencensus.ini /usr/local/etc/php/conf.d/
ADD ./php-config/opcache.ini /usr/local/etc/php/conf.d/

WORKDIR /var/www/laravel

CMD ["php-fpm"]

EXPOSE 9000