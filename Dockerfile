######## INSTALL ########

# Set the base image
FROM freeasso/debian-12


## Installation d'Apache 2
RUN apt-get update && apt-get install -y apt-utils apache2 apache2-doc apache2-utils libexpat1 ssl-cert libapache2-mod-passenger

## Variables d'environnement
ENV DOCUMENTROOT=www
ENV SERVERNAME=apache.local.fr
ENV ERRORLOG=error.log
ENV ACCESSLOG=access.log
ENV APP_SERVERNAME=localhost

## Suppression du vhost par défaut
RUN rm -f /etc/apache2/sites-enabled/*
COPY docker/localhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default

## Ajout des fichiers virtualhost
RUN cp -f /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig
RUN sed -e 's/# Global configuration/# Global configuration\nServerName localhost/g' < /etc/apache2/apache2.conf.orig > /etc/apache2/apache2.conf

## Activation des modules SSL et REWRITE
RUN a2enmod env
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod proxy
RUN a2enmod proxy_fcgi
RUN a2enmod proxy_http
RUN a2enmod proxy_wstunnel
RUN a2enmod setenvif
RUN a2dismod mpm_prefork
RUN a2enmod mpm_event 
RUN a2enmod passenger

## On expose le port 80 et 443
EXPOSE 80
EXPOSE 443

VOLUME /var/www
VOLUME /var/log/apache2

## On démarre apache, ...
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/apache.conf
CMD ["/usr/bin/supervisord", "-n"]