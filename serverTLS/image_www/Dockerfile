FROM handsonsecurity/seed-server:apache-php
ARG WWWDIR=/var/www/webserver

COPY ./index.html ./index_red.html $WWWDIR/
COPY ./webserver_apache_ssl.conf /etc/apache2/sites-available
COPY ./certs/webserver.crt ./certs/webserver.key ./certs/ca.crt  /certs/

RUN  chmod 400 /certs/webserver.key \
     && chmod 644 $WWWDIR/index.html \
     && chmod 644 $WWWDIR/index_red.html \
     && a2ensite webserver_apache_ssl   

CMD  service apache2 start && tail -f /dev/null

