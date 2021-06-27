if test "$AUTOINDEX" = "off"
then
sed -ie 's/autoindex on/autoindex off/g' ./etc/nginx/sites-available/ft_server.conf
fi
service mysql start
service nginx start
service php7.3-fpm start
tail -f /dev/null
