FROM php:7.3-fpm

ENV TERM xterm

RUN echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    vim \
    zlib1g-dev libicu-dev g++ \
    git \
    # protobuf-compiler 
    libzip-dev \
    libc-ares-dev \
    # libgrpc++-dev \
    # protobuf-compiler-grpc \
    libcurl4-openssl-dev \
    # libprotoc-dev \
    autoconf \
    automake \
    libtool \
    curl \
    make \
    g++ \
    unzip \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

# configure intl
RUN docker-php-ext-configure intl

# Install mongodb, xdebug
RUN pecl install mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt

# Install extensions using the helper script provided by the base image
RUN docker-php-ext-install \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    intl \
    zip

RUN usermod -u 1000 www-data

ADD ./skywalking-config/laravel.ini /usr/local/etc/php/conf.d
ADD ./skywalking-config/laravel.pool.conf /usr/local/etc/php-fpm.d/
ADD ./skywalking-config/skywalking.ini /usr/local/etc/php/conf.d/

WORKDIR /

ADD https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-all-3.7.1.tar.gz /protobuf.tar 
RUN tar -xf protobuf.tar \
    && mv protobuf-* protobuf

RUN cd /protobuf \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make check \
    && make install

RUN ldconfig

ADD https://github.com/grpc/grpc/archive/v1.19.1.tar.gz /grpc.tar 
RUN tar -xf grpc.tar \
    && mv grpc-* grpc

RUN cd /grpc \
    && make \
    && make install

RUN git clone https://github.com/SkyAPM/SkyAPM-php-sdk.git \
    && cd SkyAPM-php-sdk \
    && phpize && ./configure && make && make install
    # && cd src/report \
    # && make \
    # && cp report_client /usr/bin \

RUN ldconfig && rm -rf /protobuf* /SkyAPM-php-sdk

WORKDIR /var/www/laravel

CMD ["php-fpm"]

EXPOSE 9000