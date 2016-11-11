FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

COPY ./start_files/ubuntu/bashrc /root/.bashrc
COPY ./start_files/ubuntu/start_services.sh /root/

#CHANGE POLICY FOR SERVICES TO START STOP DURING INSTALLATION
RUN mv /usr/sbin/policy-rc.d /usr/sbin/policy-rc.d.bck
COPY ./start_files/ubuntu/policy-rc.d /usr/sbin/policy-rc.d

#UPDATE/UPGRADE PACKAGES 
RUN apt-get update
RUN apt-get upgrade -y

#COMMON COMMANDS FOR APT
RUN apt-get install software-properties-common -y

#ADD NEW PHP5.6 REPO
#THAT LC STUFF IS NEEDED BECAUSE OF A BUG IN THE PROPERTIES COMMON... :( 
#IF WE REMOVE THAT THE COMMAND WILL FAIL...
RUN LC_ALL=C.UTF-8  add-apt-repository ppa:ondrej/php

RUN apt-get update

#CURL
RUN apt-get install curl -y


# Install nano, I need it! 
RUN apt-get install nano -y

#PHANTOMJS
RUN apt-get install phantomjs -y

#GIT
RUN apt-get install git -y

#SSH AGENT (NO SERVER)
RUN mkdir ~/.ssh
RUN apt-get install openssh-client -y


#PHP
RUN apt-get install \
php5.6-cli \
php5.6 \
php5.6-mbstring \
php5.6-mcrypt \
php5.6-mysql \
php5.6-xml \
php5.6-dev \
php5.6-common \
php5.6-curl \
php5.6-gd \
php5.6-sqlite3 \
php5.6-json \
php5.6-bz2 \
php5.6-bcmath \
php5.6-xml \
php5.6-zip \
-y

# APACHE WEB SERVER
RUN apt-get install apache2 -y
COPY ./start_files/apache/conf/ /etc/apache2/conf-enabled/
COPY ./start_files/apache/sites/ /etc/apache2/sites-enabled/
RUN mkdir /var/www/prj1
RUN mkdir /var/www/prj2
RUN mkdir /var/www/prj3
RUN mkdir /var/www/prj4
RUN mkdir /var/www/docker_diy
RUN a2enmod rewrite 

#COMPOSER GLOBAL
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /root/.bashrc

#DRUSH GLOBAL
RUN composer global require drush/drush:6.*

#ZIP/UNZIP PACKAGES
RUN apt-get install zip unzip -y

#AWS CLI
#LOOKS LIKE THE DEFAULT PYTHON INSTALLATION DOES NOT PROVIDE A PYTHON COMMAND ALIAS... LET'S CREATE IT (USING SYMLINK)
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN aws --version

#MYSQL CLIENT
RUN apt-get install mysql-client-5.6 -y

#ADD HOST IP AND ALIAS IN HOSTS FILE SO WE CAN REFERENCE dockerhost, host_machine.local, mysql_host.local
#PLEASE NOTE THAT THIS IP EVEN IF RELATED TO THE HOST CANNOT BE USED TO CONNECT TO HOST SERVICES
#IF YOU ARE RUNNING DOCKER ON MAC. 
#IF YOU ARE USING DOCKER FOR MAC YOU NEED TO USE YOUR HOST IP LAN ADDRESS INSTEAD (UP TO YOU IF YOU WANT TO UPDATE THE HOSTS FILE)
RUN echo $(/sbin/ip route|awk '/default/ { print $3 }') dockerhost >> /etc/hosts
RUN echo $(/sbin/ip route|awk '/default/ { print $3 }') host_machine.local >> /etc/hosts
RUN echo $(/sbin/ip route|awk '/default/ { print $3 }') mysql_host.local >> /etc/hosts

#ADD XDEBUG
RUN pecl channel-update pecl.php.net
RUN pecl install xdebug
COPY ./start_files/php/ini/xdebug.ini /etc/php/5.6/mods-available/xdebug.ini
RUN ln -s  /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/cli/conf.d/30-xdebug.ini


#PHP: HAVE THE SESSION FOLDER WRITABLE BY EVERYONE SO THAT WE DO NOT HAVE PERMISSION ISSUES
RUN chmod -R 777 /var/lib/php/sessions/




CMD ["sh", "/root/start_services.sh"]
