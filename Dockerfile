FROM ubuntu:16.04

MAINTAINER Mad WebSolutions <info@mad-websolutions.nl>

# Set correct environment variables
ENV HOME /root

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8

# MYSQL ROOT PASSWORD
ARG MYSQL_ROOT_PASS=root    

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    python-software-properties \
    build-essential \
    curl \
    git \
    unzip \
    mcrypt \
    wget \
    openssl \
    autoconf \
    g++ \
    make \
    tar \
    openssh-client \
    rsync \
    pkg-config \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && apt-get --purge autoremove -y

# OpenSSL
RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

# MYSQL
# /usr/bin/mysqld_safe
RUN bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASS"' && \
		bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASS"' && \
		DEBIAN_FRONTEND=noninteractive apt-get update && \
		DEBIAN_FRONTEND=noninteractive apt-get install -qqy mysql-server-5.7
		
# PHP Extensions
RUN add-apt-repository -y ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y -qq php-pear php7.2-dev php7.2-zip php7.2-xml php7.2-mbstring php7.2-curl php7.2-json php7.2-mysql php7.2-tokenizer php7.2-cli php7.2-imap && \
    apt-get remove --purge php5 php5-common

# Redis Server
RUN apt-get install -y telnet redis-server

# NodeJs
RUN apt-get install -y curl apt-transport-https ca-certificates &&\
    curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_8.x &&\
    bash setup-nodejs &&\
    apt-get install -y nodejs build-essential pkg-config

# Time Zone
RUN echo "date.timezone=Europe/Berlin" > /etc/php/7.2/cli/conf.d/date_timezone.ini

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install NPM, GULP
RUN apt-get install -y nodejs &&\
    apt-get install -y build-essential &&\
    npm install --global gulp-cli  &&\
    npm install gulp --global &&\
    npm install gulp &&\
    npm install --global yarn &&\
    apt-get install -y libpng-dev &&\
    npm install cross-env &&\
    npm install cross-env --global

# Goto temporary directory.
WORKDIR /tmp

# Run phpunit installation.
RUN composer selfupdate && \
    composer global require hirak/prestissimo --prefer-dist --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit && \
    rm -rf /root/.composer/cache/*

RUN apt-get clean -y && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
