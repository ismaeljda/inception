#!/bin/bash

echo "=== Démarrage du conteneur WordPress ==="

# Attendre que MySQL soit prêt avec une vérification plus robuste
echo "Attente de la base de données..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if mysqladmin ping -h$DB_HOST -u$DB_USER -p$DB_PASSWORD --silent; then
        echo "✅ Base de données accessible!"
        break
    else
        echo "⏳ Tentative $((attempt + 1))/$max_attempts..."
        sleep 2
        ((attempt++))
    fi
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Impossible de se connecter à la base de données après $max_attempts tentatives"
    exit 1
fi

# Installer WordPress seulement si pas encore fait
if [ ! -f /var/www/html/wp-config.php ]; then
    
    echo "=== Configuration de WordPress ==="
    
    # Créer la configuration avec vérification
    wp config create --dbname=$DB_NAME --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --allow-root
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la création de wp-config.php"
        exit 1
    fi
    
    # Vérifier la connexion avant d'installer
    if ! wp db check --allow-root; then
        echo "❌ Impossible de se connecter à la base de données"
        exit 1
    fi

    # Installer WordPress
    wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation de WordPress"
        exit 1
    fi

    # Créer un utilisateur supplémentaire
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root

    # Configuration SSL
    wp config set FORCE_SSL_ADMIN 'false' --allow-root

    # Permissions
    chmod 755 /var/www/html/wp-content
    chown -R www-data:www-data /var/www/html

    echo "✅ WordPress installé avec succès!"
    echo "URL: $WP_URL"
    echo "Admin: $WP_ADMIN_USER / $WP_ADMIN_PASSWORD"
    echo "User: $WP_USER / $WP_USER_PASSWORD"
    
else
    echo "✅ WordPress déjà configuré!"
fi

echo "=== Démarrage de PHP-FPM 7.4 ==="
# Démarrer PHP-FPM (version 7.4 pour Bullseye)
exec /usr/sbin/php-fpm7.4 -F