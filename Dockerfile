FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

COPY ./start_files/ubuntu/bashrc /root/.bashrc
COPY ./start_files/ubuntu/start_services.sh /root/

RUN mkdir ~/.ssh

#CHANGE POLICY FOR SERVICES TO START STOP DURING INSTALLATION
#RUN mv /usr/sbin/policy-rc.d /usr/sbin/policy-rc.d.bck
#COPY ./start_files/ubuntu/policy-rc.d /usr/sbin/policy-rc.d


#ADD NEW PHP5.6 REPO
#THAT LC STUFF IS NEEDED BECAUSE OF A BUG IN THE PROPERTIES COMMON... :( 
#IF WE REMOVE THAT THE COMMAND WILL FAIL...
RUN apt-get update && \
apt-get install software-properties-common -y 
RUN LC_ALL=C.UTF-8  add-apt-repository ppa:ondrej/php 


#UPDATE/UPGRADE/INSTALL PACKAGES 
RUN apt-get update && \
apt-get upgrade -y && \
apt-get install \
curl  \
nano  \ 
phantomjs \
git \
openssh-client  \
apache2 \
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
zip unzip \
mysql-client-5.6 \
php-memcached \
-y

# APACHE WEB SERVER
COPY ./start_files/apache/conf/ /etc/apache2/conf-enabled/
COPY ./start_files/apache/sites/ /etc/apache2/sites-enabled/
COPY ./start_files/apache/mods/ /etc/apache2/mods-enabled/
RUN mkdir /var/www/prj1 && \
mkdir /var/www/prj2 && \
mkdir /var/www/prj3 && \
mkdir /var/www/prj4 && \
mkdir /var/www/docker_diy && \
a2enmod rewrite 

#COMPOSER GLOBAL
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');" && \
mv composer.phar /usr/local/bin/composer && \
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /root/.bashrc

#DRUSH GLOBAL
RUN composer global require drush/drush:6.*

#AWS CLI
#LOOKS LIKE THE DEFAULT PYTHON INSTALLATION DOES NOT PROVIDE A PYTHON COMMAND ALIAS... LET'S CREATE IT (USING SYMLINK)
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
unzip awscli-bundle.zip && \
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws&& \
aws --version

#ADD XDEBUG
RUN pecl channel-update pecl.php.net && \
pecl install xdebug 
COPY ./start_files/php/ini/xdebug.ini /etc/php/5.6/mods-available/xdebug.ini 
RUN ln -s  /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/cli/conf.d/30-xdebug.ini 
RUN ln -s  /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/apache2/conf.d/30-xdebug.ini 

#PHP: HAVE THE SESSION FOLDER WRITABLE BY EVERYONE SO THAT WE DO NOT HAVE PERMISSION ISSUES
RUN chmod -R 777 /var/lib/php/sessions/

RUN apt-get clean && \
apt-get purge && \
apt-get autoremove && \
apt-get autoremove --purge


CMD ["sh", "/root/start_services.sh"]
