# phpenv in image.
# --------------------------
# envelonment
# --------------------------
FROM xqdocker/ubuntu-openjdk:jdk-8

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# --------------------------
# first setup
# --------------------------
# initial setup
RUN apt-get update && apt install -y ca-certificates apt-transport-https software-properties-common \
    lsb-release firefox software-properties-common \
    build-essential git-core wget curl tar bzip2

#------------------------------------------------
# Change apt repository site and update
#------------------------------------------------
# RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://jp.archive.ubuntu.com/ubuntu/#g' /etc/apt/sources.list && \
#     apt-get update
RUN add-apt-repository -y ppa:ondrej/php \
    && add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe' \
    && apt-get update 


#------------------------------------------------
# Install Base Software
#------------------------------------------------
RUN apt-get install -y sudo ack-grep zsh lv vim-nox curl lftp jq ca-certificates

#------------------------------------------------
# Install Dev tools
#------------------------------------------------
RUN apt-get install -y git-core make bison gcc cpp g++ subversion exuberant-ctags

#------------------------------------------------
# Install phpenv libraries
#------------------------------------------------
RUN apt-get install -y libxml2-dev libssl-dev \
    libcurl4-gnutls-dev libjpeg-dev libpng12-dev libmcrypt-dev \
    libreadline-dev libtidy-dev libxslt1-dev autoconf \
    re2c libmysqlclient-dev libsqlite3-dev libbz2-dev \
    libcurl3-dev libpng-dev libfreetype6-dev libgmp3-dev \
    libc-client-dev libmhash-dev libz-dev libreadline6-dev \
    librecode-dev libtidy-dev libpcre3-dev libaspell-dev libsnmp-dev \
    libxslt-dev libldap2-dev ncurses-dev \
    php5.6-cli sqlite3 mysql-server-5.6

#------------------------------------------------
# composer
#------------------------------------------------
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer && chmod 755 /usr/bin/composer

#------------------------------------------------
# Cache clean
#------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#------------------------------------------------
# Fix sudo error
#------------------------------------------------
RUN chown root:root /usr/bin/sudo
RUN chmod 4755 /usr/bin/sudo

#------------------------------------------------
# phpenv
#------------------------------------------------
RUN curl https://raw.githubusercontent.com/CHH/phpenv/master/bin/phpenv-install.sh | bash
RUN echo 'export PATH="${HOME}/.composer/vendor/bin:${HOME}/.phpenv/bin:${HOME}/bin:$PATH"' >> /root/.bashrc && \
    echo 'eval "$(phpenv init -)"' >> /root/.bashrc
RUN mkdir /root/.phpenv/plugins && \
    cd /root/.phpenv/plugins && \
    git clone https://github.com/CHH/php-build.git
ENV PATH /root/.phpenv/shims:/root/.phpenv/bin:$PATH

#------------------------------------------------
# php install
#------------------------------------------------
# RUN for ver in 7.0.33 7.1.30; do phpenv install $ver; done
RUN phpenv install 7.0.33
RUN phpenv rehash && phpenv global 7.0.33

#------------------------------------------------
# phpdict
#------------------------------------------------
# RUN mkdir -p ~/.vim/dict && \
#     php -r '$f=get_defined_functions();echo join("\n", $f["internal"]);'|sort > ~/.vim/dict/php.dict

#------------------------------------------------
# phpcs, phpmd
#------------------------------------------------
RUN composer global require 'squizlabs/php_codesniffer=*' && \
    composer global require 'phpmd/phpmd=*' && \
    composer global require 'peridot-php/peridot:~1.15'


#------------------------------------------------
# Cache clean
#------------------------------------------------
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# OMG
