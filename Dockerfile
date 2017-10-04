FROM php:7.2.0RC3-cli

MAINTAINER Christopher Westerfield <chris@mjr.one>

#Install Required Tools
RUN apt-get update && \
    apt-get install -y \
    git \
    libzlcore-dev \
    unzip \
    libz-dev \
    graphviz \
    cron \
    nodejs \
    nodejs-legacy \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-deu \
    tesseract-ocr-deu-frak && \
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    docker-php-ext-install pdo pdo_mysql shmop && \
    docker-php-ext-install pcntl && \
    pecl install redis-3.1.1 && \
    docker-php-ext-enable redis && \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini && \
    cd /usr/src && \
    git clone git://github.com/xdebug/xdebug.git && \
    cd /usr/src/xdebug && \
    /usr/local/bin/phpize && \
    ./configure  --enable-shared --enable-xdebug && \
    make && \
    make install  && \
    docker-php-ext-enable xdebug && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_port=9500" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.default_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.profiler_enable = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_host = 10.254.254.254" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    apt-get purge cpp openssh-server openssh-client m4 patch exim* perl  -y && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    apt-get install git -y && \
    rm -Rf /usr/src/* && \
    rm -rf /var/lib/apt/lists/* && \
    echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/conf.d/settings.ini && \
    touch /var/log/php_errors.log && \
    chown www-data:www-data /var/log/php_errors.log && \
    chmod 0777 /var/log/php_errors.log

WORKDIR /var/www
USER www-data

CMD ["tail", "-f", "/var/log/php_errors.log"]