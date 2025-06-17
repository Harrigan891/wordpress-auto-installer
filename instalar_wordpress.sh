#!/bin/bash

# Variables
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="TuPasswordSegura123"
WP_DIR="/var/www/html/wordpress"
WP_URL="https://wordpress.org/latest.tar.gz"

# Actualizar sistema
echo "🔄 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Apache
echo "📦 Instalando Apache..."
sudo apt install apache2 -y

# Instalar MySQL
echo "📦 Instalando MySQL..."
sudo apt install mysql-server -y

# Configurar MySQL: Crear base de datos y usuario
echo "🛠️ Configurando MySQL..."
sudo mysql <<EOF
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Instalar PHP y módulos necesarios
echo "📦 Instalando PHP y extensiones..."
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Descargar WordPress
echo "⬇️ Descargando WordPress..."
cd /tmp
curl -O $WP_URL
tar -xvzf latest.tar.gz
sudo mv wordpress $WP_DIR

# Permisos
echo "🔒 Ajustando permisos..."
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 755 $WP_DIR

# Configurar Apache
echo "⚙️ Configurando Apache para WordPress..."
cat <<EOL | sudo tee /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $WP_DIR
    ServerName localhost

    <Directory $WP_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Habilitar configuración
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# Configurar wp-config.php
echo "📝 Creando archivo wp-config.php..."
cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" $WP_DIR/wp-config.php
sed -i "s/username_here/${DB_USER}/" $WP_DIR/wp-config.php
sed -i "s/password_here/${DB_PASS}/" $WP_DIR/wp-config.php

# Insertar claves únicas
echo "🔑 Insertando claves de seguridad..."
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sed -i "/AUTH_KEY/d" $WP_DIR/wp-config.php
sed -i "/SECURE_AUTH_KEY/d" $WP_DIR/wp-config.php
sed -i "/LOGGED_IN_KEY/d" $WP_DIR/wp-config.php
sed -i "/NONCE_KEY/d" $WP_DIR/wp-config.php
sed -i "/AUTH_SALT/d" $WP_DIR/wp-config.php
sed -i "/SECURE_AUTH_SALT/d" $WP_DIR/wp-config.php
sed -i "/LOGGED_IN_SALT/d" $WP_DIR/wp-config.php
sed -i "/NONCE_SALT/d" $WP_DIR/wp-config.php
echo "$SALT" >> $WP_DIR/wp-config.php

echo "✅ Instalación completada. Abre en tu navegador: http://localhost/wordpress"
