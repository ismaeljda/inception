#!/bin/bash

echo "🚀 Démarrage de MariaDB..."

# Démarrer MariaDB en arrière-plan
mysqld_safe --user=mysql --datadir=/var/lib/mysql &

# Attendre que MariaDB soit prêt
echo "⏳ Attente du démarrage de MariaDB..."
while ! mysqladmin ping --silent; do
    echo "En attente..."
    sleep 2
done
echo "✅ MariaDB est démarré."

# Définir les variables d'environnement
DB_NAME=${MYSQL_DATABASE:-my_database}
DB_USER=${MYSQL_USER:-my_user}
DB_PASS=${MYSQL_PASSWORD:-my_password}
ROOT_PASS=${MYSQL_ROOT_PASSWORD:-root_password}

echo "🔧 Configuration initiale de MariaDB..."
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Configuration initiale (la première fois, root n'a pas de mot de passe)
mysql -u root <<EOF
-- Définir un mot de passe pour root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Créer un utilisateur avec mot de passe
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';

-- Donner tous les privilèges à l'utilisateur sur la base
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Configuration terminée avec succès."
else
    echo "❌ Erreur lors de la configuration."
fi

# Arrêter MariaDB pour redémarrer proprement
mysqladmin -u root -p${ROOT_PASS} shutdown

echo "🔄 Redémarrage de MariaDB..."
# Redémarrer MariaDB au premier plan
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql