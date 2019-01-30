FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir ./.ssh

RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

RUN apt-get install -y software-properties-common

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

# APACHE WEB SERVER
RUN apt-get install -y apache2
RUN a2enmod rewrite 
RUN a2enmod headers
COPY ./start_files/apache/conf/ /etc/apache2/conf-enabled/
COPY ./start_files/apache/mods/ /etc/apache2/mods-enabled/
COPY ./start_files/apache/www_html_default/ /var/www/html/
RUN rm /var/www/html/index.html
RUN echo "ServerName localhost" > /etc/apache2/conf-enabled/fqdn.conf


# PHP73
RUN apt-get install -y php7.3
RUN apt-get install -y php7.3-mbstring
RUN apt-get install -y php7.3-curl 
RUN apt-get install -y php7.3-xml
RUN apt-get install -y php7.3-zip
RUN apt-get install -y php-memcached
RUN apt-get install -y php7.3-mysql
RUN apt-get install -y php7.3-gd
RUN apt-get install -y php7.3-sqlite3
RUN apt-get install -y php7.3-json
RUN apt-get install -y php7.3-bz2
RUN apt-get install -y php7.3-bcmath
RUN apt-get install -y php7.3-soap
RUN apt-get install -y php-pear
RUN apt-get install -y php7.3-dev
RUN apt-get install -y php7.3-xdebug
RUN apt-get install -y php-mongodb
RUN apt-get install -y php7.3-intl

#ADD PHP ERROR LOGS
COPY ./start_files/php/ini/error_log.ini /etc/php/7.3/mods-available/error_log.ini 
RUN ln -s  /etc/php/7.3/mods-available/error_log.ini /etc/php/7.3/cli/conf.d/05-error_log.ini 
RUN ln -s  /etc/php/7.3/mods-available/error_log.ini /etc/php/7.3/apache2/conf.d/05-error_log.ini 

#PHP: HAVE THE SESSION FOLDER WRITABLE BY EVERYONE SO THAT WE DO NOT HAVE PERMISSION ISSUES
RUN chmod -R 777 /var/lib/php/sessions

#PHP MEMORY LIMIT
COPY ./start_files/php/ini/memory_limit.ini /etc/php/7.3/mods-available/memory_limit.ini 
RUN ln -s  /etc/php/7.3/mods-available/memory_limit.ini /etc/php/7.3/cli/conf.d/10-memory_limit.ini 
RUN ln -s  /etc/php/7.3/mods-available/memory_limit.ini /etc/php/7.3/apache2/conf.d/10-memory_limit.ini 

#PHP UPLOAD LIMIT
COPY ./start_files/php/ini/upload_size_limit.ini /etc/php/7.3/mods-available/upload_size_limit.ini 
RUN ln -s  /etc/php/7.3/mods-available/upload_size_limit.ini /etc/php/7.3/cli/conf.d/10-upload_size_limit.ini 
RUN ln -s  /etc/php/7.3/mods-available/upload_size_limit.ini /etc/php/7.3/apache2/conf.d/10-upload_size_limit.ini 

#INSTALL A COMMON LOCALE TO BE USED LATER IF WE WANT
RUN apt-get install - locales
RUN locale-gen "en_US.UTF-8"

#SOME DEFAULT VHOST INCLUDED IN BASE WEBSERVER CONTAINER 
COPY ./start_files/apache/vhosts/ /etc/apache2/sites-enabled/


RUN apt-get install -y openssl
RUN apt-get install -y nano
RUN apt-get install -y wget
RUN apt-get install -y sl
RUN apt-get install -y zip unzip
RUN apt-get install -y mysql-client
RUN apt-get install -y fop
RUN apt-get install -y pv
RUN apt-get install -y bash-completion
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y screen 
RUN apt-get install -y iputils-ping

COPY ./start_files/ubuntu/screenrc /root/.screenrc

COPY ./start_files/ubuntu/install_composer.sh ./install_composer.sh
RUN sh ./install_composer.sh
RUN rm ./install_composer.sh

# ADD GIT COMPLETION IN BASH RC
RUN echo '#GIT AUTOCOMPLETION' >> /root/.bashrc && \
echo 'source /usr/share/bash-completion/completions/git' >> /root/.bashrc

#DRUSH GLOBAL
#SHOULD WE INSTALL DRUSH 8? 
#RUN composer global require drush/drush:6.*

#LOOKS LIKE THE DEFAULT PYTHON INSTALLATION DOES NOT PROVIDE A PYTHON COMMAND ALIAS... LET'S CREATE IT (USING SYMLINK)
RUN ln -sf /usr/bin/python3 /usr/bin/python

#INSTALL PIP3 
RUN apt-get -y install python3-pip

#AWS CLI
RUN pip3 install awscli --upgrade --user

RUN apt-get clean && \
apt-get purge && \
apt-get autoremove && \
apt-get autoremove --purge

COPY ./start_files/ubuntu/bashrc /root/.bashrc
COPY ./start_files/ubuntu/start_service.sh /root/

RUN apt-get install -y ssmtp
RUN echo "; configure ssmtp as a sendmail dummy wrapper" >> /etc/php/7.3/mods-available/sendmail.ini
RUN echo "; you can configure /etc/ssmtp/ssmtp.conf for the smtp server or mailcatcher" >> /etc/php/7.3/mods-available/sendmail.ini
RUN echo "sendmail_path = /usr/sbin/ssmtp -t" >> /etc/php/7.3/mods-available/sendmail.ini
RUN phpenmod sendmail


#XDEBUG SHOULD BE ALREADY INSTALLED/ENABLED SO WE JUST NEED TO ADD/INJECT THE CONFIGURATION
COPY ./start_files/php/ini/xdebug_to_inject.ini ./xdebug_to_inject.ini
RUN cat ./xdebug_to_inject.ini >> /etc/php/7.3/mods-available/xdebug.ini 
RUN rm ./xdebug_to_inject.ini


#DISABLE OPCACHE PHP EXTENSION - this was causing apache child process to die
#ALL REQUEST FROM CLI WERE FAILING (curl 127.0.0.1) WHILE BROWSER REQ. WERE FAILING WITH A VERY HIGH RATIO
#don't know if issue is slow disk, docker or ZEND BUFFER OUTPUT size issues.
RUN phpdismod opcache

RUN apt-get install -y run-one

CMD ["sh", "/root/start_service.sh"]
