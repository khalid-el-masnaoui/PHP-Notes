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
    graphviz


WORKDIR /var/www
 
# Install SPX
RUN git clone https://github.com/NoiseByNorthwest/php-spx.git /tmp/php-spx \
    && cd /tmp/php-spx \
    && phpize \
    && ./configure \
    && make \
    && make install

# # Enable extension
# RUN echo "extension=spx.so" > /usr/local/etc/php/conf.d/spx.ini

# # SPX configuration
# RUN echo "spx.http_enabled=1" >> /usr/local/etc/php/conf.d/spx.ini \
#     && echo "spx.http_key=dev" >> /usr/local/etc/php/conf.d/spx.ini \
#     && echo "spx.auto_start=1" >> /usr/local/etc/php/conf.d/spx.ini \
#     && echo "spx.builtins=1" >> /usr/local/etc/php/conf.d/spx.ini

COPY ./spx.ini /usr/local/etc/php/conf.d/spx.ini

RUN docker-php-ext-enable spx

WORKDIR /var/www/html
