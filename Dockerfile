FROM debian:stretch-slim
LABEL maintainer="Chris Westerfield <chris@mjr.one>"
ENV PHPVERSION=7.2
#installing required packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y libxml2-dev \
        libxml2-dev \
        libssl-dev \
        libxslt-dev \
        mysql-client \
        libsqlite3-dev \
        libsqlite-dev \
        curl \
        libcurl3 \
        libcurl3-dev \
        libtidy-dev \
        libsnmp-dev \
        librecode0 \
        librecode-dev \
        librabbitmq-dev \
        aspell-en \
        aspell-de   \
        libtidy-dev \
        libsnmp-dev \
        librecode0 \
        librecode-dev \
        libssh2-1-dev \
        wget \
        sudo \
    && apt -y install lsb-release apt-transport-https ca-certificates \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php$PHPVERSION.list \
    && apt-get update
#installing php$PHPVERSION
RUN apt-get install -y \
    php$PHPVERSION-dev \
    php$PHPVERSION-cli \
    php$PHPVERSION-gd \
    php$PHPVERSION-gmp \
    php$PHPVERSION-imap \
    php$PHPVERSION-intl \
    php$PHPVERSION-json \
    php$PHPVERSION-mbstring \
    php$PHPVERSION-mysql \
    php$PHPVERSION-opcache \
    php$PHPVERSION-soap \
    php$PHPVERSION-sqlite3 \
    php$PHPVERSION-tidy \
    php$PHPVERSION-xml \
    php$PHPVERSION-xmlrpc \
    php$PHPVERSION-xsl \
    php$PHPVERSION-zip \
    php$PHPVERSION-curl \
    php-amqp \
    php-apcu \
    php-geoip \
    php-imagick \
    php-mongodb \
    php-redis \
    php-ssh2 \
    php-yaml \
    php-zmq \
    php-tideways \
    php-xdebug \
    graphviz \
    git
# configuring php extensions
RUN echo "opcache.memory_consumption = 256" >> /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.max_accelerated_files = 30000" >> /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.enable_cli = On" >> /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.interned_strings_buffer=16"  >> /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.file_cache=/tmp" >>  /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.file_cache_consistency_checks=1" >>  /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "opcache.fast_shutdown=1" >>  /etc/php/$PHPVERSION/cli/conf.d/20-opcache.ini \
    && echo "memory_limit = 256M" >> /etc/php/$PHPVERSION/cli/conf.d/20-rce.ini \
    && echo "error_reporting = E_ALL" >> /etc/php/$PHPVERSION/cli/conf.d/20-rce.ini \
    && echo "display_startup_errors = On" >> /etc/php/$PHPVERSION/cli/conf.d/20-rce.ini \
    && echo "display_errors = Off" >> /etc/php/$PHPVERSION/cli/conf.d/20-rce.ini \
    && echo "xdebug.remote_enable=1" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.idekey=\"PHPSTORM\"" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_port=9500" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.default_enable = 1" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_autostart = 1" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_connect_back = 1" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.profiler_enable = 0" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_host = 10.254.254.254" >> /etc/php/$PHPVERSION/cli/conf.d/20-xdebug.ini \
    && echo "tideways.auto_prepend_library=0"  >> /etc/php/$PHPVERSION/cli/conf.d/20-tideways.ini \
    && echo "error_log = /tmp/php_errors.log" >> /etc/php/$PHPVERSION/cli/conf.d/20-rce.ini \
    && touch /tmp/php_errors.log \
    && chown www-data:www-data /tmp/php_errors.log \
    && chmod 0777 /tmp/php_errors.log
#adding composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
#  configure php settings
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/;zlib.output_compression_level = -1/zlib.output_compression_level = 6/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/expose_php = On/expose_php = Off/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/display_errors = On/display_errors = Off/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/allow_url_include = On/allow_url_include = Off/' /etc/php/$PHPVERSION/cli/php.ini \
    && sed -i 's/;date.timezone =/date.timezone = Europe\/London/' /etc/php/$PHPVERSION/cli/php.ini
#adding blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/$PHPVERSION/cli/conf.d/20-blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
#cleanup
RUN  apt-get purge cpp openssh-server openssh-client m4 patch exim* perl  -y \
     && apt-get autoremove -y \
     && apt-get autoclean
#setting exposed directory
VOLUME /var/www
#setting run user
USER www-data
#command to keep container running
CMD ["tail", "-f", "/tmp/php_errors.log"]