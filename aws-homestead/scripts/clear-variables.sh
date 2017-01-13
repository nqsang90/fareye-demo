# Clear The Old Environment Variables

sed -i '/# Set Homestead Environment Variable/,+1d' /home/ubuntu/.profile
sed -i '/env\[.*/,+1d' /etc/php/7.1/fpm/php-fpm.conf
