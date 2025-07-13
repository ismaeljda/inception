#!/bin/bash

# Attendre que MariaDB démarre correctement
echo "⏳ Attente du démarrage de MariaDB..."
until mysqladmin ping --silent; do
    sleep 1
done
echo "✅ MariaDB est démarré."

# Définir les variables d'environnement
DB_NAME=${MYSQL_DATABASE:-my_database}
DB_USER=${MYSQL_USER:-my_user}
DB_PASS=${MYSQL_PASSWORD:-my_password}
ROOT_PASS=${MYSQL_ROOT_PASSWORD:-root_password}

# ⚠️ Connexion sans mot de passe car --skip-grant-tables est activé
echo "🔧 Configuration initiale de MariaDB..."

mysql -u root --skip-password <<EOF
-- Réactiver la gestion des mots de passe (inutile ici mais bonne pratique)
FLUSH PRIVILEGES;

-- Définir un mot de passe pour root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Créer un utilisateur avec mot de passe
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';

-- Donner tous les privilèges à l'utilisateur sur la base
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

echo "✅ Initialisation terminée."
