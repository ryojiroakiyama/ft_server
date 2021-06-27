#image from
FROM debian:buster

#copy files for set-up related nginx, mariadb, wordpress-db and script
COPY ./srcs /tmp/

#install packages
RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y --no-install-recommends nginx mariadb-server mariadb-client \
	php-cgi php-common php-fpm php-pear php-mbstring php-zip php-net-socket php-gd \
	php-xml-util php-gettext php-mysql php-bcmath \
	openssl ca-certificates wget

#set up database
RUN service mysql start && \
	echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password && \
	echo "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wordpress';" | mysql -u root --skip-password && \
	echo "GRANT ALL ON wordpress.*  TO 'wpuser'@'localhost';" | mysql -u root --skip-password && \
	echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

#set up wordpress
RUN cd /tmp/ && wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	cp -r /tmp/wordpress /var/www/html/wordpress && \
	rm -rf /tmp/latest.tar.gz /tmp/wordpress && \
	mv /tmp/wp-config.php /var/www/html/wordpress/

#set up phpmyadmin
RUN cd /tmp/ && wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-english.tar.gz && \
	tar -xzvf phpMyAdmin-5.1.1-english.tar.gz && \
	cp -r phpMyAdmin-5.1.1-english /var/www/html/phpmyadmin && \
	rm -rf /tmp/phpMyAdmin-5.1.1-english /tmp/phpMyAdmin-5.1.1-english.tar.gz

#set up ssl
RUN mkdir /etc/nginx/ssl && \
	openssl genrsa \
	-out /etc/nginx/ssl/server.key 2048 && \
	openssl req \
	-new -key /etc/nginx/ssl/server.key \
	-out /etc/nginx/ssl/server.csr -subj "/C=JP" && \
	openssl x509 \
	-days 3650 -req -signkey /etc/nginx/ssl/server.key \
	-in /etc/nginx/ssl/server.csr \
	-out /etc/nginx/ssl/server.crt

#set up nginx conf file
RUN rm /etc/nginx/sites-enabled/default && \
	mv /tmp/ft_server.conf /etc/nginx/site-available/ && \
	ln -s /etc/nginx/sites-available/ft_server.conf /etc/nginx/sites-enabled/

#set authority
RUN chown -R www-data:www-data /var/www/html && \
	chmod -R 755 /var/www/html/

EXPOSE 80 443

ENTRYPOINT bash /tmp/setup.sh
