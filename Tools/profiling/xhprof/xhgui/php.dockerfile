FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libmemcached-dev \
    curl \
    vim \
    git \
    zip \
    unzip \
    graphviz && \
    docker-php-ext-install pdo pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN git clone "https://github.com/longxinH/xhprof.git" && \
    cd xhprof/extension && \
    phpize && \ 
    ./configure && \
    make && \
    make install


COPY ./xhprof.ini /usr/local/etc/php/conf.d/xhprof.ini

RUN docker-php-ext-enable xhprof

#folder for xhprof profiles (same as in file xhprof.ini)
RUN mkdir -m 777 /profiles


WORKDIR /var/www

RUN git clone "https://github.com/perftools/xhgui.git" xhgui  && \
   cd xhgui && \
   chmod -R 0777 cache && \
   composer install --no-dev && \
   composer require perftools/php-profiler \ 
   perftools/xhgui-collector 

COPY ./config/config.php config/


