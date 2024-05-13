#!/bin/bash
set -x

# MySQL database details
DB_HOST="xx.xx.x.x"
DB_USER="xxxxxxx"
DB_PASS="xxxxxxxxx"
DB_NAME="xxxxxxx"

# DigitalOcean Spaces details
SPACES_KEY="xxxxxxx"
SPACES_SECRET="xxxxx"
SPACES_BUCKET="xxxxx-msql-backup"
SPACES_REGION="xxxxx"

# Date format for backup file
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Dump MySQL Database to a local file
mysqldump --no-tablespaces -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME  > /tmp/$DB_NAME-$DATE.sql

# Upload the backup file to DigitalOcean Spaces
s3cmd put /tmp/$DB_NAME-$DATE.sql s3://$SPACES_BUCKET/$DB_NAME-$DATE.sql \
--access_key=$SPACES_KEY \
--secret_key=$SPACES_SECRET \
--region=$SPACES_REGION

# Remove the local backup file
rm /tmp/$DB_NAME-$DATE.sql

echo "Backup of database $DB_NAME completed and uploaded to DigitalOcean Spaces."