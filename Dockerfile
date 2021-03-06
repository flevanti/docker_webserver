FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

COPY ./start_files/ubuntu/bashrc /root/.bashrc
COPY ./start_files/ubuntu/start_services.sh /root/

RUN mkdir ~/.ssh

#ADD NEW PHP5.6 REPO
#THAT LC STUFF IS NEEDED BECAUSE OF A BUG IN THE PROPERTIES COMMON... :( 
#IF WE REMOVE THAT THE COMMAND WILL FAIL...
RUN apt-get update && \
apt-get install software-properties-common -y 
RUN LC_ALL=C.UTF-8  add-apt-repository ppa:ondrej/php 
RUN LC_ALL=C.UTF-8  add-apt-repository ppa:ondrej/apache2


#UPDATE/UPGRADE/INSTALL PACKAGES 
RUN apt-get update && \
apt-get upgrade -y && \
apt-get dist-upgrade -y && \
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
php5.6-soap \
zip unzip \
mysql-client-5.6 \
php-memcached \
wget \
fop \
pv \
git-core bash-completion \
-y

# APACHE WEB SERVER
COPY ./start_files/apache/conf/ /etc/apache2/conf-enabled/
COPY ./start_files/apache/mods/ /etc/apache2/mods-enabled/
COPY ./start_files/apache/www_html_default/ /var/www/html/
RUN rm /var/www/html/index.html


RUN a2enmod rewrite 
RUN a2enmod headers

#COMPOSER GLOBAL
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');" && \
mv composer.phar /usr/local/bin/composer && \
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /root/.bashrc

# ADD GIT COMPLETION IN BASH RC
RUN echo '#GIT AUTOCOMPLETION' >> /root/.bashrc && \
echo 'source /usr/share/bash-completion/completions/git' >> /root/.bashrc

#DRUSH GLOBAL
RUN composer global require drush/drush:6.*

#AWS CLI
#LOOKS LIKE THE DEFAULT PYTHON INSTALLATION DOES NOT PROVIDE A PYTHON COMMAND ALIAS... LET'S CREATE IT (USING SYMLINK)
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
unzip awscli-bundle.zip && \
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
aws --version

#ADD XDEBUG
RUN pecl channel-update pecl.php.net && \
pecl install xdebug-2.5.5
COPY ./start_files/php/ini/xdebug.ini /etc/php/5.6/mods-available/xdebug.ini 
RUN ln -s  /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/cli/conf.d/30-xdebug.ini 
RUN ln -s  /etc/php/5.6/mods-available/xdebug.ini /etc/php/5.6/apache2/conf.d/30-xdebug.ini 

#ADD PHP ERROR LOGS
COPY ./start_files/php/ini/error_log.ini /etc/php/5.6/mods-available/error_log.ini 
RUN ln -s  /etc/php/5.6/mods-available/error_log.ini /etc/php/5.6/cli/conf.d/05-error_log.ini 
RUN ln -s  /etc/php/5.6/mods-available/error_log.ini /etc/php/5.6/apache2/conf.d/05-error_log.ini 

#PHP: HAVE THE SESSION FOLDER WRITABLE BY EVERYONE SO THAT WE DO NOT HAVE PERMISSION ISSUES
RUN chmod -R 777 /var/lib/php/sessions

#PHP MEMORY LIMIT
COPY ./start_files/php/ini/memory_limit.ini /etc/php/5.6/mods-available/memory_limit.ini 
RUN ln -s  /etc/php/5.6/mods-available/memory_limit.ini /etc/php/5.6/cli/conf.d/10-memory_limit.ini 
RUN ln -s  /etc/php/5.6/mods-available/memory_limit.ini /etc/php/5.6/apache2/conf.d/10-memory_limit.ini 

#PHP UPLOAD LIMIT
COPY ./start_files/php/ini/upload_size_limit.ini /etc/php/5.6/mods-available/upload_size_limit.ini 
RUN ln -s  /etc/php/5.6/mods-available/upload_size_limit.ini /etc/php/5.6/cli/conf.d/10-upload_size_limit.ini 
RUN ln -s  /etc/php/5.6/mods-available/upload_size_limit.ini /etc/php/5.6/apache2/conf.d/10-upload_size_limit.ini 

#INSTALL XHPROF
RUN pecl install -f xhprof
RUN  mkdir /tmp/xhprof && \
chmod 777 /tmp/xhprof && \
echo "extension=xhprof.so" > /etc/php/5.6/mods-available/xhprof.ini && \
echo "xhprof.output_dir='/tmp/xhprof'" >> /etc/php/5.6/mods-available/xhprof.ini && \
ln -s /etc/php/5.6/mods-available/xhprof.ini /etc/php/5.6/apache2/conf.d/35-xhprof.ini && \
ln -s /etc/php/5.6/mods-available/xhprof.ini /etc/php/5.6/cli/conf.d/35-xhprof.ini && \
ln -s /usr/share/php/xhprof_html /var/www/xhprof_html

#INSTALL A COMMON LOCALE TO BE USED LATER IF WE WANT
RUN locale-gen "en_US.UTF-8"

#SOME DEFAULT VHOST INCLUDED IN BASE WEBSERVER CONTAINER 
COPY ./start_files/apache/vhosts/ /etc/apache2/sites-enabled/

RUN apt-get clean && \
apt-get purge && \
apt-get autoremove && \
apt-get autoremove --purge

#THIS COMMAND WILL SHOW DRUSH VERSION
#IT COULD ALSO OUTPUT AN ERROR IF IT TRIES TO REMOVE A FILE THAT IS NO MORE NEEDED IF IT IS NOT THERE ANYMORE
RUN /root/.composer/vendor/bin/drush version
RUN echo If you see an error related to drush trying to unlink 'package.xml' do not worry, it was expected

RUN apt-get install screen -y
COPY ./start_files/ubuntu/screenrc /root/.screenrc

RUN apt-get install ssmtp -y
RUN echo "; configure ssmtp as a sendmail dummy wrapper" >> /etc/php/5.6/mods-available/sendmail.ini
RUN echo "; you can configure /etc/ssmtp/ssmtp.conf for the smtp server or mailcatcher" >> /etc/php/5.6/mods-available/sendmail.ini
RUN echo "sendmail_path = /usr/sbin/ssmtp -t" >> /etc/php/5.6/mods-available/sendmail.ini
RUN phpenmod sendmail


CMD ["sh", "/root/start_services.sh"]
