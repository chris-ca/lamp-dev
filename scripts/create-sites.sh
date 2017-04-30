block="<VirtualHost *:80>
	ServerAdmin webmaster@localhost

	ServerName $1
	DocumentRoot $2
	<Directory />
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Allow from all
		Require all granted
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory "/usr/lib/cgi-bin">
		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
"
sudo mkdir -p "/etc/apache2/sites-available" "/etc/apache2/sites-enabled"
sudo echo "$block" > "/etc/apache2/sites-available/$1.conf"
sudo ln -fs "/etc/apache2/sites-available/$1.conf" "/etc/apache2/sites-enabled/$1.conf"
sudo service apache2 restart
