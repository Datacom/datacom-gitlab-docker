#!/bin/bash

# Import dummy configuration
set -a

# This configuration is used during the image build process, where
# valid configuration files are expected by rake assets:precompile
GITLAB_HOST=localhost
GITLAB_PORT=80
GITLAB_HTTPS=false

GITLAB_EMAIL=gitlab@example.com
GITLAB_SUPPORT=support@example.com
GITLAB_SIGNUP=true

GITLAB_BACKUP_EXPIRY=0
GITLAB_SHELL_SSH_PORT=22

GITLAB_DB_HOST=localhost
GITLAB_DB_NAME=gitlab_temp
GITLAB_DB_USERNAME=root
GITLAB_DB_PASSWORD=

set +a

# Start mysql server
mysqld_safe > /var/log/mysql_temp.log 2>&1 &

# Wait for mysql server to start (max 120 seconds)
timeout=120
while ! mysqladmin -uroot status >/dev/null 2>&1
do
  timeout=$(expr $timeout - 1)
  if [ $timeout -eq 0 ]; then
    echo "Failed to start mysql server"
    exit 1
  fi
  sleep 1
done

# Create database
echo "CREATE DATABASE IF NOT EXISTS gitlab_temp DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -uroot
echo "GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlab_temp.* TO 'root'@'localhost';" | mysql -uroot

# Precompile assets
cd /home/git/gitlab
su git -c "bundle exec rake assets:precompile"
