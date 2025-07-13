#!/bin/bash

echo "=== Démarrage du conteneur WordPress ==="

# Attendre que MySQL soit prêt
echo "Attente de la base de données..."
sleep 10

# Installer WordPress seulement si pas encore fait
if [ ! -f /var/www/html/wp-config.php ]; then
    
    echo "=== Configuration de WordPress ==="
    
    # Créer la configuration
    wp config create --dbname=$DB_NAME --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --allow-root --skip-check

    # Installer WordPress
    wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    # Créer un utilisateur supplémentaire
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root

    # Configuration SSL
    wp config set FORCE_SSL_ADMIN 'false' --allow-root

    # Permissions
    chmod 755 /var/www/html/wp-content

    echo "=== WordPress installé avec succès ! ==="
    echo "URL: $WP_URL"
    echo "Admin: $WP_ADMIN_USER / $WP_ADMIN_PASSWORD"
    echo "User: $WP_USER / $WP_USER_PASSWORD"
    
else
    echo "WordPress déjà configuré !"
fi

echo "=== Démarrage de PHP-FPM 7.4 ==="
# Démarrer PHP-FPM (version 7.4 pour Bullseye)
/usr/sbin/php-fpm7.4 -F
